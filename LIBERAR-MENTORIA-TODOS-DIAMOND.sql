-- =====================================================
-- LIBERAR MENTORIA PARA TODOS OS USUÁRIOS DIAMOND
-- Incluindo usuários que receberam Diamond manualmente
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- PRIMEIRO: Identificar TODOS os usuários Diamond (incluindo casos especiais)
SELECT 
  '=== LISTA DE TODOS OS USUÁRIOS DIAMOND ===' as info;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  p.subscription_expires_at,
  CASE 
    WHEN p.subscription_plan = 'diamond' THEN '✅ Plano Diamond'
    ELSE '❓ Outro plano'
  END as status_plano
FROM public.profiles p
WHERE p.subscription_plan = 'diamond'
ORDER BY p.username;

-- Verificar se há usuários com subscription_expires_at mas sem subscription_plan = 'diamond'
SELECT 
  '=== USUÁRIOS COM DATAS DE EXPIRAÇÃO MAS SEM PLANO DIAMOND ===' as info;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  p.subscription_expires_at
FROM public.profiles p
WHERE p.subscription_expires_at IS NOT NULL
  AND (p.subscription_plan IS NULL OR p.subscription_plan != 'diamond')
ORDER BY p.username;

-- SEGUNDO: Garantir que todos os usuários Diamond tenham subscription_plan = 'diamond'
-- (Corrige casos onde foi dado manualmente mas o campo não foi atualizado)
UPDATE public.profiles
SET subscription_plan = 'diamond'
WHERE subscription_expires_at IS NOT NULL
  AND (subscription_plan IS NULL OR subscription_plan != 'diamond')
  AND subscription_expires_at > NOW();

-- TERCEIRO: Liberar mentoria para TODOS os usuários Diamond
DO $$
DECLARE
  v_user_id UUID;
  v_module_id UUID;
  v_users_processed INTEGER := 0;
  v_modules_unlocked_total INTEGER := 0;
  v_total_diamond_users INTEGER;
  v_total_locked_modules INTEGER;
  v_new_unlocks INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA PARA TODOS OS DIAMOND';
  RAISE NOTICE '========================================';
  
  -- Contar total de usuários Diamond (após correção)
  SELECT COUNT(*) INTO v_total_diamond_users
  FROM public.profiles 
  WHERE subscription_plan = 'diamond';
  
  -- Contar total de módulos bloqueados
  SELECT COUNT(*) INTO v_total_locked_modules
  FROM public.modules 
  WHERE is_locked = true;
  
  RAISE NOTICE 'Total de usuários Diamond encontrados: %', v_total_diamond_users;
  RAISE NOTICE 'Total de módulos bloqueados: %', v_total_locked_modules;
  RAISE NOTICE '';
  
  -- Para CADA usuário Diamond (sem exceções)
  FOR v_user_id IN 
    SELECT DISTINCT user_id 
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
    ORDER BY user_id
  LOOP
    v_users_processed := v_users_processed + 1;
    v_new_unlocks := 0;
    
    -- Desbloquear TODOS os módulos bloqueados para este usuário
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      BEGIN
        INSERT INTO public.unlocked_modules (user_id, module_id)
        VALUES (v_user_id, v_module_id)
        ON CONFLICT (user_id, module_id) DO NOTHING;
        
        -- Verificar se foi inserido (ROW_COUNT)
        GET DIAGNOSTICS v_new_unlocks = ROW_COUNT;
        IF v_new_unlocks > 0 THEN
          v_modules_unlocked_total := v_modules_unlocked_total + 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE WARNING '⚠️  Erro ao desbloquear módulo % para usuário %: %', v_module_id, v_user_id, SQLERRM;
      END;
    END LOOP;
    
    IF v_users_processed % 5 = 0 OR v_users_processed = v_total_diamond_users THEN
      RAISE NOTICE 'Progresso: %/% usuários processados', v_users_processed, v_total_diamond_users;
    END IF;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO FINAL:';
  RAISE NOTICE '  Usuários Diamond processados: %', v_users_processed;
  RAISE NOTICE '  Módulos bloqueados no sistema: %', v_total_locked_modules;
  RAISE NOTICE '  Novos desbloqueios realizados: %', v_modules_unlocked_total;
  RAISE NOTICE '========================================';
  
END $$;

-- QUARTO: Verificação completa - Listar TODOS os usuários Diamond
SELECT 
  '=== VERIFICAÇÃO FINAL: TODOS OS USUÁRIOS DIAMOND ===' as info;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) as modulos_bloqueados_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ TODOS OS MÓDULOS DESBLOQUEADOS'
    WHEN COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) = 0
    THEN '❌ NENHUM MÓDULO DESBLOQUEADO'
    ELSE '⚠️  PARCIALMENTE DESBLOQUEADO'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name, p.subscription_plan
ORDER BY status, p.username;

-- QUINTO: Identificar usuários Diamond que ainda NÃO têm todos os módulos desbloqueados
SELECT 
  '=== USUÁRIOS DIAMOND INCOMPLETOS (CORRIGIR) ===' as info;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) as modulos_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) - COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) as faltando
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name
HAVING COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) < (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
   OR COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) IS NULL
ORDER BY faltando DESC, p.username;

