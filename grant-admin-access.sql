-- =====================================================
-- CONCEDER ACESSO DE ADMIN PARA admin@gmail.com
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Verificar se o usuário existe
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'admin@gmail.com';

-- 2. Atualizar ou criar perfil com role admin
DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Buscar ID do usuário
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'admin@gmail.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário admin@gmail.com não encontrado. Crie a conta primeiro.';
  END IF;
  
  -- Atualizar ou criar perfil com role admin
  INSERT INTO public.profiles (user_id, username, role, subscription_plan, points)
  VALUES (
    v_user_id,
    'admin',
    'admin',
    'diamond',
    999999
  )
  ON CONFLICT (user_id) DO UPDATE
  SET 
    role = 'admin',
    subscription_plan = 'diamond',
    updated_at = NOW();
  
  RAISE NOTICE 'Perfil de admin atualizado com sucesso!';
END $$;

-- 3. Verificar resultado
SELECT 
  p.user_id,
  p.username,
  p.role,
  p.subscription_plan,
  p.points,
  u.email
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'admin@gmail.com';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora admin@gmail.com tem acesso ao painel
-- =====================================================

