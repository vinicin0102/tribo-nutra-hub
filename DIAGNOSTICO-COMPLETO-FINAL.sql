-- DIAGNÓSTICO COMPLETO - Execute este script no Supabase SQL Editor

-- 1. Verificar se a tabela existe
SELECT 
  'Tabela existe?' as verificação,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_subscriptions'
  ) as resultado;

-- 2. Contar subscriptions
SELECT 
  'Total de subscriptions' as info,
  COUNT(*) as total 
FROM public.push_subscriptions;

-- 3. Ver subscriptions detalhadas
SELECT 
  id,
  user_id,
  LEFT(endpoint, 80) as endpoint_preview,
  LENGTH(p256dh) as p256dh_size,
  LENGTH(auth) as auth_size,
  user_agent,
  created_at,
  updated_at
FROM public.push_subscriptions
ORDER BY updated_at DESC;

-- 4. Verificar RLS
SELECT 
  'RLS está ativo?' as verificação,
  rowsecurity as resultado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'push_subscriptions';

-- 5. Ver TODAS as políticas RLS
SELECT 
  policyname,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
ORDER BY policyname;

-- 6. Verificar se service_role tem acesso
SELECT 
  'Política para service_role existe?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND policyname = 'Service role can read all subscriptions'
    AND 'service_role' = ANY(roles)
  ) as resultado;

-- 7. Testar acesso direto (simular service_role)
-- Nota: Isso não funciona diretamente, mas mostra se há dados
SELECT COUNT(*) as total_com_rls_ativo
FROM public.push_subscriptions;

