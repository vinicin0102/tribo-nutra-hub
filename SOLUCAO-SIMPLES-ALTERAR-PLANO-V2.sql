-- =====================================================
-- SOLUÇÃO SIMPLES: Permitir Admin Atualizar Qualquer Plano
-- VERSÃO 2 - Mais Robusta
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Verificar policies existentes de UPDATE
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- 2. Dropar policy antiga se existir (sem erro se não existir)
DROP POLICY IF EXISTS "Admins can update subscription plan" ON profiles;

-- 3. Criar policy específica para atualizar subscription_plan
-- Esta policy permite que admins atualizem QUALQUER campo do perfil
CREATE POLICY "Admins can update subscription plan"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se é admin por email
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'vv9250400@gmail.com'
  OR
  -- Verificar se é admin por role
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
)
WITH CHECK (
  -- Mesma verificação
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'vv9250400@gmail.com'
  OR
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
);

-- 4. Verificar se foi criada
SELECT 
  '✅ Policy criada com sucesso!' as status,
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
AND policyname = 'Admins can update subscription plan';

-- 5. Verificar se você é admin
SELECT 
  'Verificação de Admin:' as info,
  u.email,
  p.role,
  CASE 
    WHEN u.email = 'admin@gmail.com' THEN '✅ É admin (email)'
    WHEN u.email = 'vv9250400@gmail.com' THEN '✅ É admin (email)'
    WHEN p.role = 'admin' THEN '✅ É admin (role)'
    ELSE '❌ NÃO é admin'
  END as status_admin
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';

-- =====================================================
-- PRONTO! Agora admins podem atualizar planos diretamente
-- =====================================================
-- Se você viu "✅ Policy criada com sucesso!" acima, está tudo certo!
-- =====================================================

