-- Adicionar coluna stock à tabela rewards
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS stock INTEGER;

-- Comentário na coluna
COMMENT ON COLUMN public.rewards.stock IS 'Estoque do prêmio. NULL significa estoque ilimitado.';

