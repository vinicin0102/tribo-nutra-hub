-- Corrigir políticas RLS de redemptions para suporte
-- Execute este script no SQL Editor do Supabase

-- 1. Remover todas as políticas antigas
DROP POLICY IF EXISTS "Support can view all redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Support can update redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Users can view own redemptions" ON public.redemptions;
DROP POLICY IF EXISTS "Users can create redemptions" ON public.redemptions;

-- 2. Criar política para TODOS verem TODOS os resgates (temporário para debug)
CREATE POLICY "Everyone can view redemptions" 
ON public.redemptions 
FOR SELECT 
TO authenticated
USING (true);

-- 3. Criar política para TODOS atualizarem (temporário para debug)
CREATE POLICY "Everyone can update redemptions" 
ON public.redemptions 
FOR UPDATE 
TO authenticated
USING (true)
WITH CHECK (true);

-- 4. Manter política de INSERT apenas para o próprio usuário
CREATE POLICY "Users can create own redemptions" 
ON public.redemptions 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 5. Verificar políticas criadas
SELECT 
  tablename, 
  policyname, 
  cmd as operacao,
  roles
FROM pg_policies 
WHERE tablename = 'redemptions'
ORDER BY policyname;

-- 6. Testar se há resgates
SELECT COUNT(*) as total FROM redemptions;
SELECT id, user_id, reward_id, status, created_at 
FROM redemptions 
ORDER BY created_at DESC 
LIMIT 5;

