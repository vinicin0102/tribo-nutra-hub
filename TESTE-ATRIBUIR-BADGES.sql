-- Script para testar e atribuir badges manualmente
-- Execute este script no Supabase SQL Editor

-- 1. Verificar se há badges no banco
SELECT id, name, points_required FROM public.badges ORDER BY points_required;

-- 2. Verificar pontos dos usuários
SELECT user_id, username, points FROM public.profiles ORDER BY points DESC LIMIT 10;

-- 3. Verificar badges atribuídos
SELECT ub.user_id, p.username, b.name, b.points_required
FROM public.user_badges ub
JOIN public.profiles p ON p.user_id = ub.user_id
JOIN public.badges b ON b.id = ub.badge_id
ORDER BY p.username, b.points_required;

-- 4. Atribuir badges para todos os usuários (executar a função)
DO $$
DECLARE
    v_user RECORD;
BEGIN
    FOR v_user IN SELECT user_id, points FROM public.profiles
    LOOP
        PERFORM public.check_and_assign_badges(v_user.user_id);
    END LOOP;
END $$;

-- 5. Verificar novamente os badges atribuídos
SELECT ub.user_id, p.username, b.name, b.points_required
FROM public.user_badges ub
JOIN public.profiles p ON p.user_id = ub.user_id
JOIN public.badges b ON b.id = ub.badge_id
ORDER BY p.username, b.points_required;

