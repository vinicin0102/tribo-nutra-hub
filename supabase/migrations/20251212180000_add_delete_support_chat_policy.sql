-- Adicionar política RLS para permitir que admins deletem mensagens de support_chat
DROP POLICY IF EXISTS "Support can delete support chat messages" ON public.support_chat;

CREATE POLICY "Support can delete support chat messages" ON public.support_chat FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
    OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND email = 'admin@gmail.com')
  );

