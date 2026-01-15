-- Atualizar funções para criar notificações quando adicionarem pontos
-- Isso permite que as notificações apareçam em tempo real

-- Função para adicionar pontos ao receber curtida
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

-- Função para adicionar pontos ao criar post
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

-- Função para adicionar pontos ao comentar
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

-- Função para adicionar pontos ao enviar mensagem no chat
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

-- Atualizar trigger de comentários para usar a nova função
-- Primeiro remover o trigger antigo que só atualizava contador
DROP TRIGGER IF EXISTS on_comment_change ON public.comments;
DROP TRIGGER IF EXISTS trigger_add_points_comment ON public.comments;

-- Criar novo trigger que adiciona pontos e cria notificação
CREATE TRIGGER on_comment_change
  AFTER INSERT ON public.comments
  FOR EACH ROW 
  EXECUTE FUNCTION public.add_points_for_comment();

-- Trigger separado para DELETE (só atualiza contador, não remove pontos)
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

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS on_comment_delete ON public.comments;

CREATE TRIGGER on_comment_delete
  AFTER DELETE ON public.comments
  FOR EACH ROW 
  EXECUTE FUNCTION public.update_post_comments_count_on_delete();

-- Verificar se as funções foram atualizadas
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'update_post_likes_count',
    'add_points_for_post',
    'add_points_for_comment',
    'add_points_for_chat'
  )
ORDER BY routine_name;

