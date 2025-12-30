-- =====================================================
-- ADICIONAR COLUNA unlock_date PARA LIBERAÇÃO POR DATA
-- =====================================================

-- 1. Adicionar coluna unlock_date na tabela modules
ALTER TABLE modules
ADD COLUMN IF NOT EXISTS unlock_date TIMESTAMP WITH TIME ZONE;

-- 2. Adicionar coluna unlock_date na tabela lessons
ALTER TABLE lessons
ADD COLUMN IF NOT EXISTS unlock_date TIMESTAMP WITH TIME ZONE;

-- 3. Adicionar coluna is_locked na tabela lessons (se não existir)
ALTER TABLE lessons
ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;

-- 4. Verificar resultado
SELECT 'Colunas adicionadas com sucesso!' as status;
