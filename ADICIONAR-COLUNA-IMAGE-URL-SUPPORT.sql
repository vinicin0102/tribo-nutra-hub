-- =====================================================
-- EXECUTAR ESTE SCRIPT NO SUPABASE SQL EDITOR
-- =====================================================
-- Este script adiciona a coluna image_url na tabela support_chat
-- para permitir o envio de imagens no chat de suporte
-- Copie TODO o conteúdo abaixo e cole no Supabase SQL Editor, depois clique em RUN
-- =====================================================

-- Adicionar coluna image_url na tabela support_chat
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Comentário explicativo
COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';

-- =====================================================
-- APÓS EXECUTAR, O ENVIO DE IMAGENS NO CHAT DE SUPORTE
-- DEVE FUNCIONAR CORRETAMENTE
-- =====================================================
