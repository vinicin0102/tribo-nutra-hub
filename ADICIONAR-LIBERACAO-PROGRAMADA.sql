-- =====================================================
-- ADICIONAR LIBERAÇÃO PROGRAMADA PARA AULAS
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- para adicionar a funcionalidade de liberação por tempo
-- em AULAS INDIVIDUAIS (além dos módulos)
-- =====================================================

-- 1. Adicionar coluna is_locked na tabela lessons (se não existir)
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;

-- 2. Adicionar coluna unlock_after_days na tabela lessons
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;

-- 3. Comentários para documentação
COMMENT ON COLUMN lessons.is_locked IS 'Se true, esta aula está bloqueada e requer plano Diamond ou desbloqueio por tempo';
COMMENT ON COLUMN lessons.unlock_after_days IS 'Número de dias após a assinatura Diamond para liberar esta aula. 0 = imediato.';

-- =====================================================
-- VERIFICAR: Garantir que a coluna unlock_after_days 
-- também existe na tabela modules
-- =====================================================
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;
COMMENT ON COLUMN modules.unlock_after_days IS 'Número de dias após a assinatura Diamond para liberar este módulo. 0 = imediato.';

-- 4. Verificar estrutura das tabelas
SELECT 
  'modules' as tabela,
  column_name, 
  data_type, 
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'modules'
  AND column_name IN ('is_locked', 'unlock_after_days')
UNION ALL
SELECT 
  'lessons' as tabela,
  column_name, 
  data_type, 
  column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'lessons'
  AND column_name IN ('is_locked', 'unlock_after_days')
ORDER BY tabela, column_name;

-- =====================================================
-- RESULTADO ESPERADO:
-- | tabela  | column_name       | data_type | column_default |
-- |---------|-------------------|-----------|----------------|
-- | lessons | is_locked         | boolean   | false          |
-- | lessons | unlock_after_days | integer   | 0              |
-- | modules | is_locked         | boolean   | false          |
-- | modules | unlock_after_days | integer   | 0              |
-- =====================================================
