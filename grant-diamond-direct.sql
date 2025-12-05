-- =====================================================
-- CONCEDER DIAMOND - VERSÃO MAIS DIRETA
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Atualizar TODOS os perfis para DIAMOND
UPDATE public.profiles
SET subscription_plan = 'diamond';

-- Verificar resultado
SELECT user_id, username, subscription_plan 
FROM public.profiles 
ORDER BY created_at DESC 
LIMIT 10;

