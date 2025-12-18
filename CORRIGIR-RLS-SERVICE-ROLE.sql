-- CORRIGIR RLS PARA PERMITIR SERVICE_ROLE ACESSAR SUBSCRIPTIONS
-- Execute este script no Supabase SQL Editor

-- Remover política existente se houver (para permitir re-execução)
DROP POLICY IF EXISTS "Service role can read all subscriptions" ON public.push_subscriptions;

-- Adicionar política para service_role poder ler todas as subscriptions
-- Isso é ESSENCIAL para a Edge Function funcionar
CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);

-- Verificar se a política foi criada
SELECT 
  'Política criada:' as status,
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
AND policyname = 'Service role can read all subscriptions';

-- Testar contagem (deve retornar o número correto agora)
SELECT 
  'Total de subscriptions:' as info,
  COUNT(*) as total 
FROM public.push_subscriptions;

-- Ver subscriptions (deve funcionar agora)
SELECT 
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  created_at
FROM public.push_subscriptions
ORDER BY created_at DESC
LIMIT 5;

