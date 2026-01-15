-- Adicionar colunas para mídia no support_chat

-- Adicionar coluna para URL de imagem
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Adicionar coluna para URL de áudio
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS audio_url TEXT;

-- Adicionar coluna para duração do áudio
ALTER TABLE public.support_chat 
ADD COLUMN IF NOT EXISTS audio_duration INTEGER;

-- Adicionar comentários
COMMENT ON COLUMN public.support_chat.image_url IS 'URL da imagem enviada na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_url IS 'URL do áudio enviado na mensagem de suporte';
COMMENT ON COLUMN public.support_chat.audio_duration IS 'Duração do áudio em segundos';