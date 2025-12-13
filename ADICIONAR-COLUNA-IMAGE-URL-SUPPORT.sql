-- =====================================================
-- EXECUTAR ESTE SCRIPT NO SUPABASE SQL EDITOR
-- =====================================================
-- Este script adiciona a coluna image_url na tabela support_chat
-- para permitir o envio de imagens no chat de suporte
-- =====================================================

-- Adicionar coluna image_url na tabela support_chat
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';

-- =====================================================
-- APÓS EXECUTAR, O ENVIO DE IMAGENS NO CHAT DE SUPORTE
-- DEVE FUNCIONAR CORRETAMENTE
-- =====================================================

