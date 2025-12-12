-- Script para limpar Feed e Chat antes do lançamento
-- Este script remove todos os posts, comentários, likes e mensagens de chat
-- ATENÇÃO: Execute este script apenas quando estiver pronto para limpar todos os dados!

-- Desabilitar triggers temporariamente para evitar atualizações de contadores e pontos
ALTER TABLE public.posts DISABLE TRIGGER on_post_created;
ALTER TABLE public.comments DISABLE TRIGGER on_comment_change;
ALTER TABLE public.likes DISABLE TRIGGER on_like_change;
ALTER TABLE public.chat_messages DISABLE TRIGGER on_chat_message;

-- Limpar dados relacionados (ordem importante devido às foreign keys)
-- Primeiro deletar likes e comments que referenciam posts
DELETE FROM public.likes;
DELETE FROM public.comments;

-- Depois deletar os posts
DELETE FROM public.posts;

-- Deletar mensagens de chat
DELETE FROM public.chat_messages;

-- Reabilitar triggers
ALTER TABLE public.posts ENABLE TRIGGER on_post_created;
ALTER TABLE public.comments ENABLE TRIGGER on_comment_change;
ALTER TABLE public.likes ENABLE TRIGGER on_like_change;
ALTER TABLE public.chat_messages ENABLE TRIGGER on_chat_message;

-- Nota: As imagens/vídeos no storage do Supabase não são deletadas automaticamente
-- Se necessário, limpe manualmente o bucket 'posts' no Supabase Storage através do dashboard

