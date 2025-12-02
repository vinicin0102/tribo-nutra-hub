-- Adicionar colunas para mídia (áudio) na tabela chat_messages
-- Execute este script no SQL Editor do Supabase

DO $$ 
BEGIN
  -- Adicionar coluna para URL de áudio
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chat_messages' AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE chat_messages ADD COLUMN audio_url TEXT;
  END IF;

  -- Adicionar coluna para duração do áudio
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'chat_messages' AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE chat_messages ADD COLUMN audio_duration INTEGER;
  END IF;
END $$;

-- Verificar as colunas adicionadas
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'chat_messages' 
AND column_name IN ('audio_url', 'audio_duration', 'content')
ORDER BY ordinal_position;

