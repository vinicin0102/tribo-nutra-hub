-- =====================================================
-- SOLUÇÃO DEFINITIVA PARA RESTABELECER PONTUAÇÕES (V2 - CORRIGIDA)
-- =====================================================

-- 1. GARANTIR A TABELA DE PONTOS DIÁRIOS
CREATE TABLE IF NOT EXISTS public.daily_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  points_date DATE NOT NULL DEFAULT CURRENT_DATE,
  points_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, points_date)
);

-- Índices e RLS
CREATE INDEX IF NOT EXISTS idx_daily_points_user_date ON public.daily_points(user_id, points_date);
ALTER TABLE public.daily_points ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own daily points" ON public.daily_points;
CREATE POLICY "Users can view own daily points" ON public.daily_points FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can manage daily points" ON public.daily_points;
CREATE POLICY "System can manage daily points" ON public.daily_points FOR ALL USING (true);

-- 2. FUNÇÃO CENTRAL PARA ADICIONAR PONTOS (COM COMPATIBILIDADE)
-- Dropar antes para evitar erro de tipo de retorno
-- Dropar todas as variações possíveis para evitar erro de tipo de retorno
DROP FUNCTION IF EXISTS public.add_points_with_limit(UUID, INTEGER, TEXT);
DROP FUNCTION IF EXISTS public.add_points_with_limit(UUID, INTEGER, TEXT, TEXT);

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
  v_current_points INTEGER;
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
    RETURN jsonb_build_object(
      'success', false,
      'points_added', 0,
      'points_earned', 0,
      'message', 'Limite diário de 100 pontos atingido!'
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
  WHERE user_id = p_user_id
  RETURNING points INTO v_current_points;
  
  -- Criar notificação (se ganhou pontos)
  IF v_points_to_add > 0 THEN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      p_user_id,
      'points',
      'Pontos Ganhos!',
      COALESCE(p_message, '+' || v_points_to_add || ' pontos por ' || p_action_type)
    )
    RETURNING id INTO v_notification_id;
  END IF;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_added', v_points_to_add,
    'points_earned', v_points_to_add, -- Compatibilidade com frontend
    'message', '+' || v_points_to_add || ' pontos!',
    'new_total_points', v_current_points
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FUNÇÕES AUXILIARES DE PONTOS
-- Dropar antes
DROP FUNCTION IF EXISTS public.add_points_for_daily_login(UUID);

CREATE OR REPLACE FUNCTION public.add_points_for_daily_login(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_already_earned_today BOOLEAN;
BEGIN
  -- A verificação real deve ser feita na chamada (record_daily_login)
  
  v_result := public.add_points_with_limit(
    p_user_id,
    8,
    'login diário',
    '+8 pontos por login diário!'
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. FUNÇÃO DE REGISTRO DE LOGIN (CORRIGIDA E COMPATÍVEL)
-- Dropar antes para evitar erro de tipo de retorno (IMPORTANTE: ISSO CORRIGE O ERRO 42P13)
DROP FUNCTION IF EXISTS public.record_daily_login(UUID);

CREATE OR REPLACE FUNCTION public.record_daily_login(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_consecutive_days INTEGER := 0;
  v_current_date DATE := CURRENT_DATE;
  v_check_date DATE := CURRENT_DATE;
  v_points_result JSONB;
  v_already_logged_today BOOLEAN;
  v_points_earned INTEGER := 0;
BEGIN
  -- Tabela de logs de login
  CREATE TABLE IF NOT EXISTS public.user_daily_logins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    login_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id, login_date)
  );
  
  -- Verificar se já fez login hoje para evitar duplicação de pontos
  SELECT EXISTS (
    SELECT 1 FROM public.user_daily_logins 
    WHERE user_id = p_user_id 
    AND login_date = v_current_date
  ) INTO v_already_logged_today;
  
  IF v_already_logged_today THEN
    -- Já logou, não dá pontos, mas retorna estrutura compatível
    RETURN jsonb_build_object(
      'success', false,
      'points_earned', 0,
      'message', 'Login já registrado hoje.',
      'already_logged', true
    );
  END IF;
  
  -- Inserir login
  INSERT INTO public.user_daily_logins (user_id, login_date)
  VALUES (p_user_id, v_current_date)
  ON CONFLICT (user_id, login_date) DO NOTHING;
  
  -- Adicionar pontos
  v_points_result := public.add_points_for_daily_login(p_user_id);
  v_points_earned := (v_points_result->>'points_earned')::INTEGER;
  
  -- Calcular dias consecutivos
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
  
  -- Atualizar perfil
  UPDATE public.profiles
  SET 
    consecutive_days = v_consecutive_days,
    last_login_date = v_current_date
  WHERE user_id = p_user_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_earned', v_points_earned, -- CHAVE IMPORTANTE PARA O FRONTEND
    'consecutive_days', v_consecutive_days,
    'message', 'Login registrado! +' || v_points_earned || ' pontos!'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 5. TRIGGERS PARA AÇÕES (POSTS, LIKES, COMMENTS)
-- Função para Posts
CREATE OR REPLACE FUNCTION public.add_points_for_post()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.add_points_with_limit(
    NEW.user_id,
    5,
    'publicação',
    '+5 pontos por publicar!'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para Likes
CREATE OR REPLACE FUNCTION public.add_points_for_like()
RETURNS TRIGGER AS $$
BEGIN
  -- Dar pontos para quem DEU o like
  PERFORM public.add_points_with_limit(
    NEW.user_id,
    1,
    'curtida',
    '+1 ponto por curtir!'
  );
  
  -- Atualizar contador do post
  UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para Comentários
CREATE OR REPLACE FUNCTION public.add_points_for_comment()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.add_points_with_limit(
    NEW.user_id,
    1,
    'comentário',
    '+1 ponto por comentar!'
  );
  
  UPDATE public.posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover triggers antigos para evitar duplicação ou erro
DROP TRIGGER IF EXISTS trigger_add_points_post ON public.posts;
DROP TRIGGER IF EXISTS on_post_created ON public.posts;

DROP TRIGGER IF EXISTS trigger_add_points_like ON public.likes;
DROP TRIGGER IF EXISTS on_like_change ON public.likes;

DROP TRIGGER IF EXISTS trigger_add_points_comment ON public.comments;
DROP TRIGGER IF EXISTS on_comment_change ON public.comments;

-- Criar triggers novamente
CREATE TRIGGER trigger_add_points_post
  AFTER INSERT ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_post();

CREATE TRIGGER trigger_add_points_like
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_like();

CREATE TRIGGER trigger_add_points_comment
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.add_points_for_comment();

-- Verificação final
SELECT 'Sistema de pontuação restaurado com sucesso! (Versão atualizada)' as status;
