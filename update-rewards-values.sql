-- =====================================================
-- ATUALIZAR VALORES DOS PRÊMIOS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Atualizar valores dos prêmios existentes
UPDATE public.rewards
SET 
  points_cost = 2500,
  updated_at = NOW()
WHERE name = 'Pix Misterioso';

UPDATE public.rewards
SET 
  points_cost = 5000,
  updated_at = NOW()
WHERE name = 'Um Dia de Anúncios';

UPDATE public.rewards
SET 
  points_cost = 75000,
  updated_at = NOW()
WHERE name = 'Viagem Tudo Pago';

UPDATE public.rewards
SET 
  points_cost = 50000,
  updated_at = NOW()
WHERE name = 'iPhone Novo';

-- Se o prêmio não existir, criar
INSERT INTO public.rewards (name, description, points_cost, stock, image_url, created_at)
SELECT 
  'Pix Misterioso',
  'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!',
  2500,
  999,
  NULL,
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM public.rewards WHERE name = 'Pix Misterioso');

INSERT INTO public.rewards (name, description, points_cost, stock, image_url, created_at)
SELECT 
  'Um Dia de Anúncios',
  'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!',
  5000,
  50,
  NULL,
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM public.rewards WHERE name = 'Um Dia de Anúncios');

INSERT INTO public.rewards (name, description, points_cost, stock, image_url, created_at)
SELECT 
  'Viagem Tudo Pago',
  'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.',
  75000,
  5,
  NULL,
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM public.rewards WHERE name = 'Viagem Tudo Pago');

INSERT INTO public.rewards (name, description, points_cost, stock, image_url, created_at)
SELECT 
  'iPhone Novo',
  'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.',
  50000,
  3,
  NULL,
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM public.rewards WHERE name = 'iPhone Novo');

-- Verificar os prêmios atualizados
SELECT 
  id,
  name,
  description,
  points_cost,
  stock,
  created_at
FROM public.rewards 
ORDER BY points_cost ASC;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Valores atualizados:
-- - PIX Misterioso: 2.500 pontos
-- - Um Dia de Anúncios: 5.000 pontos
-- - Viagem Tudo Pago: 75.000 pontos
-- - iPhone Novo: 50.000 pontos
-- =====================================================

