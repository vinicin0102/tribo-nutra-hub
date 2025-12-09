-- ============================================
-- CRIAR FUNÇÃO RPC PARA ENVIAR ÁUDIO
-- ============================================
-- Esta função bypassa o cache do schema
-- Execute este script no Supabase SQL Editor
-- ============================================

-- Primeiro, garantir que as colunas existem
DO $$ 
BEGIN
  -- Adicionar audio_url se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE public.chat_messages ADD COLUMN audio_url TEXT;
  END IF;
  
  -- Adicionar audio_duration se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'audio_duration'
  ) THEN
    ALTER TABLE public.chat_messages ADD COLUMN audio_duration INTEGER;
  END IF;
  
  -- Adicionar image_url se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'chat_messages' 
    AND column_name = 'image_url'
  ) THEN
    ALTER TABLE public.chat_messages ADD COLUMN image_url TEXT;
  END IF;
END $$;

-- Criar função RPC para enviar mensagem com áudio
-- Esta função usa SECURITY DEFINER para bypass do cache
CREATE OR REPLACE FUNCTION public.send_chat_message_with_audio(
  p_user_id UUID,
  p_content TEXT,
  p_audio_url TEXT DEFAULT NULL,
  p_audio_duration INTEGER DEFAULT NULL,
  p_image_url TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_message_id UUID;
BEGIN
  -- Inserir mensagem
  INSERT INTO public.chat_messages (
    user_id,
    content,
    audio_url,
    audio_duration,
    image_url,
    created_at
  )
  VALUES (
    p_user_id,
    p_content,
    p_audio_url,
    p_audio_duration,
    p_image_url,
    NOW()
  )
  RETURNING id INTO v_message_id;
  
  RETURN v_message_id;
END;
$$;

-- Dar permissão para usuários autenticados usarem a função
GRANT EXECUTE ON FUNCTION public.send_chat_message_with_audio TO authenticated;

-- Verificar se a função foi criada
SELECT 
  '✅ Função criada:' as status,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND routine_name = 'send_chat_message_with_audio';

-- Verificar se as colunas existem
SELECT 
  '✅ Colunas verificadas:' as status,
  column_name, 
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
  AND column_name IN ('audio_url', 'audio_duration', 'image_url')
ORDER BY column_name;

