-- =====================================================
-- CONCEDER PLANO DIAMOND PARA TODOS - VERSÃO SIMPLES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Garantir que a coluna subscription_plan existe
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS subscription_plan TEXT DEFAULT 'free';

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

-- 2. Atualizar TODOS os perfis para DIAMOND (sem condições)
UPDATE public.profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NULL,
  updated_at = NOW();

-- 3. Mostrar resultado
SELECT 
  'Total de usuários atualizados:' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN subscription_plan = 'diamond' THEN 1 END) as diamond
FROM public.profiles;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

