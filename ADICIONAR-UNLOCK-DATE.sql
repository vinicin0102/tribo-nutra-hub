-- =====================================================
-- ADICIONAR COLUNA unlock_date NA TABELA modules
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- Isso permite definir uma data fixa de lançamento para módulos
-- =====================================================

-- 1. Adicionar coluna unlock_date na tabela modules
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_date TIMESTAMPTZ DEFAULT NULL;

-- 2. Comentário para documentação
COMMENT ON COLUMN modules.unlock_date IS 'Data fixa de lançamento do módulo. Se NULL, o módulo está disponível imediatamente. Se definido, o módulo só será liberado na data especificada.';

-- 3. Atualizar o schema cache do PostgREST
SELECT pg_notify('pgrst', 'reload schema');

-- 4. Verificar se a coluna foi criada corretamente
SELECT 
  column_name, 
  data_type, 
  column_default,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'modules'
  AND column_name = 'unlock_date';

-- =====================================================
-- RESULTADO ESPERADO:
-- | column_name  | data_type                | column_default | is_nullable |
-- |--------------|-------------------------|----------------|-------------|
-- | unlock_date  | timestamp with time zone | NULL           | YES         |
-- =====================================================

-- =====================================================
-- APÓS EXECUTAR ESTE SCRIPT:
-- 1. Recarregue a página do admin
-- 2. Agora você poderá definir datas de lançamento para módulos
-- =====================================================
