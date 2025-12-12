-- Adicionar política RLS para permitir que admins deletem mensagens de support_chat
CREATE POLICY IF NOT EXISTS "Support can delete support chat messages" ON public.support_chat FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
    OR auth.uid() IN (SELECT id FROM auth.users WHERE email = 'admin@gmail.com')
  );

