-- ============================================
-- CORREÇÃO COMPLETA DO BANCO DE DADOS
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- Este script corrige TODAS as inconsistências
-- ============================================

-- ============================================
-- PARTE 1: ADICIONAR COLUNAS FALTANTES EM PROFILES
-- ============================================

DO $$ 
BEGIN
  -- Adicionar colunas de subscription
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'subscription_plan') THEN
    ALTER TABLE public.profiles ADD COLUMN subscription_plan TEXT DEFAULT 'bronze';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'subscription_expires_at') THEN
    ALTER TABLE public.profiles ADD COLUMN subscription_expires_at TIMESTAMP WITH TIME ZONE;
  END IF;
  
  -- Adicionar colunas de tier
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'tier') THEN
    ALTER TABLE public.profiles ADD COLUMN tier TEXT DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum', 'diamond'));
  END IF;
  
  -- Adicionar colunas de admin/ban/mute
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'role') THEN
    ALTER TABLE public.profiles ADD COLUMN role TEXT DEFAULT 'user';
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'email') THEN
    ALTER TABLE public.profiles ADD COLUMN email TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'is_banned') THEN
    ALTER TABLE public.profiles ADD COLUMN is_banned BOOLEAN DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'banned_until') THEN
    ALTER TABLE public.profiles ADD COLUMN banned_until TIMESTAMP WITH TIME ZONE;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'is_muted') THEN
    ALTER TABLE public.profiles ADD COLUMN is_muted BOOLEAN DEFAULT false;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'mute_until') THEN
    ALTER TABLE public.profiles ADD COLUMN mute_until TIMESTAMP WITH TIME ZONE;
  END IF;
END $$;

-- ============================================
-- PARTE 2: ADICIONAR COLUNAS FALTANTES EM POSTS
-- ============================================

DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'posts' AND column_name = 'is_support_post') THEN
    ALTER TABLE public.posts ADD COLUMN is_support_post BOOLEAN DEFAULT false;
  END IF;
END $$;

-- ============================================
-- PARTE 3: CRIAR TABELAS FALTANTES
-- ============================================

-- Tabela rewards
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

-- Constraint UNIQUE em name
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'rewards_name_key' 
      AND conrelid = 'public.rewards'::regclass
  ) THEN
    ALTER TABLE public.rewards ADD CONSTRAINT rewards_name_key UNIQUE (name);
  END IF;
END $$;

-- Tabela redemptions
CREATE TABLE IF NOT EXISTS public.redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE NOT NULL,
  points_spent INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'delivered', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela support_chat
CREATE TABLE IF NOT EXISTS public.support_chat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  support_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_from_support BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  plan_type TEXT NOT NULL,
  status TEXT NOT NULL,
  payment_provider TEXT,
  payment_provider_subscription_id TEXT,
  payment_provider_customer_id TEXT,
  payment_provider_payment_id TEXT,
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at_period_end BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Tabela payments
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'brl',
  status TEXT NOT NULL,
  payment_provider TEXT,
  payment_provider_payment_id TEXT,
  payment_method TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ============================================
-- PARTE 4: HABILITAR RLS EM TODAS AS TABELAS
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_chat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PARTE 5: POLÍTICAS RLS PARA PROFILES
-- ============================================

-- Remover políticas antigas
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;

-- Criar políticas corretas
CREATE POLICY "Profiles are viewable by everyone" 
ON public.profiles FOR SELECT 
USING (true);

CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Admins can update any profile" 
ON public.profiles FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role = 'admin')
  )
);

CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Política para permitir usuário atualizar próprio plano
CREATE POLICY "Users can update own subscription" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id AND
  (OLD.subscription_plan IS DISTINCT FROM NEW.subscription_plan OR
   OLD.subscription_expires_at IS DISTINCT FROM NEW.subscription_expires_at)
);

-- ============================================
-- PARTE 6: POLÍTICAS RLS PARA REWARDS
-- ============================================

DROP POLICY IF EXISTS "Everyone can view active rewards" ON public.rewards;
CREATE POLICY "Everyone can view active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- ============================================
-- PARTE 7: POLÍTICAS RLS PARA REDEMPTIONS
-- ============================================

DROP POLICY IF EXISTS "Users can view own redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Users can create redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Support can view all redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Support can update redemptions" ON public.redemptions;

CREATE POLICY "Users can view own redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create redemptions"
ON public.redemptions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Support can view all redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role IN ('admin', 'support'))
  )
);

CREATE POLICY "Support can update redemptions"
ON public.redemptions FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role IN ('admin', 'support'))
  )
);

-- ============================================
-- PARTE 8: POLÍTICAS RLS PARA SUPPORT_CHAT
-- ============================================

DROP POLICY IF EXISTS "Users can view own support chat" ON public.support_chat;
DROP POLICY IF EXISTS "Users can send support messages" ON public.support_chat;
DROP POLICY IF EXISTS "Support can view all chats" ON public.support_chat;
DROP POLICY IF EXISTS "Support can send messages" ON public.support_chat;

CREATE POLICY "Users can view own support chat"
ON public.support_chat FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can send support messages"
ON public.support_chat FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id AND is_from_support = false);

CREATE POLICY "Support can view all chats"
ON public.support_chat FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role IN ('admin', 'support'))
  )
);

CREATE POLICY "Support can send messages"
ON public.support_chat FOR INSERT
TO authenticated
WITH CHECK (
  is_from_support = true AND
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role IN ('admin', 'support'))
  )
);

-- ============================================
-- PARTE 9: FUNÇÕES RPC NECESSÁRIAS
-- ============================================

-- Função redeem_reward
DROP FUNCTION IF EXISTS public.redeem_reward(UUID, UUID);
CREATE OR REPLACE FUNCTION public.redeem_reward(
  p_user_id UUID,
  p_reward_id UUID
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_reward RECORD;
  v_user_points INTEGER;
  v_points_cost INTEGER;
BEGIN
  -- Buscar prêmio
  SELECT * INTO v_reward FROM public.rewards WHERE id = p_reward_id AND is_active = true;
  
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Prêmio não encontrado ou inativo';
    RETURN;
  END IF;
  
  -- Buscar pontos do usuário
  SELECT COALESCE(points, 0) INTO v_user_points FROM public.profiles WHERE user_id = p_user_id;
  
  -- Determinar custo
  v_points_cost := COALESCE(v_reward.points_cost, v_reward.points_required, 0);
  
  -- Verificar se tem pontos suficientes
  IF v_user_points < v_points_cost THEN
    RETURN QUERY SELECT false, 'Pontos insuficientes';
    RETURN;
  END IF;
  
  -- Verificar estoque
  IF v_reward.stock IS NOT NULL AND v_reward.stock <= 0 THEN
    RETURN QUERY SELECT false, 'Prêmio esgotado';
    RETURN;
  END IF;
  
  -- Criar resgate
  INSERT INTO public.redemptions (user_id, reward_id, points_spent, status)
  VALUES (p_user_id, p_reward_id, v_points_cost, 'pending');
  
  -- Deduzir pontos
  UPDATE public.profiles 
  SET points = points - v_points_cost 
  WHERE user_id = p_user_id;
  
  -- Atualizar estoque
  IF v_reward.stock IS NOT NULL AND v_reward.stock > 0 THEN
    UPDATE public.rewards 
    SET stock = stock - 1 
    WHERE id = p_reward_id;
  END IF;
  
  RETURN QUERY SELECT true, 'Prêmio resgatado com sucesso!';
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_reward(UUID, UUID) TO authenticated;

-- Função record_daily_login
DROP FUNCTION IF EXISTS public.record_daily_login(UUID);
CREATE OR REPLACE FUNCTION public.record_daily_login(
  p_user_id UUID
)
RETURNS TABLE(already_logged BOOLEAN, points_earned INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_last_login DATE;
  v_points INTEGER := 8;
BEGIN
  -- Verificar último login
  SELECT MAX(created_at::DATE) INTO v_last_login
  FROM public.notifications
  WHERE user_id = p_user_id AND type = 'daily_login';
  
  -- Se já logou hoje, retornar
  IF v_last_login = CURRENT_DATE THEN
    RETURN QUERY SELECT true, 0;
    RETURN;
  END IF;
  
  -- Adicionar pontos
  UPDATE public.profiles 
  SET points = COALESCE(points, 0) + v_points 
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (p_user_id, 'daily_login', 'Login diário', 'Você ganhou ' || v_points || ' pontos por fazer login hoje!');
  
  RETURN QUERY SELECT false, v_points;
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_daily_login(UUID) TO authenticated;

-- Função ban_user_temporary
DROP FUNCTION IF EXISTS public.ban_user_temporary(UUID, INTEGER);
CREATE OR REPLACE FUNCTION public.ban_user_temporary(
  p_user_id UUID,
  p_days INTEGER
)
RETURNS TABLE(success BOOLEAN, error TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verificar se é admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role = 'admin')
  ) THEN
    RETURN QUERY SELECT false, 'Acesso negado';
    RETURN;
  END IF;
  
  -- Banir usuário
  UPDATE public.profiles 
  SET 
    is_banned = true,
    banned_until = NOW() + (p_days || ' days')::INTERVAL
  WHERE user_id = p_user_id;
  
  RETURN QUERY SELECT true, NULL::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ban_user_temporary(UUID, INTEGER) TO authenticated;

-- Função mute_user
DROP FUNCTION IF EXISTS public.mute_user(UUID, INTEGER);
CREATE OR REPLACE FUNCTION public.mute_user(
  p_user_id UUID,
  p_hours INTEGER
)
RETURNS TABLE(success BOOLEAN, error TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verificar se é admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role = 'admin')
  ) THEN
    RETURN QUERY SELECT false, 'Acesso negado';
    RETURN;
  END IF;
  
  -- Mutar usuário
  UPDATE public.profiles 
  SET 
    is_muted = true,
    mute_until = CASE 
      WHEN p_hours = -1 THEN NULL -- permanente
      ELSE NOW() + (p_hours || ' hours')::INTERVAL
    END
  WHERE user_id = p_user_id;
  
  RETURN QUERY SELECT true, NULL::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mute_user(UUID, INTEGER) TO authenticated;

-- Função unmute_user
DROP FUNCTION IF EXISTS public.unmute_user(UUID);
CREATE OR REPLACE FUNCTION public.unmute_user(
  p_user_id UUID
)
RETURNS TABLE(success BOOLEAN, error TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verificar se é admin
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
      AND (email = 'admin@gmail.com' OR role = 'admin')
  ) THEN
    RETURN QUERY SELECT false, 'Acesso negado';
    RETURN;
  END IF;
  
  -- Desmutar usuário
  UPDATE public.profiles 
  SET 
    is_muted = false,
    mute_until = NULL
  WHERE user_id = p_user_id;
  
  RETURN QUERY SELECT true, NULL::TEXT;
END;
$$;

GRANT EXECUTE ON FUNCTION public.unmute_user(UUID) TO authenticated;

-- ============================================
-- PARTE 10: INSERIR DADOS PADRÃO
-- ============================================

-- Inserir badges se não existirem
INSERT INTO public.badges (name, description, icon, points_required)
SELECT * FROM (VALUES
  ('Influenciador', 'Fez 20 postagens', '🏅', 20),
  ('Ativo', '7 dias seguidos entrando', '🥇', 7),
  ('Engajado', '7 curtidas e 7 comentários', '🥈', 14),
  ('Lenda', '100 postagens, 100 curtidas, 100 comentários', '🥉', 300)
) AS v(name, description, icon, points_required)
WHERE NOT EXISTS (SELECT 1 FROM public.badges WHERE badges.name = v.name);

-- Inserir prêmios se não existirem
DELETE FROM public.rewards WHERE name IN ('Pix Misterioso', 'Um Dia de Anúncios', 'Viagem Tudo Pago', 'iPhone Novo');

INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url, created_at)
VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, NULL, NOW()),
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, NULL, NOW()),
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, NULL, NOW()),
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, NULL, NOW());

-- ============================================
-- PARTE 11: HABILITAR REALTIME
-- ============================================

DO $$ 
BEGIN
  -- Adicionar tabelas ao realtime se não estiverem
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.posts;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.comments;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.likes;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.redemptions;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.support_chat;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END $$;

-- ============================================
-- PARTE 12: VERIFICAÇÃO FINAL
-- ============================================

SELECT '✅ CORREÇÃO COMPLETA!' as status;

-- Verificar tabelas
SELECT 
  'Tabelas criadas:' as verificação,
  table_name
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name IN ('profiles', 'posts', 'rewards', 'redemptions', 'support_chat', 'subscriptions', 'payments')
ORDER BY table_name;

-- Verificar prêmios
SELECT 
  'Prêmios cadastrados:' as verificação,
  COUNT(*) as total
FROM public.rewards
WHERE is_active = true;

-- Verificar funções RPC
SELECT 
  'Funções RPC:' as verificação,
  routine_name
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND routine_name IN ('redeem_reward', 'record_daily_login', 'ban_user_temporary', 'mute_user', 'unmute_user')
ORDER BY routine_name;

