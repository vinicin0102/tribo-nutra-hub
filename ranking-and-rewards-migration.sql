-- ============================================
-- MIGRAÇÃO: SISTEMA DE RANKING E PREMIAÇÃO
-- ============================================
-- Execute este script no SQL Editor do Supabase

-- 1. Adicionar campo tier (nível) na tabela profiles
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'tier'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN tier TEXT DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum', 'diamond'));
    RAISE NOTICE 'Coluna tier adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna tier já existe na tabela profiles';
  END IF;
END $$;

-- 2. Criar tabela de prêmios
CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  points_cost INTEGER NOT NULL,
  stock INTEGER DEFAULT -1, -- -1 = ilimitado
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Criar tabela de resgates
CREATE TABLE IF NOT EXISTS public.redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE NOT NULL,
  points_spent INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'delivered', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. Atualizar função de pontos para post (de 5 para 2 pontos)
CREATE OR REPLACE FUNCTION public.add_points_for_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  post_count INTEGER;
BEGIN
  -- Verificar se é a primeira postagem (concede Bronze)
  SELECT COUNT(*) INTO post_count
  FROM public.posts
  WHERE user_id = NEW.user_id;
  
  -- Se for a primeira postagem, definir tier como bronze e adicionar 2 pontos
  IF post_count = 1 THEN
    UPDATE public.profiles 
    SET tier = 'bronze', points = COALESCE(points, 0) + 2
    WHERE user_id = NEW.user_id;
  ELSE
    -- Adicionar 2 pontos para postagens seguintes
    UPDATE public.profiles 
    SET points = COALESCE(points, 0) + 2
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Remover trigger antigo se existir (que adiciona 5 pontos)
-- O trigger antigo também se chama on_post_created, então vamos substituí-lo
DROP TRIGGER IF EXISTS on_post_created ON public.posts;

-- Criar novo trigger que adiciona 2 pontos e concede bronze na primeira postagem
CREATE TRIGGER on_post_created
  AFTER INSERT ON public.posts
  FOR EACH ROW EXECUTE FUNCTION public.add_points_for_post();

-- 5. Atualizar função de curtidas (já está +1, manter)
-- A função atual já adiciona +1 ponto, está correta

-- 6. Adicionar pontos para comentários (+1 ponto para o autor do post)
CREATE OR REPLACE FUNCTION public.add_points_for_comment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Adicionar 1 ponto para o autor do post que recebeu o comentário
  UPDATE public.profiles 
  SET points = COALESCE(points, 0) + 1 
  WHERE user_id = (
    SELECT user_id FROM public.posts WHERE id = NEW.post_id
  );
  
  RETURN NEW;
END;
$$;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS on_comment_points ON public.comments;

-- Criar novo trigger para comentários
CREATE TRIGGER on_comment_points
  AFTER INSERT ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.add_points_for_comment();

-- 6.1. Remover trigger antigo de posts que adiciona 5 pontos
DROP TRIGGER IF EXISTS on_post_created_old ON public.posts;

-- 7. Função para atualizar tier baseado em pontos
CREATE OR REPLACE FUNCTION public.update_user_tier()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  user_points INTEGER;
BEGIN
  user_points := COALESCE(NEW.points, 0);
  
  -- Atualizar tier baseado em pontos
  -- Bronze: 0-29 pontos (primeira postagem = bronze)
  -- Prata: 30-99 pontos
  -- Ouro: 100-249 pontos
  -- Platina: 250-499 pontos
  -- Diamante: 500+ pontos
  
  IF user_points >= 500 THEN
    NEW.tier := 'diamond';
  ELSIF user_points >= 250 THEN
    NEW.tier := 'platinum';
  ELSIF user_points >= 100 THEN
    NEW.tier := 'gold';
  ELSIF user_points >= 30 THEN
    NEW.tier := 'silver';
  ELSE
    -- Se não tem pontos suficientes mas já tem postagem, mantém bronze
    IF (SELECT COUNT(*) FROM public.posts WHERE user_id = NEW.user_id) > 0 THEN
      NEW.tier := 'bronze';
    ELSE
      NEW.tier := COALESCE(OLD.tier, 'bronze');
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Trigger para atualizar tier quando pontos mudam
DROP TRIGGER IF EXISTS on_points_update_tier ON public.profiles;
CREATE TRIGGER on_points_update_tier
  BEFORE UPDATE OF points ON public.profiles
  FOR EACH ROW
  WHEN (OLD.points IS DISTINCT FROM NEW.points)
  EXECUTE FUNCTION public.update_user_tier();

-- 8. Políticas RLS para rewards
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Rewards are viewable by everyone" ON public.rewards FOR SELECT USING (is_active = true);
CREATE POLICY "Users can view own redemptions" ON public.redemptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create redemptions" ON public.redemptions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 9. Função para resgatar prêmio
CREATE OR REPLACE FUNCTION public.redeem_reward(reward_uuid UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  reward_points INTEGER;
  user_points INTEGER;
  redemption_id UUID;
BEGIN
  -- Buscar custo do prêmio
  SELECT points_cost INTO reward_points
  FROM public.rewards
  WHERE id = reward_uuid AND is_active = true;
  
  IF reward_points IS NULL THEN
    RAISE EXCEPTION 'Prêmio não encontrado ou inativo';
  END IF;
  
  -- Buscar pontos do usuário
  SELECT points INTO user_points
  FROM public.profiles
  WHERE user_id = auth.uid();
  
  IF user_points IS NULL OR user_points < reward_points THEN
    RAISE EXCEPTION 'Pontos insuficientes';
  END IF;
  
  -- Verificar estoque
  IF (SELECT stock FROM public.rewards WHERE id = reward_uuid) = 0 THEN
    RAISE EXCEPTION 'Prêmio esgotado';
  END IF;
  
  -- Criar resgate
  INSERT INTO public.redemptions (user_id, reward_id, points_spent)
  VALUES (auth.uid(), reward_uuid, reward_points)
  RETURNING id INTO redemption_id;
  
  -- Deduzir pontos
  UPDATE public.profiles
  SET points = points - reward_points
  WHERE user_id = auth.uid();
  
  -- Reduzir estoque (se não for ilimitado)
  UPDATE public.rewards
  SET stock = stock - 1
  WHERE id = reward_uuid AND stock > 0;
  
  RETURN redemption_id;
END;
$$;

-- 10. Índices para performance
CREATE INDEX IF NOT EXISTS idx_profiles_tier ON public.profiles(tier);
CREATE INDEX IF NOT EXISTS idx_profiles_points ON public.profiles(points DESC);
CREATE INDEX IF NOT EXISTS idx_rewards_active ON public.rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON public.redemptions(user_id);

-- 11. Verificar se tudo foi criado
SELECT 
  'Migração concluída!' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'tier'
    ) THEN '✓ Coluna tier em profiles'
    ELSE '✗ Coluna tier em profiles'
  END as check_tier,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_name = 'rewards'
    ) THEN '✓ Tabela rewards'
    ELSE '✗ Tabela rewards'
  END as check_rewards,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_name = 'redemptions'
    ) THEN '✓ Tabela redemptions'
    ELSE '✗ Tabela redemptions'
  END as check_redemptions;

