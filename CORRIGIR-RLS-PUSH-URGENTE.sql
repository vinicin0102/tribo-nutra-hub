-- ============================================
-- CORREÇÃO URGENTE: RLS PARA SERVICE_ROLE
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Verificar se RLS está ativo
SELECT 
  'RLS está ativo?' as verificação,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'push_subscriptions';

-- 2. Ver todas as políticas existentes
SELECT 
  'Políticas existentes:' as info,
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
ORDER BY policyname;

-- 3. REMOVER política antiga se existir (para permitir re-execução)
DROP POLICY IF EXISTS "Service role can read all subscriptions" ON public.push_subscriptions;

-- 4. CRIAR política para service_role poder ler TODAS as subscriptions
-- IMPORTANTE: Isso é ESSENCIAL para a Edge Function funcionar
CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);

-- 5. Verificar se a política foi criada
SELECT 
  '✅ Política criada!' as status,
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
AND policyname = 'Service role can read all subscriptions';

-- 6. Verificar quantas subscriptions existem
SELECT 
  'Total de subscriptions no banco:' as info,
  COUNT(*) as total 
FROM public.push_subscriptions;

-- 7. Ver detalhes das subscriptions
SELECT 
  id,
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  LENGTH(p256dh) as p256dh_size,
  LENGTH(auth) as auth_size,
  created_at,
  updated_at
FROM public.push_subscriptions
ORDER BY created_at DESC;

-- ============================================
-- NOTA IMPORTANTE
-- ============================================
-- Se após executar este script a Edge Function ainda retornar 0,
-- verifique:
-- 1. Se o SUPABASE_SERVICE_ROLE_KEY está configurado corretamente na Edge Function
-- 2. Se a Edge Function está usando createClient com service_role key
-- 3. Os logs da Edge Function para ver o erro exato

