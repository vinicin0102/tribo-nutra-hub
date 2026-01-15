-- =====================================================
-- TESTAR UPDATE MANUAL (para verificar se funciona)
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Ver seu user_id atual
SELECT 
  id as user_id,
  email
FROM auth.users
WHERE email = 'admin@gmail.com' OR email = 'vv9250400@gmail.com';

-- 2. Verificar seu perfil
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

-- 3. Testar update manual (substitua USER_ID_AQUI pelo user_id de um usuário de teste)
-- Descomente e execute apenas se quiser testar:
/*
UPDATE profiles
SET points = 99999
WHERE user_id = 'USER_ID_AQUI'
RETURNING user_id, username, points;
*/

-- 4. Verificar policies de UPDATE
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

