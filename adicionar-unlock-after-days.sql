-- Adicionar coluna unlock_after_days na tabela modules
-- Valor 0 significa liberação imediata (comportamento atual)
-- Valor > 0 significa liberar após X dias da assinatura Diamond

ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;

-- Comentário para documentação
COMMENT ON COLUMN modules.unlock_after_days IS 'Número de dias após a assinatura Diamond para liberar este módulo. 0 = imediato.';
