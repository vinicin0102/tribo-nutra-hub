-- SOLUÇÃO DEFINITIVA PARA ÁUDIO NO CHAT
-- Execute este script COMPLETO no SQL Editor do Supabase

-- 1. Remover colunas se existirem (para evitar conflitos)
ALTER TABLE public.chat_messages 
DROP COLUMN IF EXISTS audio_url;

ALTER TABLE public.chat_messages 
DROP COLUMN IF EXISTS audio_duration;

ALTER TABLE public.chat_messages 
DROP COLUMN IF EXISTS image_url;

-- 2. Adicionar colunas novamente
ALTER TABLE public.chat_messages 
ADD COLUMN audio_url TEXT;

ALTER TABLE public.chat_messages 
ADD COLUMN audio_duration INTEGER;

ALTER TABLE public.chat_messages 
ADD COLUMN image_url TEXT;

-- 3. Verificar se foram criadas
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

-- 4. Forçar atualização do schema cache
NOTIFY pgrst, 'reload schema';

