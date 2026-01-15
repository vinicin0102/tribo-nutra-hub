-- Políticas para admin deletar qualquer post
CREATE POLICY "Admin can delete any post"
ON public.posts
FOR DELETE
TO authenticated
USING (is_admin());

-- Políticas para admin deletar qualquer mensagem do chat
CREATE POLICY "Admin can delete any chat message"
ON public.chat_messages
FOR DELETE
TO authenticated
USING (is_admin());

-- Políticas para admin deletar qualquer comentário
CREATE POLICY "Admin can delete any comment"
ON public.comments
FOR DELETE
TO authenticated
USING (is_admin());