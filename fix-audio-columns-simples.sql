-- Script SIMPLES e DIRETO para adicionar colunas de áudio
-- Execute este script no SQL Editor do Supabase

-- Adicionar coluna audio_url
ALTER TABLE public.chat_messages 
ADD COLUMN audio_url TEXT;

-- Adicionar coluna audio_duration
ALTER TABLE public.chat_messages 
ADD COLUMN audio_duration INTEGER;

-- Adicionar coluna image_url (opcional, mas útil)
ALTER TABLE public.chat_messages 
ADD COLUMN image_url TEXT;

-- Verificar se as colunas foram criadas
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

