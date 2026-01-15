-- =====================================================
-- CRIAR POLICY PARA ADMIN ATUALIZAR PROFILES (VERSÃO 2 - MAIS SIMPLES)
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Verificar policies existentes de UPDATE
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- 2. Dropar TODAS as policies de UPDATE existentes (vamos recriar)
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;
DROP POLICY IF EXISTS "Support can update profiles" ON profiles;

-- 3. Criar policy para usuários atualizarem seu próprio perfil
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Criar policy para admin atualizar qualquer perfil (versão simplificada)
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se o email é admin@gmail.com
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  -- Verificar se tem role admin
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
);

-- 5. Verificar se foram criadas
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
ORDER BY policyname;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora você tem 2 policies:
-- 1. Usuários podem atualizar seu próprio perfil
-- 2. Admins podem atualizar qualquer perfil
-- =====================================================

