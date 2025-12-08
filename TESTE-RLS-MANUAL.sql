-- =====================================================
-- TESTE MANUAL DE RLS - Verificar se funciona
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Ver seu user_id e email atual
SELECT 
  id as user_id,
  email,
  raw_user_meta_data
FROM auth.users
WHERE email = 'admin@gmail.com' OR email = 'vv9250400@gmail.com';

-- 2. Ver seu perfil e role
SELECT 
  user_id,
  username,
  email,
  role,
  points
FROM profiles
WHERE user_id IN (
  SELECT id FROM auth.users 
  WHERE email = 'admin@gmail.com' OR email = 'vv9250400@gmail.com'
);

-- 3. Pegar o user_id de um usuário de teste (ex: vini)
SELECT 
  user_id,
  username,
  points
FROM profiles
WHERE username = 'vini' OR username LIKE '%vini%'
LIMIT 1;

-- 4. Testar UPDATE manual (substitua USER_ID_VINI pelo user_id do vini acima)
-- Descomente e execute:
/*
UPDATE profiles
SET points = 12345
WHERE user_id = 'USER_ID_VINI_AQUI'
RETURNING user_id, username, points;
*/

-- 5. Verificar todas as policies de UPDATE
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- 6. Verificar se RLS está habilitado
SELECT 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'profiles';

