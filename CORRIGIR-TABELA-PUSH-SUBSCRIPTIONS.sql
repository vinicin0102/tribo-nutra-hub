-- ============================================
-- CORRIGIR TABELA push_subscriptions
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Garantir que a tabela existe com a estrutura correta
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  endpoint TEXT NOT NULL,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Adicionar constraint UNIQUE se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.push_subscriptions'::regclass
    AND contype = 'u'
    AND pg_get_constraintdef(oid) LIKE '%user_id%'
    AND pg_get_constraintdef(oid) LIKE '%endpoint%'
  ) THEN
    ALTER TABLE public.push_subscriptions
    ADD CONSTRAINT push_subscriptions_user_endpoint_unique 
    UNIQUE (user_id, endpoint);
    
    RAISE NOTICE '✅ Constraint UNIQUE (user_id, endpoint) criada';
  ELSE
    RAISE NOTICE '✅ Constraint UNIQUE (user_id, endpoint) já existe';
  END IF;
END $$;

-- 3. Habilitar RLS
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

-- 4. Remover políticas antigas de INSERT se existirem
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON public.push_subscriptions;

-- 5. Criar política para usuários inserirem suas próprias subscriptions
CREATE POLICY "Users can insert own subscriptions"
ON public.push_subscriptions 
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 6. Criar política para usuários atualizarem suas próprias subscriptions
DROP POLICY IF EXISTS "Users can update own subscriptions" ON public.push_subscriptions;
CREATE POLICY "Users can update own subscriptions"
ON public.push_subscriptions 
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 7. Verificar se service_role pode ler (para Edge Function)
DROP POLICY IF EXISTS "Service role can read all subscriptions" ON public.push_subscriptions;
CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);

-- 8. Verificar se service_role pode inserir (caso necessário)
DROP POLICY IF EXISTS "Service role can insert subscriptions" ON public.push_subscriptions;
CREATE POLICY "Service role can insert subscriptions"
ON public.push_subscriptions 
FOR INSERT
TO service_role
WITH CHECK (true);

-- 9. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_user_id 
ON public.push_subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_push_subscriptions_endpoint 
ON public.push_subscriptions(endpoint);

-- 10. Verificar estrutura final
SELECT 
  '✅ Tabela corrigida!' as status,
  (SELECT COUNT(*) FROM pg_constraint 
   WHERE conrelid = 'public.push_subscriptions'::regclass 
   AND contype = 'u') as unique_constraints,
  (SELECT COUNT(*) FROM pg_policies 
   WHERE tablename = 'push_subscriptions' 
   AND cmd = 'INSERT') as insert_policies,
  (SELECT COUNT(*) FROM pg_policies 
   WHERE tablename = 'push_subscriptions' 
   AND 'service_role' = ANY(roles)) as service_role_policies;

