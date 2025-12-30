-- =====================================================
-- ADICIONAR COLUNA unlock_after_days NA TABELA modules
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- 1. Adicionar coluna unlock_after_days na tabela modules
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;

-- 2. Comentário para documentação
COMMENT ON COLUMN modules.unlock_after_days IS 'Número de dias após o primeiro login Diamond para liberar este módulo. 0 = disponível imediatamente.';

-- 3. Forçar reload do schema cache
NOTIFY pgrst, 'reload schema';
SELECT pg_notify('pgrst', 'reload schema');

-- 4. Verificar se a coluna foi criada
SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'modules' 
AND column_name = 'unlock_after_days';

-- =====================================================
-- RESULTADO ESPERADO:
-- | column_name       | data_type | column_default |
-- |-------------------|-----------|----------------|
-- | unlock_after_days | integer   | 0              |
-- =====================================================
