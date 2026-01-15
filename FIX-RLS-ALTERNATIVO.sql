-- =====================================================
-- FIX RLS ALTERNATIVO - Versão Mais Simples
-- =====================================================
-- Se o FIX-RLS-DEFINITIVO.sql não funcionou, tente este
-- =====================================================

-- PASSO 1: Dropar TODAS as policies de UPDATE (sem exceção)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'profiles' 
    AND cmd = 'UPDATE'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON profiles', r.policyname);
    RAISE NOTICE 'Dropped policy: %', r.policyname;
  END LOOP;
END $$;

-- PASSO 2: Recriar policy para usuários atualizarem seu próprio perfil
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- PASSO 3: Criar policy para admin (versão mais direta - sem subqueries complexas)
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se o email do usuário logado é admin@gmail.com
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'vv9250400@gmail.com'
  OR
  -- Verificar se o role do perfil do usuário logado é admin
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
)
WITH CHECK (
  -- Mesma verificação para WITH CHECK
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'vv9250400@gmail.com'
  OR
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
);

-- PASSO 4: Verificar se foram criadas
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

-- PASSO 5: Verificar se você é admin
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

