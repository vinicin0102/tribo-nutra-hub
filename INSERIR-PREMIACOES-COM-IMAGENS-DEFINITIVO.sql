-- ============================================
-- INSERIR PREMIAÇÕES COM IMAGENS - DEFINITIVO
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

-- 2. REMOVER TODAS AS POLÍTICAS
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'rewards' AND schemaname = 'public') LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON public.rewards';
    END LOOP;
END $$;

-- 3. DESABILITAR RLS
ALTER TABLE public.rewards DISABLE ROW LEVEL SECURITY;

-- 4. DELETAR TUDO
DELETE FROM public.rewards;

-- 5. INSERIR PRÊMIOS COM IMAGENS (URLs do Unsplash)
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=800&h=600&fit=crop&q=80'),
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=600&fit=crop&q=80'),
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&h=600&fit=crop&q=80'),
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800&h=600&fit=crop&q=80');

-- 6. HABILITAR RLS
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICA PÚBLICA
CREATE POLICY "Everyone can view active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- 8. VERIFICAR
SELECT 
  '✅ PRÊMIOS INSERIDOS!' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem
FROM public.rewards;

-- 9. MOSTRAR TODOS
SELECT 
  name,
  points_cost,
  CASE 
    WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM IMAGEM'
    ELSE '✅ ' || LEFT(image_url, 60) || '...'
  END as imagem_status
FROM public.rewards
ORDER BY points_cost;

