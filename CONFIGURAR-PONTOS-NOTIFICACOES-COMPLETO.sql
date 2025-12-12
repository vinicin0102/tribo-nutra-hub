-- ============================================
-- CONFIGURAR PONTOS E NOTIFICAÇÕES - SQL COMPLETO
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- Este script configura tudo de uma vez
-- ============================================

-- 1. HABILITAR REALTIME PARA PROFILES
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;

-- 2. HABILITAR REALTIME PARA NOTIFICATIONS
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- 3. ATUALIZAR FUNÇÃO PARA ADICIONAR PONTOS AO RECEBER CURTIDA
CREATE OR REPLACE FUNCTION public.update_post_likes_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_post_owner_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Atualizar contador de curtidas
    UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
    
    -- Obter o dono do post
    SELECT user_id INTO v_post_owner_id FROM public.posts WHERE id = NEW.post_id;
    
    -- Adicionar pontos ao dono do post
    UPDATE public.profiles SET points = points + 1 WHERE user_id = v_post_owner_id;
    
    -- Criar notificação para o dono do post
    INSERT INTO public.notifications (user_id, type, title, message, related_post_id, related_user_id)
    VALUES (
      v_post_owner_id,
      'points',
      'Pontos Ganhos!',
      '+1 ponto por receber uma curtida!',
      NEW.post_id,
      NEW.user_id
    );
    
  ELSIF TG_OP = 'DELETE' THEN
    -- Atualizar contador de curtidas
    UPDATE public.posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
    
    -- Remover pontos do dono do post
    UPDATE public.profiles SET points = points - 1 WHERE user_id = (SELECT user_id FROM public.posts WHERE id = OLD.post_id);
  END IF;
  RETURN NULL;
END;
$$;

-- 4. ATUALIZAR FUNÇÃO PARA ADICIONAR PONTOS AO CRIAR POST
CREATE OR REPLACE FUNCTION public.add_points_for_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Adicionar pontos
  UPDATE public.profiles SET points = points + 5 WHERE user_id = NEW.user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message, related_post_id)
  VALUES (
    NEW.user_id,
    'points',
    'Pontos Ganhos!',
    '+5 pontos por criar uma publicação!',
    NEW.id
  );
  
  RETURN NEW;
END;
$$;

-- 5. CRIAR FUNÇÃO PARA ADICIONAR PONTOS AO COMENTAR
CREATE OR REPLACE FUNCTION public.add_points_for_comment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Atualizar contador de comentários
  UPDATE public.posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  
  -- Adicionar pontos ao autor do comentário
  UPDATE public.profiles SET points = points + 1 WHERE user_id = NEW.user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message, related_post_id)
  VALUES (
    NEW.user_id,
    'points',
    'Pontos Ganhos!',
    '+1 ponto por comentar!',
    NEW.post_id
  );
  
  RETURN NEW;
END;
$$;

-- 6. ATUALIZAR FUNÇÃO PARA ADICIONAR PONTOS NO CHAT
CREATE OR REPLACE FUNCTION public.add_points_for_chat()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Adicionar pontos
  UPDATE public.profiles SET points = points + 1 WHERE user_id = NEW.user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    NEW.user_id,
    'points',
    'Pontos Ganhos!',
    '+1 ponto por participar do chat!'
  );
  
  RETURN NEW;
END;
$$;

-- 7. REMOVER TRIGGERS ANTIGOS
DROP TRIGGER IF EXISTS on_comment_change ON public.comments;
DROP TRIGGER IF EXISTS trigger_add_points_comment ON public.comments;
DROP TRIGGER IF EXISTS on_comment_delete ON public.comments;

-- 8. CRIAR TRIGGER PARA COMENTÁRIOS (INSERT)
CREATE TRIGGER on_comment_change
  AFTER INSERT ON public.comments
  FOR EACH ROW 
  EXECUTE FUNCTION public.add_points_for_comment();

-- 9. CRIAR FUNÇÃO PARA DELETE DE COMENTÁRIOS (só atualiza contador)
CREATE OR REPLACE FUNCTION public.update_post_comments_count_on_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  UPDATE public.posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
  RETURN NULL;
END;
$$;

-- 10. CRIAR TRIGGER PARA DELETE DE COMENTÁRIOS
CREATE TRIGGER on_comment_delete
  AFTER DELETE ON public.comments
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_post_comments_count_on_delete();

-- 11. VERIFICAR SE TUDO FOI CRIADO CORRETAMENTE
SELECT 
  'Realtime habilitado para profiles' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' AND tablename = 'profiles'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado
UNION ALL
SELECT 
  'Realtime habilitado para notifications' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado
UNION ALL
SELECT 
  'Função update_post_likes_count' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'update_post_likes_count'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado
UNION ALL
SELECT 
  'Função add_points_for_post' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'add_points_for_post'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado
UNION ALL
SELECT 
  'Função add_points_for_comment' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'add_points_for_comment'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado
UNION ALL
SELECT 
  'Função add_points_for_chat' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'add_points_for_chat'
    ) THEN '✅ OK'
    ELSE '❌ FALHOU'
  END as resultado;

-- ============================================
-- FIM DO SCRIPT
-- ============================================
-- Se todos os resultados mostrarem ✅ OK, está tudo configurado!
-- ============================================

