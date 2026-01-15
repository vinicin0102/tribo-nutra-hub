-- ============================================
-- VERIFICAR SE OS PRÊMIOS EXISTEM
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. Verificar se a tabela rewards existe
SELECT 
  '1. Tabela rewards:' as verificação,
  EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
      AND table_name = 'rewards'
  ) as existe;

-- 2. Verificar quantos prêmios existem
SELECT 
  '2. Total de prêmios:' as verificação,
  COUNT(*) as total
FROM public.rewards;

-- 3. Listar todos os prêmios
SELECT 
  '3. Prêmios cadastrados:' as verificação,
  id,
  name,
  points_cost,
  stock,
  is_active,
  created_at
FROM public.rewards 
ORDER BY points_cost ASC;

-- 4. Verificar políticas RLS
SELECT 
  '4. Políticas RLS:' as verificação,
  policyname,
  cmd as operação,
  roles::text as roles
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename = 'rewards'
ORDER BY policyname;

-- 5. Verificar se RLS está habilitado
SELECT 
  '5. RLS habilitado:' as verificação,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'rewards';

