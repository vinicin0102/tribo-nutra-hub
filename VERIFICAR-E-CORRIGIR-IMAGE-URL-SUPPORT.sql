-- =====================================================
-- 🔍 VERIFICAR E CORRIGIR COLUNA image_url NO support_chat
-- =====================================================
-- Este script verifica se a coluna image_url existe
-- e a cria se necessário
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. Verificar se a coluna image_url existe
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'support_chat'
  AND column_name = 'image_url';

-- 2. Adicionar coluna se não existir
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 3. Adicionar colunas de áudio se não existirem
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS audio_url TEXT,
ADD COLUMN IF NOT EXISTS audio_duration INTEGER;

-- 4. Adicionar comentários
COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_url IS 'URL do áudio enviado na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_duration IS 'Duração do áudio em segundos';

-- 5. Verificar estrutura completa da tabela
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'support_chat'
ORDER BY ordinal_position;

-- 6. Verificar políticas RLS para INSERT
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'support_chat'
  AND cmd = 'INSERT';

