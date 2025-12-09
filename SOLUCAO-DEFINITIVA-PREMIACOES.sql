-- ============================================
-- SOLUÇÃO DEFINITIVA - PREMIAÇÕES
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. CRIAR TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  points_cost INTEGER NOT NULL,
  stock INTEGER DEFAULT -1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. REMOVER TODAS AS POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Everyone can view active rewards" ON public.rewards;
DROP POLICY IF EXISTS "Public can view rewards" ON public.rewards;
DROP POLICY IF EXISTS "Authenticated can view rewards" ON public.rewards;
DROP POLICY IF EXISTS "Allow public reads" ON public.rewards;

-- 3. DESABILITAR RLS TEMPORARIAMENTE PARA INSERIR
ALTER TABLE public.rewards DISABLE ROW LEVEL SECURITY;

-- 4. DELETAR TUDO E RECRIAR
TRUNCATE TABLE public.rewards CASCADE;

-- 5. INSERIR PRÊMIOS
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url, created_at) VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop', NOW()),
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop', NOW()),
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop', NOW()),
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400&h=300&fit=crop', NOW());

-- 6. HABILITAR RLS NOVAMENTE
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICA SUPER SIMPLES - PERMITE TUDO
CREATE POLICY "Allow all reads"
ON public.rewards FOR SELECT
TO public
USING (true);

-- 8. VERIFICAR
SELECT 
  '✅ PRÊMIOS INSERIDOS!' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN is_active = true THEN 1 END) as ativos,
  COUNT(CASE WHEN image_url IS NOT NULL THEN 1 END) as com_imagem
FROM public.rewards;

-- 9. LISTAR TODOS OS PRÊMIOS
SELECT 
  id,
  name,
  points_cost,
  is_active,
  image_url IS NOT NULL as tem_imagem
FROM public.rewards
ORDER BY points_cost;

