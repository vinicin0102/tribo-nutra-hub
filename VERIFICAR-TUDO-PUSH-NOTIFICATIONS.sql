-- ============================================
-- VERIFICAÇÃO COMPLETA DE PUSH NOTIFICATIONS
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. VERIFICAR SE A TABELA EXISTE
SELECT 
  '1. Tabela push_subscriptions existe?' as verificação,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_subscriptions'
  ) as resultado;

-- 2. CONTAR SUBSCRIPTIONS
SELECT 
  '2. Total de subscriptions' as info,
  COUNT(*) as total 
FROM public.push_subscriptions;

-- 3. VER SUBSCRIPTIONS DETALHADAS (últimas 5)
SELECT 
  '3. Últimas 5 subscriptions' as info,
  id,
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  LENGTH(p256dh) as p256dh_size,
  LENGTH(auth) as auth_size,
  created_at,
  updated_at
FROM public.push_subscriptions
ORDER BY updated_at DESC
LIMIT 5;

-- 4. VERIFICAR RLS
SELECT 
  '4. RLS está ativo?' as verificação,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'push_subscriptions';

-- 5. VER TODAS AS POLÍTICAS RLS
SELECT 
  '5. Políticas RLS existentes' as info,
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
ORDER BY policyname;

-- 6. VERIFICAR SE SERVICE_ROLE TEM ACESSO
SELECT 
  '6. Política para service_role existe?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND policyname = 'Service role can read all subscriptions'
    AND 'service_role' = ANY(roles)
  ) as resultado;

-- 7. VERIFICAR TABELA DE LOGS
SELECT 
  '7. Tabela push_notifications_log existe?' as verificação,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_notifications_log'
  ) as resultado;

-- 8. CONTAR LOGS DE NOTIFICAÇÕES
-- NOTA: Se der erro "relation does not exist", execute primeiro CRIAR-TABELA-PUSH-NOTIFICATIONS-LOG.sql
SELECT 
  '8. Total de logs de notificações' as info,
  COUNT(*) as total 
FROM public.push_notifications_log;

-- 9. VER ÚLTIMOS 5 LOGS
-- NOTA: Se der erro "relation does not exist", execute primeiro CRIAR-TABELA-PUSH-NOTIFICATIONS-LOG.sql
SELECT 
  '9. Últimas 5 notificações enviadas' as info,
  id,
  title,
  body,
  recipients_count,
  success_count,
  failed_count,
  created_at
FROM public.push_notifications_log
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- RESUMO FINAL
-- ============================================
SELECT 
  '=== RESUMO ===' as resumo,
  (SELECT COUNT(*) FROM public.push_subscriptions) as total_subscriptions,
  CASE 
    WHEN EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'push_notifications_log'
    ) THEN (SELECT COUNT(*) FROM public.push_notifications_log)
    ELSE 0
  END as total_logs,
  (SELECT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND policyname = 'Service role can read all subscriptions'
  )) as service_role_policy_exists,
  (SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_notifications_log'
  )) as log_table_exists;

