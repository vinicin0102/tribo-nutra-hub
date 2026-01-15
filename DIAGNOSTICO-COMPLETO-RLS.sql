-- =====================================================
-- DIAGNÓSTICO COMPLETO - RLS Policy
-- =====================================================
-- Execute este SQL para diagnosticar o problema
-- =====================================================

-- 1. Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'profiles';

-- 2. Ver TODAS as policies de UPDATE na tabela profiles
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
ORDER BY policyname;

-- 3. Verificar se você é admin (verificar email e role)
SELECT 
  u.id as user_id,
  u.email,
  p.role,
  p.points,
  p.user_id as profile_user_id
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';

-- 4. Verificar qual é o seu auth.uid() atual
-- (Execute isso enquanto estiver logado no app)
SELECT 
  auth.uid() as current_user_id,
  auth.email() as current_user_email;

-- 5. Testar se a policy permite UPDATE (substitua USER_ID_AQUI pelo user_id de um usuário de teste)
-- ATENÇÃO: Execute isso apenas se você estiver logado como admin
-- Substitua 'USER_ID_AQUI' pelo user_id de um usuário que você quer testar
/*
UPDATE profiles
SET points = 99999
WHERE user_id = 'USER_ID_AQUI'
RETURNING user_id, username, points;
*/

-- 6. Verificar se existe alguma policy conflitante
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- =====================================================
-- RESULTADOS ESPERADOS:
-- =====================================================
-- 1. rls_enabled deve ser TRUE
-- 2. Deve haver 2 policies de UPDATE:
--    - "Users can update own profile"
--    - "Admins can update any profile"
-- 3. Seu email deve aparecer com role = 'admin'
-- 4. current_user_id deve ser o mesmo do seu perfil
-- =====================================================

