-- =====================================================
-- FIX RLS DEFINITIVO - Atualizar Pontos Admin
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Ver todas as policies de UPDATE atuais
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- PASSO 2: Dropar TODAS as policies de UPDATE
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;
DROP POLICY IF EXISTS "Support can update profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update profiles" ON profiles;

-- PASSO 3: Recriar policy para usuários atualizarem seu próprio perfil
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- PASSO 4: Criar policy para admin (versão mais simples e direta)
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar email diretamente
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  -- Verificar role admin
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  -- Mesma verificação para WITH CHECK
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- PASSO 5: Verificar se foram criadas corretamente
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
ORDER BY policyname;

-- PASSO 6: Testar se você é admin
SELECT 
  u.id as user_id,
  u.email,
  p.role,
  p.points
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora você tem 2 policies:
-- 1. "Users can update own profile" - Usuários atualizam seu próprio perfil
-- 2. "Admins can update any profile" - Admins atualizam qualquer perfil
-- =====================================================

