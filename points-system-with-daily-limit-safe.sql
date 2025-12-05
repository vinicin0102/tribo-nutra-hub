-- =====================================================
-- SISTEMA DE PONTOS COM LIMITE DIÁRIO E NOTIFICAÇÕES
-- VERSÃO SEGURA - NÃO CRIA TABELAS EXISTENTES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. CRIAR TABELA PARA RASTREAR PONTOS DIÁRIOS (se não existir)
CREATE TABLE IF NOT EXISTS public.daily_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  points_date DATE NOT NULL DEFAULT CURRENT_DATE,
  points_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, points_date)
);

-- 2. CRIAR ÍNDICES (se não existirem)
CREATE INDEX IF NOT EXISTS idx_daily_points_user_date ON public.daily_points(user_id, points_date);

-- 3. HABILITAR RLS (se não estiver habilitado)
ALTER TABLE public.daily_points ENABLE ROW LEVEL SECURITY;

-- 4. REMOVER POLÍTICAS ANTIGAS (se existirem)
DROP POLICY IF EXISTS "Users can view own daily points" ON public.daily_points;
DROP POLICY IF EXISTS "System can manage daily points" ON public.daily_points;

-- 5. CRIAR POLÍTICAS RLS
CREATE POLICY "Users can view own daily points" 
  ON public.daily_points FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "System can manage daily points" 
  ON public.daily_points FOR ALL 
  USING (true);

-- 6. FUNÇÃO: ADICIONAR PONTOS COM LIMITE DIÁRIO
CREATE OR REPLACE FUNCTION public.add_points_with_limit(
  p_user_id UUID,
  p_points INTEGER,
  p_action_type TEXT,
  p_message TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  v_daily_points INTEGER;
  v_daily_limit INTEGER := 100;
  v_points_to_add INTEGER;
  v_remaining_limit INTEGER;
  v_notification_id UUID;
BEGIN
  -- Verificar pontos ganhos hoje
  SELECT COALESCE(points_earned, 0) INTO v_daily_points
  FROM public.daily_points
  WHERE user_id = p_user_id AND points_date = CURRENT_DATE;
  
  -- Se não existe registro para hoje, criar
  IF v_daily_points IS NULL THEN
    INSERT INTO public.daily_points (user_id, points_date, points_earned)
    VALUES (p_user_id, CURRENT_DATE, 0)
    ON CONFLICT (user_id, points_date) DO NOTHING;
    v_daily_points := 0;
  END IF;
  
  -- Calcular quantos pontos podem ser adicionados
  v_remaining_limit := v_daily_limit - v_daily_points;
  
  IF v_remaining_limit <= 0 THEN
    -- Limite diário atingido
    RETURN jsonb_build_object(
      'success', false,
      'points_added', 0,
      'message', 'Limite diário de 100 pontos atingido!',
      'daily_points', v_daily_points,
      'remaining', 0
    );
  END IF;
  
  -- Adicionar pontos respeitando o limite
  v_points_to_add := LEAST(p_points, v_remaining_limit);
  
  -- Atualizar pontos diários
  UPDATE public.daily_points
  SET 
    points_earned = points_earned + v_points_to_add,
    updated_at = NOW()
  WHERE user_id = p_user_id AND points_date = CURRENT_DATE;
  
  -- Atualizar pontos totais do perfil
  UPDATE public.profiles
  SET points = COALESCE(points, 0) + v_points_to_add
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'points',
    'Pontos Ganhos!',
    COALESCE(p_message, '+' || v_points_to_add || ' pontos por ' || p_action_type)
  )
  RETURNING id INTO v_notification_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_added', v_points_to_add,
    'message', '+' || v_points_to_add || ' pontos!',
    'daily_points', v_daily_points + v_points_to_add,
    'remaining', v_daily_limit - (v_daily_points + v_points_to_add),
    'notification_id', v_notification_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO: ADICIONAR PONTOS PARA POST
CREATE OR REPLACE FUNCTION public.add_points_for_post()
RETURNS TRIGGER AS $$
DECLARE
  v_result JSONB;
BEGIN
  -- Adicionar 5 pontos por post
  v_result := public.add_points_with_limit(
    NEW.user_id,
    5,
    'publicação',
    '+5 pontos por publicar!'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO: ADICIONAR PONTOS PARA CURTIDA
CREATE OR REPLACE FUNCTION public.add_points_for_like()
RETURNS TRIGGER AS $$
DECLARE
  v_result JSONB;
BEGIN
  -- Adicionar 1 ponto para quem curtiu
  v_result := public.add_points_with_limit(
    NEW.user_id,
    1,
    'curtida',
    '+1 ponto por curtir!'
  );
  
  -- Atualizar contador de likes do post
  UPDATE public.posts 
  SET likes_count = COALESCE(likes_count, 0) + 1 
  WHERE id = NEW.post_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. FUNÇÃO: REMOVER PONTOS AO DESFAZER CURTIDA
CREATE OR REPLACE FUNCTION public.remove_points_for_unlike()
RETURNS TRIGGER AS $$
BEGIN
  -- Remover 1 ponto ao desfazer curtida
  UPDATE public.profiles
  SET points = GREATEST(0, COALESCE(points, 0) - 1)
  WHERE user_id = OLD.user_id;
  
  -- Atualizar contador de likes do post
  UPDATE public.posts 
  SET likes_count = GREATEST(0, COALESCE(likes_count, 0) - 1)
  WHERE id = OLD.post_id;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. FUNÇÃO: ADICIONAR PONTOS PARA COMENTÁRIO
CREATE OR REPLACE FUNCTION public.add_points_for_comment()
RETURNS TRIGGER AS $$
DECLARE
  v_result JSONB;
BEGIN
  -- Adicionar 1 ponto para quem comentou
  v_result := public.add_points_with_limit(
    NEW.user_id,
    1,
    'comentário',
    '+1 ponto por comentar!'
  );
  
  -- Atualizar contador de comentários do post
  UPDATE public.posts 
  SET comments_count = COALESCE(comments_count, 0) + 1 
  WHERE id = NEW.post_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. FUNÇÃO: REMOVER PONTOS AO DELETAR COMENTÁRIO
CREATE OR REPLACE FUNCTION public.remove_points_for_comment_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Remover 1 ponto ao deletar comentário
  UPDATE public.profiles
  SET points = GREATEST(0, COALESCE(points, 0) - 1)
  WHERE user_id = OLD.user_id;
  
  -- Atualizar contador de comentários do post
  UPDATE public.posts 
  SET comments_count = GREATEST(0, COALESCE(comments_count, 0) - 1)
  WHERE id = OLD.post_id;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. FUNÇÃO: ADICIONAR PONTOS PARA LOGIN DIÁRIO
CREATE OR REPLACE FUNCTION public.add_points_for_daily_login(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
BEGIN
  -- Adicionar 8 pontos por login diário
  v_result := public.add_points_with_limit(
    p_user_id,
    8,
    'login diário',
    '+8 pontos por login diário!'
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 13. REMOVER TRIGGERS ANTIGOS (se existirem)
DROP TRIGGER IF EXISTS trigger_add_points_post ON public.posts;
DROP TRIGGER IF EXISTS trigger_add_points_like ON public.likes;
DROP TRIGGER IF EXISTS trigger_remove_points_unlike ON public.likes;
DROP TRIGGER IF EXISTS trigger_add_points_comment ON public.comments;
DROP TRIGGER IF EXISTS trigger_remove_points_comment_delete ON public.comments;
DROP TRIGGER IF EXISTS on_post_created ON public.posts;
DROP TRIGGER IF EXISTS on_like_change ON public.likes;
DROP TRIGGER IF EXISTS on_comment_change ON public.comments;

-- 14. CRIAR NOVOS TRIGGERS
CREATE TRIGGER trigger_add_points_post
  AFTER INSERT ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_post();

CREATE TRIGGER trigger_add_points_like
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_like();

CREATE TRIGGER trigger_remove_points_unlike
  AFTER DELETE ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.remove_points_for_unlike();

CREATE TRIGGER trigger_add_points_comment
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_comment();

CREATE TRIGGER trigger_remove_points_comment_delete
  AFTER DELETE ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.remove_points_for_comment_delete();

-- 15. ATUALIZAR FUNÇÃO DE LOGIN DIÁRIO (se existir)
CREATE OR REPLACE FUNCTION public.record_daily_login(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_consecutive_days INTEGER := 0;
  v_current_date DATE := CURRENT_DATE;
  v_check_date DATE := CURRENT_DATE;
  v_points_result JSONB;
BEGIN
  -- Verificar se a tabela user_daily_logins existe, se não, criar
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_name = 'user_daily_logins'
  ) THEN
    CREATE TABLE IF NOT EXISTS public.user_daily_logins (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
      login_date DATE NOT NULL DEFAULT CURRENT_DATE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
      UNIQUE(user_id, login_date)
    );
  END IF;
  
  -- Inserir login de hoje (se ainda não existir)
  INSERT INTO public.user_daily_logins (user_id, login_date)
  VALUES (p_user_id, v_current_date)
  ON CONFLICT (user_id, login_date) DO NOTHING;
  
  -- Adicionar 8 pontos por login diário
  v_points_result := public.add_points_for_daily_login(p_user_id);
  
  -- Verificar quantos dias consecutivos o usuário fez login
  LOOP
    IF EXISTS (
      SELECT 1 FROM public.user_daily_logins 
      WHERE user_id = p_user_id 
      AND login_date = v_check_date
    ) THEN
      v_consecutive_days := v_consecutive_days + 1;
      v_check_date := v_check_date - INTERVAL '1 day';
    ELSE
      EXIT;
    END IF;
  END LOOP;
  
  -- Atualizar o perfil (usar UPDATE com verificação de coluna)
  DO $$
  BEGIN
    -- Tentar atualizar consecutive_days se a coluna existir
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'consecutive_days'
    ) THEN
      UPDATE public.profiles
      SET 
        consecutive_days = v_consecutive_days,
        last_login_date = v_current_date
      WHERE user_id = p_user_id;
    ELSE
      -- Se não existir, apenas atualizar last_login_date
      IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'profiles' AND column_name = 'last_login_date'
      ) THEN
        UPDATE public.profiles
        SET last_login_date = v_current_date
        WHERE user_id = p_user_id;
      END IF;
    END IF;
  END $$;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 16. VERIFICAR RESULTADO
SELECT 
  'Sistema de pontos com limite diário configurado!' as status,
  'Limite diário: 100 pontos' as info,
  'Login diário: 8 pontos' as login_points,
  'Post: 5 pontos' as post_points,
  'Curtida: 1 ponto' as like_points,
  'Comentário: 1 ponto' as comment_points;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

