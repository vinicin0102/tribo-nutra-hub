-- ============================================
-- DIAGNOSTICAR POR QUE SUBSCRIPTIONS NÃO SALVAM
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Verificar estrutura da tabela
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'push_subscriptions'
ORDER BY ordinal_position;

-- 2. Verificar constraints UNIQUE
SELECT
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.push_subscriptions'::regclass
AND contype IN ('u', 'p'); -- u = unique, p = primary key

-- 3. Verificar se a constraint (user_id, endpoint) existe
SELECT 
  'Constraint (user_id, endpoint) existe?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.push_subscriptions'::regclass
    AND contype = 'u'
    AND pg_get_constraintdef(oid) LIKE '%user_id%'
    AND pg_get_constraintdef(oid) LIKE '%endpoint%'
  ) as resultado;

-- 4. Verificar políticas RLS para INSERT
SELECT 
  'Políticas RLS para INSERT:' as info,
  policyname,
  roles,
  cmd,
  with_check
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
AND cmd = 'INSERT';

-- 5. Verificar se usuários podem inserir suas próprias subscriptions
SELECT 
  'Usuários podem inserir?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND cmd = 'INSERT'
    AND (with_check LIKE '%auth.uid()%' OR with_check LIKE '%user_id%')
  ) as resultado;

-- 6. Testar INSERT manual (simular o que o frontend faz)
-- NOTA: Isso vai falhar se não houver um usuário autenticado, mas mostra a estrutura esperada
DO $$
DECLARE
  test_user_id UUID := '00000000-0000-0000-0000-000000000000'::UUID; -- UUID de teste
  test_endpoint TEXT := 'https://fcm.googleapis.com/fcm/send/test-endpoint';
  test_p256dh TEXT := 'test_p256dh_key_base64_encoded';
  test_auth TEXT := 'test_auth_key_base64_encoded';
BEGIN
  -- Tentar inserir (vai falhar por causa do UUID inválido, mas mostra a estrutura)
  RAISE NOTICE 'Estrutura esperada para INSERT:';
  RAISE NOTICE '  user_id: UUID';
  RAISE NOTICE '  endpoint: TEXT (NOT NULL)';
  RAISE NOTICE '  p256dh: TEXT (NOT NULL)';
  RAISE NOTICE '  auth: TEXT (NOT NULL)';
  RAISE NOTICE '  user_agent: TEXT (opcional)';
  RAISE NOTICE '  updated_at: TIMESTAMP (opcional)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Erro ao testar estrutura: %', SQLERRM;
END $$;

-- 7. Verificar se há índices
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename = 'push_subscriptions';

-- ============================================
-- RESUMO
-- ============================================
SELECT 
  '=== RESUMO ===' as resumo,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'push_subscriptions') as total_colunas,
  (SELECT COUNT(*) FROM pg_constraint WHERE conrelid = 'public.push_subscriptions'::regclass AND contype = 'u') as total_unique_constraints,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'push_subscriptions' AND cmd = 'INSERT') as total_insert_policies,
  (SELECT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.push_subscriptions'::regclass
    AND contype = 'u'
    AND pg_get_constraintdef(oid) LIKE '%user_id%'
    AND pg_get_constraintdef(oid) LIKE '%endpoint%'
  )) as unique_constraint_exists;

