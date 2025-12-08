-- =====================================================
-- CRIAR POLICY PARA ADMIN ATUALIZAR PROFILES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Dropar policy existente se houver (para evitar conflito)
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;

-- 2. Criar policy para admin atualizar qualquer perfil
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se é admin pelo email
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  -- Verificar se tem role admin no perfil
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  -- Mesma verificação para WITH CHECK
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- 3. Verificar se foi criada
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora admins podem atualizar qualquer perfil
-- =====================================================

