-- Verificar subscriptions de push notifications

-- 1. Contar total de subscriptions
SELECT COUNT(*) as total_subscriptions FROM push_subscriptions;

-- 2. Ver subscriptions recentes
SELECT 
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  LENGTH(p256dh) as p256dh_length,
  LENGTH(auth) as auth_length,
  user_agent,
  created_at,
  updated_at
FROM push_subscriptions
ORDER BY updated_at DESC
LIMIT 10;

-- 3. Verificar se há subscriptions com dados válidos
SELECT 
  COUNT(*) as subscriptions_validas,
  COUNT(CASE WHEN p256dh IS NOT NULL AND LENGTH(p256dh) > 0 THEN 1 END) as com_p256dh,
  COUNT(CASE WHEN auth IS NOT NULL AND LENGTH(auth) > 0 THEN 1 END) as com_auth,
  COUNT(CASE WHEN endpoint IS NOT NULL AND LENGTH(endpoint) > 0 THEN 1 END) as com_endpoint
FROM push_subscriptions;

-- 4. Ver usuários únicos com subscriptions
SELECT 
  COUNT(DISTINCT user_id) as usuarios_unicos
FROM push_subscriptions;

