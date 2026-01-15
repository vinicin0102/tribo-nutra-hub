-- Adicionar colunas para mídia (imagem e áudio) na tabela support_chat
-- Execute este script no SQL Editor do Supabase

-- Verificar se a tabela existe
DO $$ 
BEGIN
  -- Adicionar coluna para URL de imagem
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_chat' AND column_name = 'image_url'
  ) THEN
    ALTER TABLE support_chat ADD COLUMN image_url TEXT;
  END IF;

  -- Adicionar coluna para URL de áudio
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_chat' AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE support_chat ADD COLUMN audio_url TEXT;
  END IF;

  -- Adicionar coluna para duração do áudio
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'support_chat' AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE support_chat ADD COLUMN audio_duration INTEGER;
  END IF;
END $$;

-- Verificar as colunas adicionadas
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'support_chat' 
AND column_name IN ('image_url', 'audio_url', 'audio_duration', 'message')
ORDER BY ordinal_position;
