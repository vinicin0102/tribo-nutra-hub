-- Adicionar colunas de áudio e imagem à tabela chat_messages
-- Este script adiciona suporte para mensagens de áudio e imagem no chat da comunidade

-- Adicionar coluna audio_url se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE public.chat_messages 
    ADD COLUMN audio_url TEXT;
  END IF;
END $$;

-- Adicionar coluna audio_duration se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE public.chat_messages 
    ADD COLUMN audio_duration INTEGER;
  END IF;
END $$;

-- Adicionar coluna image_url se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'image_url'
  ) THEN
    ALTER TABLE public.chat_messages 
    ADD COLUMN image_url TEXT;
  END IF;
END $$;

-- Verificar se as colunas foram adicionadas
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

