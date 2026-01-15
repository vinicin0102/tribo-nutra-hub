-- Limpar todas as mensagens do chat da comunidade
-- Execute este script no SQL Editor do Supabase

-- Deletar todas as mensagens do chat
DELETE FROM chat_messages;

-- Verificar se foi limpo
SELECT COUNT(*) as total_mensagens FROM chat_messages;

-- Mensagem de confirmação
SELECT 'Chat da comunidade limpo com sucesso!' as status;

