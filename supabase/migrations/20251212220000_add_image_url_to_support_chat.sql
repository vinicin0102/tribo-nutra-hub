-- Adicionar coluna image_url na tabela support_chat para permitir envio de imagens
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';

