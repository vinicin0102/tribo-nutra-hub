-- Remover pontuação de interação no chat
-- Esta migration remove a funcionalidade de adicionar pontos quando usuários enviam mensagens no chat

-- Remover o trigger que adiciona pontos no chat
DROP TRIGGER IF EXISTS on_chat_message ON public.chat_messages;

-- Opcional: Remover a função (pode ser útil manter para referência futura)
-- DROP FUNCTION IF EXISTS public.add_points_for_chat();

-- Comentário explicativo
COMMENT ON FUNCTION public.add_points_for_chat() IS 
'Função desabilitada: Pontos não são mais adicionados para mensagens de chat (removido em 20251212)';

