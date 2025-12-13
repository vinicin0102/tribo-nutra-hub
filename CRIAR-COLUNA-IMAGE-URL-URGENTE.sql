-- =====================================================
-- 🚨 URGENTE: CRIAR COLUNA image_url NO support_chat
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- Este script cria a coluna image_url se ela não existir
-- =====================================================

-- 1. Verificar se a coluna existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'support_chat' 
      AND column_name = 'image_url'
  ) THEN
    -- Criar a coluna
    ALTER TABLE public.support_chat 
    ADD COLUMN image_url TEXT;
    
    RAISE NOTICE '✅ Coluna image_url criada com sucesso!';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna image_url já existe.';
  END IF;
END $$;

-- 2. Adicionar colunas de áudio se não existirem
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'support_chat' 
      AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE public.support_chat 
    ADD COLUMN audio_url TEXT;
    
    RAISE NOTICE '✅ Coluna audio_url criada com sucesso!';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna audio_url já existe.';
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'support_chat' 
      AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE public.support_chat 
    ADD COLUMN audio_duration INTEGER;
    
    RAISE NOTICE '✅ Coluna audio_duration criada com sucesso!';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna audio_duration já existe.';
  END IF;
END $$;

-- 3. Adicionar comentários
COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_url IS 'URL do áudio enviado na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_duration IS 'Duração do áudio em segundos';

-- 4. Verificar estrutura final
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'support_chat'
  AND column_name IN ('image_url', 'audio_url', 'audio_duration')
ORDER BY column_name;

-- 5. Verificar políticas RLS para INSERT (importante para permitir envio de imagens)
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'support_chat'
  AND cmd = 'INSERT';

