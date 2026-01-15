-- Adicionar coluna stock à tabela rewards
ALTER TABLE public.rewards ADD COLUMN IF NOT EXISTS stock INTEGER DEFAULT NULL;