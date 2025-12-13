-- =====================================================
-- LIBERAR MENTORIA PARA TODOS OS DIAMOND - FORÇA TOTAL
-- Este script identifica TODOS os usuários Diamond de QUALQUER forma
-- e libera a mentoria para eles
-- =====================================================

-- PASSO 1: Corrigir subscription_plan para TODOS que têm subscription_expires_at
UPDATE public.profiles
SET subscription_plan = 'diamond'
WHERE subscription_expires_at IS NOT NULL
  AND (subscription_plan IS NULL OR subscription_plan != 'diamond');

-- PASSO 2: Liberar mentoria para TODOS os usuários Diamond (sem exceções)
DO $$
DECLARE
  v_user_id UUID;
  v_module_id UUID;
  v_total_usuarios INTEGER := 0;
  v_total_modulos INTEGER := 0;
  v_usuarios_processados INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA - FORÇA TOTAL';
  RAISE NOTICE '========================================';
  
  -- Contar módulos bloqueados
  SELECT COUNT(*) INTO v_total_modulos
  FROM public.modules 
  WHERE is_locked = true;
  
  RAISE NOTICE 'Módulos bloqueados: %', v_total_modulos;
  RAISE NOTICE '';
  
  -- Buscar TODOS os usuários Diamond (de qualquer forma)
  FOR v_user_id IN 
    SELECT DISTINCT user_id
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
       OR subscription_expires_at IS NOT NULL
    ORDER BY user_id
  LOOP
    v_total_usuarios := v_total_usuarios + 1;
    v_usuarios_processados := v_usuarios_processados + 1;
    
    -- Garantir que tem subscription_plan = 'diamond'
    UPDATE public.profiles
    SET subscription_plan = 'diamond'
    WHERE user_id = v_user_id
      AND (subscription_plan IS NULL OR subscription_plan != 'diamond');
    
    -- Desbloquear TODOS os módulos bloqueados
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (v_user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
    END LOOP;
    
    IF v_usuarios_processados % 10 = 0 THEN
      RAISE NOTICE 'Processados: % usuários...', v_usuarios_processados;
    END IF;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CONCLUÍDO!';
  RAISE NOTICE 'Usuários processados: %', v_usuarios_processados;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 3: Verificação - Listar TODOS os usuários Diamond e status
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  p.subscription_expires_at,
  COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) as modulos_mentoria_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ ACESSO COMPLETO'
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = 0 OR COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) IS NULL
    THEN '❌ SEM ACESSO'
    ELSE '⚠️ PARCIAL'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.subscription_plan = 'diamond'
   OR p.subscription_expires_at IS NOT NULL
GROUP BY p.user_id, p.username, p.full_name, p.subscription_plan, p.subscription_expires_at
ORDER BY 
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) THEN 1
    ELSE 2
  END,
  p.username;

