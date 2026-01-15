-- =====================================================
-- SOLUÇÃO SIMPLES: Permitir Admin Atualizar Qualquer Plano
-- =====================================================
-- Este SQL cria uma policy RLS que permite admins atualizarem planos
-- SEM precisar de função RPC
-- =====================================================

-- 1. Verificar policies existentes de UPDATE
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- 2. Dropar policy antiga se existir
DROP POLICY IF EXISTS "Admins can update subscription plan" ON profiles;

-- 3. Criar policy específica para atualizar subscription_plan
CREATE POLICY "Admins can update subscription plan"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se é admin por email
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'vv9250400@gmail.com'
  )
  OR
  -- Verificar se é admin por role
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
  OR
  -- Permitir usuário atualizar seu próprio plano (caso necessário)
  auth.uid() = user_id
)
WITH CHECK (
  -- Mesma verificação
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'vv9250400@gmail.com'
  )
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
  OR
  auth.uid() = user_id
);

-- 4. Verificar se foi criada
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
AND policyname = 'Admins can update subscription plan';

-- =====================================================
-- PRONTO! Agora admins podem atualizar planos diretamente
-- =====================================================

