-- Adicionar campo role na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'support', 'admin'));

-- Adicionar campo is_support_post na tabela posts
ALTER TABLE public.posts 
ADD COLUMN IF NOT EXISTS is_support_post BOOLEAN DEFAULT false;

-- Adicionar campo is_banned na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT false;

-- Criar tabela de chat de suporte
CREATE TABLE IF NOT EXISTS public.support_chat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  support_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  is_from_support BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Políticas para suporte
CREATE POLICY "Support can view all posts" ON public.posts FOR SELECT 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
    OR true
  );

CREATE POLICY "Support can delete any post" ON public.posts FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

CREATE POLICY "Support can delete any comment" ON public.comments FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

CREATE POLICY "Support can delete any chat message" ON public.chat_messages FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

CREATE POLICY "Support can view all profiles" ON public.profiles FOR SELECT 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
    OR auth.uid() = user_id
  );

CREATE POLICY "Support can update any profile" ON public.profiles FOR UPDATE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

-- Políticas para chat de suporte
CREATE POLICY "Users can view own support chat" ON public.support_chat FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

CREATE POLICY "Users can create support chat messages" ON public.support_chat FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Support can create support chat messages" ON public.support_chat FOR INSERT 
  WITH CHECK (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
  );

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_posts_is_support ON public.posts(is_support_post);
CREATE INDEX IF NOT EXISTS idx_support_chat_user ON public.support_chat(user_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_support_user ON public.support_chat(support_user_id);

