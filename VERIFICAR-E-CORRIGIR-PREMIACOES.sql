-- ============================================
-- VERIFICAR E CORRIGIR PREMIAÇÕES
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 
  'Tabelas' as tipo,
  table_name as nome,
  CASE WHEN table_name IN ('rewards', 'redemptions') THEN '✅ EXISTE' ELSE '❌ NÃO EXISTE' END as status
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name IN ('rewards', 'redemptions');

-- 2. VERIFICAR RLS
SELECT 
  'RLS' as tipo,
  tablename as nome,
  CASE WHEN rowsecurity THEN '✅ HABILITADO' ELSE '❌ DESABILITADO' END as status
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename IN ('rewards', 'redemptions');

-- 3. VERIFICAR POLÍTICAS EXISTENTES
SELECT 
  'Políticas' as tipo,
  tablename as tabela,
  policyname as politica,
  cmd as comando
FROM pg_policies
WHERE schemaname = 'public' 
  AND tablename IN ('rewards', 'redemptions')
ORDER BY tablename, policyname;

-- 4. VERIFICAR DADOS
SELECT 
  'Dados' as tipo,
  'rewards' as tabela,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN is_active = true THEN 1 END) as ativos,
  COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem
FROM public.rewards;

-- 5. LISTAR PRÊMIOS
SELECT 
  id,
  name,
  points_cost,
  is_active,
  image_url,
  CASE 
    WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM IMAGEM'
    ELSE '✅ COM IMAGEM'
  END as status_imagem
FROM public.rewards
ORDER BY points_cost;

-- 6. REMOVER TODAS AS POLÍTICAS
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'rewards' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.rewards';
    END LOOP;
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'redemptions' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.redemptions';
    END LOOP;
END $$;

-- 7. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE IF EXISTS public.rewards DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.redemptions DISABLE ROW LEVEL SECURITY;

-- 8. GARANTIR QUE OS PRÊMIOS ESTÃO INSERIDOS
DELETE FROM public.rewards;

INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=800&h=600&fit=crop&q=80')
ON CONFLICT DO NOTHING;

INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=600&fit=crop&q=80')
ON CONFLICT DO NOTHING;

INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&h=600&fit=crop&q=80')
ON CONFLICT DO NOTHING;

INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800&h=600&fit=crop&q=80')
ON CONFLICT DO NOTHING;

-- 9. HABILITAR RLS
ALTER TABLE IF EXISTS public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.redemptions ENABLE ROW LEVEL SECURITY;

-- 10. CRIAR POLÍTICA SUPER PERMISSIVA PARA REWARDS (TODOS PODEM VER)
CREATE POLICY "Public can view all active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- 11. CRIAR POLÍTICAS PARA REDEMPTIONS
CREATE POLICY "Users can view own redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Support can view all redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (email = 'admin@gmail.com' OR role IN ('support', 'admin'))
  )
);

CREATE POLICY "Users can create redemptions"
ON public.redemptions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Support can update redemptions"
ON public.redemptions FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND (email = 'admin@gmail.com' OR role IN ('support', 'admin'))
  )
);

-- 12. VERIFICAÇÃO FINAL
SELECT 
  '✅ VERIFICAÇÃO FINAL' as status,
  (SELECT COUNT(*) FROM public.rewards) as total_premios,
  (SELECT COUNT(*) FROM public.rewards WHERE is_active = true) as premios_ativos,
  (SELECT COUNT(*) FROM public.rewards WHERE image_url IS NOT NULL AND image_url != '') as premios_com_imagem,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'rewards' AND schemaname = 'public') as politicas_rewards,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'redemptions' AND schemaname = 'public') as politicas_redemptions;

-- 13. TESTE DE ACESSO PÚBLICO
SELECT 
  'TESTE DE ACESSO' as teste,
  id,
  name,
  points_cost,
  image_url IS NOT NULL as tem_imagem
FROM public.rewards
WHERE is_active = true
ORDER BY points_cost;

