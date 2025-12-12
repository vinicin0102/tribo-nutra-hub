-- =====================================================
-- ATUALIZAR FORÇADO - vv9250400@gmail.com
-- =====================================================
-- Este script força a atualização mesmo se já existir
-- =====================================================

-- Primeiro, vamos ver o que existe
SELECT 
  p.user_id,
  p.points,
  p.role,
  p.subscription_plan
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

-- Agora vamos atualizar FORÇADAMENTE
UPDATE profiles
SET 
  points = 70000,
  role = 'admin',
  subscription_plan = 'diamond',
  email = 'vv9250400@gmail.com',
  updated_at = NOW()
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email = 'vv9250400@gmail.com'
);

-- Verificar se atualizou
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.points,
  p.role,
  p.subscription_plan,
  p.updated_at
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

-- Se ainda não funcionar, vamos criar do zero
-- (só execute se o UPDATE acima não retornar nenhuma linha)
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
AND NOT EXISTS (
  SELECT 1 FROM profiles WHERE user_id = u.id
);

-- Verificar resultado final
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.points,
  p.role,
  p.subscription_plan,
  CASE 
    WHEN p.points = 70000 THEN '✅ Pontos OK'
    ELSE '❌ Pontos: ' || p.points
  END as status_pontos,
  CASE 
    WHEN p.role = 'admin' THEN '✅ Role OK'
    ELSE '❌ Role: ' || COALESCE(p.role, 'NULL')
  END as status_role,
  CASE 
    WHEN p.subscription_plan = 'diamond' THEN '✅ Plano OK'
    ELSE '❌ Plano: ' || COALESCE(p.subscription_plan, 'NULL')
  END as status_plano
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

