-- ============================================
-- EXECUTE ESTE SCRIPT COMPLETO NO SUPABASE
-- ============================================
-- 1. Vá em SQL Editor
-- 2. Cole TODO este código
-- 3. Clique em RUN
-- ============================================

-- Passo 1: Remover colunas se existirem (limpar)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN audio_url;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN audio_duration;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'image_url'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN image_url;
  END IF;
END $$;

-- Passo 2: Adicionar colunas novamente
ALTER TABLE public.chat_messages 
ADD COLUMN audio_url TEXT;

ALTER TABLE public.chat_messages 
ADD COLUMN audio_duration INTEGER;

ALTER TABLE public.chat_messages 
ADD COLUMN image_url TEXT;

-- Passo 3: Verificar se foram criadas
SELECT 
  '✅ Colunas criadas com sucesso!' as status,
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

-- Passo 4: Aguardar 30 segundos antes de testar no app

