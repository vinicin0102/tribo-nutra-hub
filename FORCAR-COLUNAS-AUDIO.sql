-- ============================================
-- SCRIPT DEFINITIVO - FORÇAR CRIAÇÃO DAS COLUNAS
-- ============================================
-- Execute este script COMPLETO no Supabase SQL Editor
-- ============================================

-- Passo 1: Remover colunas se existirem (forçar limpeza)
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN audio_url CASCADE;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN audio_duration CASCADE;
  END IF;
  
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'image_url'
  ) THEN
    ALTER TABLE public.chat_messages DROP COLUMN image_url CASCADE;
  END IF;
END $$;

-- Passo 2: Criar colunas novamente
ALTER TABLE public.chat_messages 
ADD COLUMN audio_url TEXT;

ALTER TABLE public.chat_messages 
ADD COLUMN audio_duration INTEGER;

ALTER TABLE public.chat_messages 
ADD COLUMN image_url TEXT;

-- Passo 3: Verificar criação
SELECT 
  '✅ Colunas criadas:' as status,
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

-- Passo 4: IMPORTANTE - Aguardar 1-2 minutos após executar
-- O cache do PostgREST precisa atualizar

