-- =====================================================
-- ATUALIZAR BADGES PARA USAR MEDALHAS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Atualizar os ícones dos badges para usar identificadores de medalhas
-- Isso substitui os emojis (🌱, ⭐, 🔥, 💪, 👑) por identificadores

UPDATE public.badges
SET icon = 'beginner'
WHERE name = 'Iniciante' OR icon = '🌱';

UPDATE public.badges
SET icon = 'active'
WHERE name = 'Ativo' OR icon = '⭐';

UPDATE public.badges
SET icon = 'engaged'
WHERE name = 'Engajado' OR icon = '🔥';

UPDATE public.badges
SET icon = 'influencer'
WHERE name = 'Influenciador' OR icon = '💪';

UPDATE public.badges
SET icon = 'legend'
WHERE name = 'Lenda' OR icon = '👑';

-- Verificar resultado
SELECT 
  name, 
  icon, 
  points_required,
  CASE 
    WHEN icon = 'beginner' THEN '✅ Atualizado para medalha'
    WHEN icon = 'active' THEN '✅ Atualizado para medalha'
    WHEN icon = 'engaged' THEN '✅ Atualizado para medalha'
    WHEN icon = 'influencer' THEN '✅ Atualizado para medalha'
    WHEN icon = 'legend' THEN '✅ Atualizado para medalha'
    ELSE '⚠️ Ainda usando emoji'
  END as status
FROM public.badges 
ORDER BY points_required ASC;

-- =====================================================
-- PRONTO! 🎉
-- Agora os badges usam identificadores de medalhas
-- O componente MedalIcon irá renderizar medalhas SVG
-- =====================================================

