-- Adicionar cover_url na tabela modules
ALTER TABLE modules ADD COLUMN IF NOT EXISTS cover_url text;

-- Adicionar cover_url e is_locked na tabela lessons
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS cover_url text;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_locked boolean DEFAULT false;