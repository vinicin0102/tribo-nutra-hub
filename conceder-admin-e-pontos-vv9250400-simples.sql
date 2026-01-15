-- =====================================================
-- CONCEDER 70.000 PONTOS E ADMIN PARA vv9250400@gmail.com
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Verificar se o usuário existe
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE email = 'vv9250400@gmail.com';

-- 2. Atualizar ou criar perfil com 70.000 pontos e role admin
INSERT INTO profiles (
  user_id,
  username,
  email,
  points,
  role,
  subscription_plan,
  created_at,
  updated_at
)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'username', 'vv9250400'),
  'vv9250400@gmail.com',
  70000,
  'admin',
  'diamond',
  NOW(),
  NOW()
FROM auth.users u
WHERE u.email = 'vv9250400@gmail.com'
ON CONFLICT (user_id) DO UPDATE
SET 
  points = 70000,
  role = 'admin',
  subscription_plan = 'diamond',
  email = 'vv9250400@gmail.com',
  updated_at = NOW();

-- 3. Verificar resultado
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.points,
  p.role,
  p.subscription_plan,
  u.email as auth_email
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- O usuário agora tem:
-- ✅ 70.000 pontos
-- ✅ Role: admin (acesso a admin e suporte)
-- ✅ Plano: diamond
-- =====================================================

