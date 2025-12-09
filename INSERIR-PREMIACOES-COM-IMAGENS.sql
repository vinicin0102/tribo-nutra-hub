-- ============================================
-- INSERIR PREMIAÇÕES COM IMAGENS
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Garantir que a tabela existe
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

-- Remover constraint UNIQUE se existir e recriar
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'rewards_name_key' 
      AND conrelid = 'public.rewards'::regclass
  ) THEN
    ALTER TABLE public.rewards DROP CONSTRAINT rewards_name_key;
  END IF;
END $$;

ALTER TABLE public.rewards ADD CONSTRAINT rewards_name_key UNIQUE (name);

-- Deletar prêmios antigos
DELETE FROM public.rewards;

-- Inserir prêmios COM IMAGENS (usando placeholders - você pode substituir por URLs reais)
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url, created_at)
VALUES
  (
    'Pix Misterioso',
    'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!',
    2500,
    999,
    true,
    'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=300&fit=crop',
    NOW()
  ),
  (
    'Um Dia de Anúncios',
    'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!',
    5000,
    50,
    true,
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop',
    NOW()
  ),
  (
    'Viagem Tudo Pago',
    'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.',
    75000,
    5,
    true,
    'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop',
    NOW()
  ),
  (
    'iPhone Novo',
    'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.',
    50000,
    3,
    true,
    'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400&h=300&fit=crop',
    NOW()
  );

-- Garantir RLS habilitado
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;

-- Remover TODAS as políticas antigas
DROP POLICY IF EXISTS "Everyone can view active rewards" ON public.rewards;
DROP POLICY IF EXISTS "Public can view rewards" ON public.rewards;
DROP POLICY IF EXISTS "Authenticated can view rewards" ON public.rewards;
DROP POLICY IF EXISTS "Allow public reads" ON public.rewards;

-- Criar política SIMPLES: TODOS (público e autenticado) podem ver prêmios ativos
CREATE POLICY "Everyone can view active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- Verificar resultado
SELECT 
  '✅ Prêmios inseridos com imagens!' as status,
  id,
  name,
  points_cost,
  stock,
  is_active,
  image_url IS NOT NULL as tem_imagem
FROM public.rewards 
ORDER BY points_cost ASC;

-- Contar prêmios ativos
SELECT 
  'Total de prêmios ativos:' as info,
  COUNT(*) as total
FROM public.rewards
WHERE is_active = true;

