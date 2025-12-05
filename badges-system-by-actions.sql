-- =====================================================
-- SISTEMA DE MEDALHAS BASEADO EM AÇÕES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. ADICIONAR COLUNAS NA TABELA PROFILES PARA RASTREAR AÇÕES
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS posts_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS likes_given_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS comments_given_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS consecutive_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_login_date DATE;

-- 2. CRIAR TABELA PARA RASTREAR LOGINS DIÁRIOS
CREATE TABLE IF NOT EXISTS public.user_daily_logins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  login_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, login_date)
);

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_daily_logins_user_date ON public.user_daily_logins(user_id, login_date);
CREATE INDEX IF NOT EXISTS idx_profiles_posts_count ON public.profiles(posts_count);
CREATE INDEX IF NOT EXISTS idx_profiles_likes_given ON public.profiles(likes_given_count);
CREATE INDEX IF NOT EXISTS idx_profiles_comments_given ON public.profiles(comments_given_count);

-- 4. HABILITAR RLS NA NOVA TABELA
ALTER TABLE public.user_daily_logins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own daily logins" 
  ON public.user_daily_logins FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "System can insert daily logins" 
  ON public.user_daily_logins FOR INSERT 
  WITH CHECK (true);

-- 5. ATUALIZAR BADGES COM NOVAS CONDIÇÕES
-- Remover badges antigos baseados em pontos
DELETE FROM public.badges WHERE name IN ('Iniciante', 'Ativo', 'Engajado', 'Influenciador', 'Lenda');

-- Inserir novos badges baseados em ações
INSERT INTO public.badges (name, description, icon, points_required) VALUES
  ('Influenciador', 'Fazer 20 posts', 'influencer', 0),
  ('Ativo', '7 dias seguidos entrando', 'active', 0),
  ('Engajado', 'Curtir e comentar 7 posts', 'engaged', 0),
  ('Lenda', '100 posts + 100 curtidas + 100 comentários', 'legend', 0);

-- 6. FUNÇÃO: CONTAR POSTS CRIADOS
CREATE OR REPLACE FUNCTION public.count_user_posts()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles 
    SET posts_count = (
      SELECT COUNT(*) 
      FROM public.posts 
      WHERE user_id = NEW.user_id
    )
    WHERE user_id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles 
    SET posts_count = (
      SELECT COUNT(*) 
      FROM public.posts 
      WHERE user_id = OLD.user_id
    )
    WHERE user_id = OLD.user_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO: CONTAR CURTIDAS DADAS
CREATE OR REPLACE FUNCTION public.count_user_likes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles 
    SET likes_given_count = (
      SELECT COUNT(*) 
      FROM public.likes 
      WHERE user_id = NEW.user_id
    )
    WHERE user_id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles 
    SET likes_given_count = (
      SELECT COUNT(*) 
      FROM public.likes 
      WHERE user_id = OLD.user_id
    )
    WHERE user_id = OLD.user_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO: CONTAR COMENTÁRIOS DADOS
CREATE OR REPLACE FUNCTION public.count_user_comments()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles 
    SET comments_given_count = (
      SELECT COUNT(*) 
      FROM public.comments 
      WHERE user_id = NEW.user_id
    )
    WHERE user_id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles 
    SET comments_given_count = (
      SELECT COUNT(*) 
      FROM public.comments 
      WHERE user_id = OLD.user_id
    )
    WHERE user_id = OLD.user_id;
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. FUNÇÃO: VERIFICAR E ATUALIZAR DIAS CONSECUTIVOS
CREATE OR REPLACE FUNCTION public.update_consecutive_days(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_consecutive_days INTEGER := 0;
  v_current_date DATE := CURRENT_DATE;
  v_check_date DATE := CURRENT_DATE;
BEGIN
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
  
  -- Atualizar o perfil
  UPDATE public.profiles
  SET 
    consecutive_days = v_consecutive_days,
    last_login_date = v_current_date
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. FUNÇÃO: REGISTRAR LOGIN DIÁRIO
CREATE OR REPLACE FUNCTION public.record_daily_login(p_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Inserir login de hoje (se ainda não existir)
  INSERT INTO public.user_daily_logins (user_id, login_date)
  VALUES (p_user_id, CURRENT_DATE)
  ON CONFLICT (user_id, login_date) DO NOTHING;
  
  -- Atualizar dias consecutivos
  PERFORM public.update_consecutive_days(p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. FUNÇÃO: VERIFICAR E ATRIBUIR BADGES
CREATE OR REPLACE FUNCTION public.check_and_assign_badges(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_profile RECORD;
  v_badge_id UUID;
BEGIN
  -- Buscar perfil do usuário
  SELECT * INTO v_profile
  FROM public.profiles
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    RETURN;
  END IF;
  
  -- BADGE: INFLUENCIADOR (20 posts)
  IF v_profile.posts_count >= 20 THEN
    SELECT id INTO v_badge_id
    FROM public.badges
    WHERE name = 'Influenciador';
    
    IF v_badge_id IS NOT NULL THEN
      INSERT INTO public.user_badges (user_id, badge_id)
      VALUES (p_user_id, v_badge_id)
      ON CONFLICT (user_id, badge_id) DO NOTHING;
    END IF;
  END IF;
  
  -- BADGE: ATIVO (7 dias consecutivos)
  IF v_profile.consecutive_days >= 7 THEN
    SELECT id INTO v_badge_id
    FROM public.badges
    WHERE name = 'Ativo';
    
    IF v_badge_id IS NOT NULL THEN
      INSERT INTO public.user_badges (user_id, badge_id)
      VALUES (p_user_id, v_badge_id)
      ON CONFLICT (user_id, badge_id) DO NOTHING;
    END IF;
  END IF;
  
  -- BADGE: ENGAJADO (7 curtidas + 7 comentários)
  IF v_profile.likes_given_count >= 7 AND v_profile.comments_given_count >= 7 THEN
    SELECT id INTO v_badge_id
    FROM public.badges
    WHERE name = 'Engajado';
    
    IF v_badge_id IS NOT NULL THEN
      INSERT INTO public.user_badges (user_id, badge_id)
      VALUES (p_user_id, v_badge_id)
      ON CONFLICT (user_id, badge_id) DO NOTHING;
    END IF;
  END IF;
  
  -- BADGE: LENDA (100 posts + 100 curtidas + 100 comentários)
  IF v_profile.posts_count >= 100 
     AND v_profile.likes_given_count >= 100 
     AND v_profile.comments_given_count >= 100 THEN
    SELECT id INTO v_badge_id
    FROM public.badges
    WHERE name = 'Lenda';
    
    IF v_badge_id IS NOT NULL THEN
      INSERT INTO public.user_badges (user_id, badge_id)
      VALUES (p_user_id, v_badge_id)
      ON CONFLICT (user_id, badge_id) DO NOTHING;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. CRIAR TRIGGERS PARA CONTAR AÇÕES
DROP TRIGGER IF EXISTS trigger_count_posts ON public.posts;
CREATE TRIGGER trigger_count_posts
  AFTER INSERT OR DELETE ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.count_user_posts();

DROP TRIGGER IF EXISTS trigger_count_likes ON public.likes;
CREATE TRIGGER trigger_count_likes
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.count_user_likes();

DROP TRIGGER IF EXISTS trigger_count_comments ON public.comments;
CREATE TRIGGER trigger_count_comments
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.count_user_comments();

-- 13. FUNÇÃO: VERIFICAR BADGES APÓS AÇÕES
CREATE OR REPLACE FUNCTION public.trigger_check_badges()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.check_and_assign_badges(COALESCE(NEW.user_id, OLD.user_id));
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 14. TRIGGERS PARA VERIFICAR BADGES APÓS AÇÕES
DROP TRIGGER IF EXISTS trigger_check_badges_posts ON public.posts;
CREATE TRIGGER trigger_check_badges_posts
  AFTER INSERT ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_check_badges();

DROP TRIGGER IF EXISTS trigger_check_badges_likes ON public.likes;
CREATE TRIGGER trigger_check_badges_likes
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_check_badges();

DROP TRIGGER IF EXISTS trigger_check_badges_comments ON public.comments;
CREATE TRIGGER trigger_check_badges_comments
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_check_badges();

-- 15. INICIALIZAR CONTADORES PARA USUÁRIOS EXISTENTES
UPDATE public.profiles p
SET 
  posts_count = (SELECT COUNT(*) FROM public.posts WHERE user_id = p.user_id),
  likes_given_count = (SELECT COUNT(*) FROM public.likes WHERE user_id = p.user_id),
  comments_given_count = (SELECT COUNT(*) FROM public.comments WHERE user_id = p.user_id);

-- 16. VERIFICAR RESULTADO
SELECT 
  'Sistema de medalhas configurado!' as status,
  COUNT(*) as total_badges
FROM public.badges;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Para registrar login diário, chame:
-- SELECT public.record_daily_login(auth.uid());
-- =====================================================

