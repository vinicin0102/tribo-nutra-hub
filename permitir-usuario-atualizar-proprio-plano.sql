-- =====================================================
-- PERMITIR USUÁRIO ATUALIZAR SEU PRÓPRIO PLANO
-- =====================================================
-- Esta policy permite que o usuário atualize seu próprio subscription_plan
-- Necessário para liberar o plano imediatamente após pagamento
-- =====================================================

-- 1. Verificar policies existentes
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- 2. Dropar policy se já existir
DROP POLICY IF EXISTS "Users can update own subscription plan" ON profiles;

-- 3. Criar policy para usuário atualizar seu próprio plano
CREATE POLICY "Users can update own subscription plan"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Verificar se foi criada
SELECT 
  '✅ Policy criada!' as status,
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
AND policyname = 'Users can update own subscription plan';

-- =====================================================
-- PRONTO! Agora usuários podem atualizar seu próprio plano
-- =====================================================

