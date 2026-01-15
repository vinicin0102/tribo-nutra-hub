-- =====================================================
-- CONCEDER PLANO DIAMOND PARA TODOS OS USUÁRIOS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Garantir que a coluna subscription_plan existe
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'subscription_plan'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN subscription_plan TEXT DEFAULT 'free' CHECK (subscription_plan IN ('free', 'diamond'));
    RAISE NOTICE 'Coluna subscription_plan adicionada à tabela profiles';
  END IF;
END $$;

-- 2. Atualizar TODOS os perfis existentes para DIAMOND
UPDATE public.profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NULL, -- NULL = vitalício
  updated_at = NOW()
WHERE subscription_plan IS NULL OR subscription_plan != 'diamond';

-- 3. Criar perfis para usuários que ainda não têm (se necessário)
INSERT INTO public.profiles (user_id, username, subscription_plan, subscription_expires_at, created_at, updated_at)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data ->> 'username', split_part(u.email, '@', 1)),
  'diamond',
  NULL, -- NULL = vitalício
  NOW(),
  NOW()
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE p.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- 4. Atualizar também a tabela subscriptions (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'subscriptions'
  ) THEN
    -- Atualizar assinaturas existentes
    UPDATE subscriptions
    SET 
      plan_type = 'diamond',
      status = 'active',
      current_period_end = NULL,
      updated_at = NOW()
    WHERE plan_type != 'diamond' OR status != 'active';
    
    -- Criar assinaturas para usuários que não têm
    INSERT INTO subscriptions (user_id, plan_type, status, created_at, updated_at)
    SELECT 
      u.id,
      'diamond',
      'active',
      NOW(),
      NOW()
    FROM auth.users u
    LEFT JOIN subscriptions s ON s.user_id = u.id
    WHERE s.id IS NULL
    ON CONFLICT (user_id) DO NOTHING;
    
    RAISE NOTICE 'Tabela subscriptions atualizada';
  END IF;
END $$;

-- 5. Mostrar resultado
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN subscription_plan = 'diamond' THEN 1 END) as usuarios_diamond,
  COUNT(CASE WHEN subscription_plan = 'free' OR subscription_plan IS NULL THEN 1 END) as usuarios_free
FROM public.profiles;

-- =====================================================
-- PRONTO! 🎉 Todos os usuários agora têm DIAMOND
-- =====================================================

