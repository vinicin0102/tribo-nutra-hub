-- ============================================
-- VERIFICAR SE OS PRÊMIOS ESTÃO NO BANCO
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. CONTAR PRÊMIOS
SELECT 
  'Total de prêmios' as info,
  COUNT(*) as valor
FROM public.rewards;

-- 2. LISTAR TODOS OS PRÊMIOS COM DETALHES
SELECT 
  id,
  name,
  points_cost,
  is_active,
  image_url,
  CASE 
    WHEN image_url IS NULL THEN '❌ SEM IMAGEM'
    WHEN image_url = '' THEN '❌ URL VAZIA'
    ELSE '✅ COM IMAGEM'
  END as status_imagem,
  LENGTH(image_url) as tamanho_url,
  stock
FROM public.rewards
ORDER BY points_cost;

-- 3. VERIFICAR RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'rewards';

-- 4. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE tablename = 'rewards' AND schemaname = 'public';

