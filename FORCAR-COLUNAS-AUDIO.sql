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

-- Passo 4: Forçar atualização do schema cache do PostgREST
-- Isso força o PostgREST a recarregar o schema
NOTIFY pgrst, 'reload schema';

-- Passo 5: Verificar novamente após alguns segundos
-- Execute este SELECT novamente em 30 segundos para confirmar
SELECT 
  '✅ Verificação final:' as status,
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

-- IMPORTANTE: Após executar este script:
-- 1. Aguarde 2-3 minutos
-- 2. Feche o app completamente
-- 3. Limpe o cache do navegador (Ctrl+Shift+R)
-- 4. Abra o app novamente
-- 5. Teste enviar um áudio

