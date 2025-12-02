-- Adicionar colunas para mídia (imagem e áudio) na tabela support_chat
-- Execute este script no SQL Editor do Supabase

-- Adicionar coluna para URL de imagem
ALTER TABLE support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Adicionar coluna para URL de áudio
ALTER TABLE support_chat 
ADD COLUMN IF NOT EXISTS audio_url TEXT;

-- Adicionar coluna para duração do áudio (em segundos)
ALTER TABLE support_chat 
ADD COLUMN IF NOT EXISTS audio_duration INTEGER;

-- Verificar as colunas adicionadas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'support_chat' 
AND column_name IN ('image_url', 'audio_url', 'audio_duration');

