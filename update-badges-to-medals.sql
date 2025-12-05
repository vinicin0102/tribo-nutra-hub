-- =====================================================
-- ATUALIZAR BADGES PARA USAR MEDALHAS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Atualizar os ícones dos badges para usar identificadores de medalhas
UPDATE public.badges
SET icon = 'beginner'
WHERE name = 'Iniciante';

UPDATE public.badges
SET icon = 'active'
WHERE name = 'Ativo';

UPDATE public.badges
SET icon = 'engaged'
WHERE name = 'Engajado';

UPDATE public.badges
SET icon = 'influencer'
WHERE name = 'Influenciador';

UPDATE public.badges
SET icon = 'legend'
WHERE name = 'Lenda';

-- Verificar resultado
SELECT name, icon, points_required 
FROM public.badges 
ORDER BY points_required ASC;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

