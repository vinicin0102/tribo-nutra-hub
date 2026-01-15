-- ============================================
-- ATUALIZAR SCHEMA CACHE DO SUPABASE
-- ============================================
-- Este SQL força o PostgREST a atualizar o cache do schema
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Forçar atualização do schema cache
NOTIFY pgrst, 'reload schema';

-- Verificar estrutura da tabela chat_messages
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- Verificar se existem colunas de áudio (não devem existir)
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
        AND table_name = 'chat_messages' 
        AND column_name IN ('audio_url', 'audio_duration')
    ) THEN '❌ Colunas de áudio ainda existem'
    ELSE '✅ Tabela está correta (sem colunas de áudio)'
  END as status;

