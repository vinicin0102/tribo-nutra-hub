-- ============================================
-- MIGRAÇÃO: SISTEMA DE ASSINATURA
-- ============================================
-- Execute este script no SQL Editor do Supabase

-- 1. Adicionar coluna de plano na tabela profiles
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'subscription_plan'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN subscription_plan TEXT DEFAULT 'free' CHECK (subscription_plan IN ('free', 'diamond'));
    RAISE NOTICE 'Coluna subscription_plan adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna subscription_plan já existe na tabela profiles';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'subscription_expires_at'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN subscription_expires_at TIMESTAMP WITH TIME ZONE;
    RAISE NOTICE 'Coluna subscription_expires_at adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna subscription_expires_at já existe na tabela profiles';
  END IF;
END $$;

-- 2. Criar tabela de pagamentos (para histórico)
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  plan TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'failed', 'refunded')),
  payment_method TEXT,
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Políticas RLS para payments
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own payments" ON public.payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create payments" ON public.payments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Função para verificar se usuário tem acesso Diamond
CREATE OR REPLACE FUNCTION public.has_diamond_access()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  user_plan TEXT;
  expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  SELECT subscription_plan, subscription_expires_at 
  INTO user_plan, expires_at
  FROM public.profiles
  WHERE user_id = auth.uid();
  
  -- Se for plano diamond e não expirou (ou não tem data de expiração = vitalício)
  IF user_plan = 'diamond' THEN
    IF expires_at IS NULL OR expires_at > NOW() THEN
      RETURN TRUE;
    END IF;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 5. Índices para performance
CREATE INDEX IF NOT EXISTS idx_profiles_subscription ON public.profiles(subscription_plan);
CREATE INDEX IF NOT EXISTS idx_payments_user ON public.payments(user_id);

-- 6. Verificar se tudo foi criado
SELECT 
  'Migração de assinatura concluída!' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'subscription_plan'
    ) THEN '✓ Coluna subscription_plan em profiles'
    ELSE '✗ Coluna subscription_plan em profiles'
  END as check_subscription,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_name = 'payments'
    ) THEN '✓ Tabela payments'
    ELSE '✗ Tabela payments'
  END as check_payments;

