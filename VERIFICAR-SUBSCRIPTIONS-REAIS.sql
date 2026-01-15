-- ============================================
-- VERIFICAR SUBSCRIPTIONS REAIS (BYPASS RLS)
-- Execute este script no Supabase SQL Editor
-- ============================================

-- IMPORTANTE: Este script usa SECURITY DEFINER para bypassar RLS
-- e verificar quantas subscriptions realmente existem no banco

-- 1. Verificar se a tabela existe
SELECT 
  '1. Tabela existe?' as verificação,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_subscriptions'
  ) as resultado;

-- 2. Contar subscriptions SEM RLS (usando função SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.count_push_subscriptions()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM public.push_subscriptions);
END;
$$;

-- 3. Ver total REAL de subscriptions (bypassando RLS)
SELECT 
  '2. Total REAL de subscriptions (bypassando RLS):' as info,
  public.count_push_subscriptions() as total;

-- 4. Ver subscriptions detalhadas (bypassando RLS)
CREATE OR REPLACE FUNCTION public.get_push_subscriptions()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  endpoint_preview TEXT,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ps.id,
    ps.user_id,
    LEFT(ps.endpoint, 60) as endpoint_preview,
    ps.created_at
  FROM public.push_subscriptions ps
  ORDER BY ps.created_at DESC;
END;
$$;

-- 5. Listar subscriptions (bypassando RLS)
SELECT 
  '3. Subscriptions encontradas:' as info,
  id,
  user_id,
  endpoint_preview,
  created_at
FROM public.get_push_subscriptions();

-- 6. Verificar políticas RLS
SELECT 
  '4. Políticas RLS:' as info,
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
ORDER BY policyname;

-- 7. Verificar se service_role tem política
SELECT 
  '5. Service role tem política?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND policyname = 'Service role can read all subscriptions'
    AND 'service_role' = ANY(roles)
  ) as resultado;

-- 8. Verificar se admin tem política
SELECT 
  '6. Admin tem política?' as verificação,
  EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND policyname = 'Admins can view all subscriptions'
  ) as resultado;

-- ============================================
-- RESUMO
-- ============================================
SELECT 
  '=== RESUMO ===' as resumo,
  public.count_push_subscriptions() as total_subscriptions_real,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'push_subscriptions') as total_politicas_rls,
  (SELECT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'push_subscriptions'
    AND 'service_role' = ANY(roles)
  )) as service_role_policy_exists;

