-- Função para atribuir badges automaticamente baseado nos pontos do usuário
CREATE OR REPLACE FUNCTION public.check_and_assign_badges(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_points INTEGER;
    v_badge RECORD;
BEGIN
    -- Buscar pontos do usuário
    SELECT COALESCE(points, 0) INTO v_user_points
    FROM public.profiles
    WHERE user_id = p_user_id;
    
    -- Verificar todos os badges e atribuir os que o usuário já conquistou
    FOR v_badge IN 
        SELECT id, points_required 
        FROM public.badges
        WHERE points_required <= v_user_points
    LOOP
        -- Inserir badge se ainda não foi atribuído (evita duplicatas)
        INSERT INTO public.user_badges (user_id, badge_id)
        VALUES (p_user_id, v_badge.id)
        ON CONFLICT (user_id, badge_id) DO NOTHING;
    END LOOP;
END;
$$;

-- Trigger para atribuir badges automaticamente quando os pontos são atualizados
CREATE OR REPLACE FUNCTION public.auto_assign_badges_on_points_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Atribuir badges quando os pontos mudarem
    IF NEW.points IS DISTINCT FROM OLD.points THEN
        PERFORM public.check_and_assign_badges(NEW.user_id);
    END IF;
    
    RETURN NEW;
END;
$$;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_auto_assign_badges ON public.profiles;
CREATE TRIGGER trigger_auto_assign_badges
    AFTER UPDATE OF points ON public.profiles
    FOR EACH ROW
    WHEN (NEW.points IS DISTINCT FROM OLD.points)
    EXECUTE FUNCTION public.auto_assign_badges_on_points_update();

-- Atribuir badges para todos os usuários existentes baseado nos pontos atuais
DO $$
DECLARE
    v_user RECORD;
BEGIN
    FOR v_user IN SELECT user_id, points FROM public.profiles
    LOOP
        PERFORM public.check_and_assign_badges(v_user.user_id);
    END LOOP;
END $$;

