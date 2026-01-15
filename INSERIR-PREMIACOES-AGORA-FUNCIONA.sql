-- ============================================
-- INSERIR PREMIAÇÕES - VAI FUNCIONAR
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- 1. CRIAR TABELA
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

-- 2. DESABILITAR RLS
ALTER TABLE public.rewards DISABLE ROW LEVEL SECURITY;

-- 3. DELETAR TUDO
DELETE FROM public.rewards;

-- 4. INSERIR OS 4 PRÊMIOS COM IMAGENS
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url) VALUES
  ('Pix Misterioso', 'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!', 2500, 999, true, 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop'),
  ('Um Dia de Anúncios', 'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!', 5000, 50, true, 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop'),
  ('Viagem Tudo Pago', 'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.', 75000, 5, true, 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop'),
  ('iPhone Novo', 'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.', 50000, 3, true, 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400&h=300&fit=crop');

-- 5. NÃO HABILITAR RLS - DEIXAR DESABILITADO

-- 6. VERIFICAR SE INSERIU
SELECT 
  COUNT(*) as total_premios,
  COUNT(CASE WHEN image_url IS NOT NULL THEN 1 END) as com_imagem,
  COUNT(CASE WHEN is_active = true THEN 1 END) as ativos
FROM public.rewards;

-- 7. MOSTRAR TODOS OS PRÊMIOS
SELECT 
  id,
  name,
  points_cost,
  is_active,
  image_url,
  stock
FROM public.rewards
ORDER BY points_cost;

