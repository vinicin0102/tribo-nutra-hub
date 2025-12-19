-- ============================================
-- SCRIPT PARA VERIFICAR CONFIGURAÇÃO ONESIGNAL
-- Execute este script no Supabase SQL Editor
-- ============================================

-- Verificar se a tabela push_subscriptions existe e tem dados do OneSignal
SELECT 
  '=== SUBSCRIPTIONS ONESIGNAL ===' as info,
  COUNT(*) as total_onesignal_subscriptions,
  COUNT(DISTINCT user_id) as usuarios_unicos
FROM public.push_subscriptions
WHERE endpoint LIKE 'onesignal:%';

-- Listar subscriptions do OneSignal
SELECT 
  user_id,
  endpoint,
  user_agent,
  updated_at
FROM public.push_subscriptions
WHERE endpoint LIKE 'onesignal:%'
ORDER BY updated_at DESC
LIMIT 10;

-- Verificar histórico de notificações enviadas
SELECT 
  '=== HISTÓRICO DE NOTIFICAÇÕES ===' as info,
  COUNT(*) as total_notificacoes,
  SUM(recipients_count) as total_destinatarios,
  SUM(success_count) as total_sucessos,
  SUM(failed_count) as total_falhas
FROM public.push_notifications_log;

-- Últimas notificações enviadas
SELECT 
  title,
  body,
  recipients_count,
  success_count,
  failed_count,
  created_at
FROM public.push_notifications_log
ORDER BY created_at DESC
LIMIT 5;

