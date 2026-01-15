-- ============================================
-- MIGRAÇÃO DO SISTEMA DE SUPORTE
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- Este script adiciona todas as funcionalidades de suporte

-- 1. Adicionar campo role na tabela profiles (se não existir)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'role'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('user', 'support', 'admin'));
    RAISE NOTICE 'Coluna role adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna role já existe na tabela profiles';
  END IF;
END $$;

-- 2. Adicionar campo is_support_post na tabela posts (se não existir)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'posts' AND column_name = 'is_support_post'
  ) THEN
    ALTER TABLE public.posts 
    ADD COLUMN is_support_post BOOLEAN DEFAULT false;
    RAISE NOTICE 'Coluna is_support_post adicionada à tabela posts';
  ELSE
    RAISE NOTICE 'Coluna is_support_post já existe na tabela posts';
  END IF;
END $$;

-- 3. Adicionar campo is_banned na tabela profiles (se não existir)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'is_banned'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN is_banned BOOLEAN DEFAULT false;
    RAISE NOTICE 'Coluna is_banned adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna is_banned já existe na tabela profiles';
  END IF;
END $$;

-- 4. Criar tabela de chat de suporte (se não existir)
CREATE TABLE IF NOT EXISTS public.support_chat (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  support_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  is_from_support BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. Criar função helper para verificar se é suporte (evita recursão infinita)
CREATE OR REPLACE FUNCTION public.is_support_user(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = user_uuid
    AND role IN ('support', 'admin')
  );
END;
$$;

-- 6. Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Support can view all posts" ON public.posts;
DROP POLICY IF EXISTS "Support can delete any post" ON public.posts;
DROP POLICY IF EXISTS "Support can delete any comment" ON public.comments;
DROP POLICY IF EXISTS "Support can delete any chat message" ON public.chat_messages;
DROP POLICY IF EXISTS "Support can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Support can update any profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own support chat" ON public.support_chat;
DROP POLICY IF EXISTS "Users can create support chat messages" ON public.support_chat;
DROP POLICY IF EXISTS "Support can create support chat messages" ON public.support_chat;

-- 7. Criar políticas para suporte usando a função helper (sem recursão)
CREATE POLICY "Support can view all posts" ON public.posts FOR SELECT 
  USING (
    public.is_support_user(auth.uid())
    OR true
  );

CREATE POLICY "Support can delete any post" ON public.posts FOR DELETE 
  USING (
    public.is_support_user(auth.uid())
  );

CREATE POLICY "Support can delete any comment" ON public.comments FOR DELETE 
  USING (
    public.is_support_user(auth.uid())
  );

CREATE POLICY "Support can delete any chat message" ON public.chat_messages FOR DELETE 
  USING (
    public.is_support_user(auth.uid())
  );

CREATE POLICY "Support can view all profiles" ON public.profiles FOR SELECT 
  USING (
    auth.uid() = user_id
    OR public.is_support_user(auth.uid())
  );

CREATE POLICY "Support can update any profile" ON public.profiles FOR UPDATE 
  USING (
    auth.uid() = user_id
    OR public.is_support_user(auth.uid())
  );

-- 8. Políticas para chat de suporte usando a função helper
CREATE POLICY "Users can view own support chat" ON public.support_chat FOR SELECT 
  USING (
    auth.uid() = user_id 
    OR public.is_support_user(auth.uid())
  );

CREATE POLICY "Users can create support chat messages" ON public.support_chat FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Support can create support chat messages" ON public.support_chat FOR INSERT 
  WITH CHECK (
    public.is_support_user(auth.uid())
  );

-- 9. Criar índices para performance (se não existirem)
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_posts_is_support ON public.posts(is_support_post);
CREATE INDEX IF NOT EXISTS idx_support_chat_user ON public.support_chat(user_id);
CREATE INDEX IF NOT EXISTS idx_support_chat_support_user ON public.support_chat(support_user_id);

-- 10. Verificar se tudo foi criado corretamente
SELECT 
  'Migração concluída!' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'role'
    ) THEN '✓ Coluna role em profiles'
    ELSE '✗ Coluna role em profiles'
  END as check_role,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'posts' AND column_name = 'is_support_post'
    ) THEN '✓ Coluna is_support_post em posts'
    ELSE '✗ Coluna is_support_post em posts'
  END as check_support_post,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'is_banned'
    ) THEN '✓ Coluna is_banned em profiles'
    ELSE '✗ Coluna is_banned em profiles'
  END as check_banned,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_name = 'support_chat'
    ) THEN '✓ Tabela support_chat'
    ELSE '✗ Tabela support_chat'
  END as check_support_chat,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_name = 'is_support_user'
    ) THEN '✓ Função is_support_user'
    ELSE '✗ Função is_support_user'
  END as check_function;
