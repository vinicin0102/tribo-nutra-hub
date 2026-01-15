-- Corrigir RLS para permitir que Edge Function (service_role) acesse subscriptions

-- Adicionar política para service_role poder ler todas as subscriptions
-- Isso é necessário para a Edge Function enviar notificações

CREATE POLICY IF NOT EXISTS "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);

-- Verificar se a política foi criada
SELECT 
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
AND policyname = 'Service role can read all subscriptions';

-- Testar contagem (deve funcionar mesmo com RLS ativo)
SELECT COUNT(*) as total_subscriptions FROM public.push_subscriptions;


