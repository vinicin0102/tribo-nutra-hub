-- =====================================================
-- CRIAR POLICY PARA ADMIN ATUALIZAR PROFILES (SIMPLES)
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Dropar policy existente se houver
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;

-- Criar policy para admin atualizar qualquer perfil
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Verificar se foi criada
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

