-- ============================================
-- CORREÇÃO DE POLÍTICAS RLS - RECURSÃO INFINITA
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- Este script corrige o erro de recursão infinita nas políticas

-- 1. Criar função helper para verificar se é suporte (evita recursão)
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

-- 2. Remover políticas problemáticas
DROP POLICY IF EXISTS "Support can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Support can update any profile" ON public.profiles;
DROP POLICY IF EXISTS "Support can view all posts" ON public.posts;
DROP POLICY IF EXISTS "Support can delete any post" ON public.posts;
DROP POLICY IF EXISTS "Support can delete any comment" ON public.comments;
DROP POLICY IF EXISTS "Support can delete any chat message" ON public.chat_messages;

-- 3. Recriar políticas usando a função helper (sem recursão)
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

-- 4. Atualizar políticas do support_chat
DROP POLICY IF EXISTS "Users can view own support chat" ON public.support_chat;
DROP POLICY IF EXISTS "Users can create support chat messages" ON public.support_chat;
DROP POLICY IF EXISTS "Support can create support chat messages" ON public.support_chat;

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

-- 5. Verificar se as políticas foram criadas corretamente
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename IN ('profiles', 'posts', 'comments', 'chat_messages', 'support_chat')
ORDER BY tablename, policyname;

-- Mensagem de sucesso
DO $$
BEGIN
  RAISE NOTICE '✅ Políticas RLS corrigidas com sucesso!';
  RAISE NOTICE 'A recursão infinita foi resolvida usando função SECURITY DEFINER.';
END $$;

