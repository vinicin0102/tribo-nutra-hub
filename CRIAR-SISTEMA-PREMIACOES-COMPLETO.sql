-- ============================================
-- SISTEMA DE PREMIAÇÕES COMPLETO
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. CRIAR TABELA DE PRÊMIOS
CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  points_cost INTEGER NOT NULL,
  stock INTEGER DEFAULT -1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. CRIAR TABELA DE RESGATES
CREATE TABLE IF NOT EXISTS public.redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE NOT NULL,
  points_spent INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'delivered', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. REMOVER TODAS AS POLÍTICAS ANTIGAS
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'rewards' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.rewards';
    END LOOP;
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'redemptions' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.redemptions';
    END LOOP;
END $$;

-- 4. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE public.rewards DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions DISABLE ROW LEVEL SECURITY;

-- 5. LIMPAR E INSERIR PRÊMIOS
DELETE FROM public.rewards;
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop'),
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop'),
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop'),
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400&h=300&fit=crop');

-- 6. CRIAR FUNÇÃO PARA RESGATAR PRÊMIO
CREATE OR REPLACE FUNCTION public.redeem_reward(
  p_user_id UUID,
  p_reward_id UUID
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_reward RECORD;
  v_user_points INTEGER;
  v_points_cost INTEGER;
BEGIN
  -- Buscar informações do prêmio
  SELECT * INTO v_reward
  FROM public.rewards
  WHERE id = p_reward_id AND is_active = true;
  
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Prêmio não encontrado ou inativo'::TEXT;
    RETURN;
  END IF;
  
  -- Buscar pontos do usuário
  SELECT COALESCE(points, 0) INTO v_user_points
  FROM public.profiles
  WHERE user_id = p_user_id;
  
  v_points_cost := v_reward.points_cost;
  
  -- Verificar se tem pontos suficientes
  IF v_user_points < v_points_cost THEN
    RETURN QUERY SELECT false, ('Pontos insuficientes. Você tem ' || v_user_points || ' pontos, mas precisa de ' || v_points_cost || ' pontos.')::TEXT;
    RETURN;
  END IF;
  
  -- Verificar estoque
  IF v_reward.stock IS NOT NULL AND v_reward.stock >= 0 AND v_reward.stock = 0 THEN
    RETURN QUERY SELECT false, 'Prêmio esgotado'::TEXT;
    RETURN;
  END IF;
  
  -- Criar resgate
  INSERT INTO public.redemptions (user_id, reward_id, points_spent, status)
  VALUES (p_user_id, p_reward_id, v_points_cost, 'pending');
  
  -- Deduzir pontos do usuário
  UPDATE public.profiles
  SET points = points - v_points_cost
  WHERE user_id = p_user_id;
  
  -- Atualizar estoque se aplicável
  IF v_reward.stock IS NOT NULL AND v_reward.stock > 0 THEN
    UPDATE public.rewards
    SET stock = stock - 1
    WHERE id = p_reward_id;
  END IF;
  
  RETURN QUERY SELECT true, 'Resgate solicitado com sucesso! Aguarde a avaliação do suporte.'::TEXT;
END;
$$;

-- 7. HABILITAR RLS
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;

-- 8. CRIAR POLÍTICAS RLS PARA REWARDS
CREATE POLICY "Everyone can view active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- 9. CRIAR POLÍTICAS RLS PARA REDEMPTIONS
CREATE POLICY "Users can view own redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Support can view all redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (email = 'admin@gmail.com' OR role = 'support' OR role = 'admin')
  )
);

CREATE POLICY "Users can create own redemptions"
ON public.redemptions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Support can update redemptions"
ON public.redemptions FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (email = 'admin@gmail.com' OR role = 'support' OR role = 'admin')
  )
);

-- 10. VERIFICAR
SELECT 
  '✅ SISTEMA DE PREMIAÇÕES CRIADO!' as status,
  (SELECT COUNT(*) FROM public.rewards) as total_premios,
  (SELECT COUNT(*) FROM public.redemptions) as total_resgates;

