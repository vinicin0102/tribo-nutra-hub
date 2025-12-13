-- =====================================================
-- LIBERAR MENTORIA PARA TODOS OS USUÁRIOS DIAMOND
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- Este script libera TODOS os módulos bloqueados (incluindo a mentoria avançada)
-- para TODOS os usuários que têm o plano Diamond

-- PRIMEIRO: Ver quantos usuários Diamond existem
SELECT 
  COUNT(*) as total_usuarios_diamond,
  STRING_AGG(user_id::text, ', ') as lista_ids
FROM public.profiles 
WHERE subscription_plan = 'diamond';

-- SEGUNDO: Liberar mentoria para TODOS os usuários Diamond
DO $$
DECLARE
  v_user_id UUID;
  v_module_id UUID;
  v_users_processed INTEGER := 0;
  v_modules_unlocked_total INTEGER := 0;
  v_total_diamond_users INTEGER;
  v_total_locked_modules INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA PARA DIAMOND';
  RAISE NOTICE '========================================';
  
  -- Contar total de usuários Diamond
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
  
  -- Para cada usuário com plano Diamond (sem filtros adicionais)
  FOR v_user_id IN 
    SELECT user_id 
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
    ORDER BY user_id
  LOOP
    v_users_processed := v_users_processed + 1;
    
    -- Desbloquear todos os módulos bloqueados para este usuário
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      BEGIN
        INSERT INTO public.unlocked_modules (user_id, module_id)
        VALUES (v_user_id, v_module_id)
        ON CONFLICT (user_id, module_id) DO NOTHING;
        
        -- Contar se foi inserido (GET DIAGNOSTICS é mais confiável que FOUND)
        GET DIAGNOSTICS v_modules_unlocked_total = ROW_COUNT;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE WARNING 'Erro ao desbloquear módulo % para usuário %: %', v_module_id, v_user_id, SQLERRM;
      END;
    END LOOP;
    
    IF v_users_processed % 10 = 0 THEN
      RAISE NOTICE 'Processados % de % usuários...', v_users_processed, v_total_diamond_users;
    END IF;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO:';
  RAISE NOTICE '  Usuários Diamond processados: %', v_users_processed;
  RAISE NOTICE '  Módulos bloqueados no sistema: %', v_total_locked_modules;
  RAISE NOTICE '========================================';
  
END $$;

-- TERCEIRO: Verificação completa
-- Listar TODOS os usuários Diamond e quantos módulos bloqueados têm desbloqueados

-- Ver todos os usuários Diamond
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) as modulos_bloqueados_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ COMPLETO'
    ELSE '❌ INCOMPLETO'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name, p.subscription_plan
ORDER BY p.username;

-- Ver usuários Diamond que NÃO têm TODOS os módulos bloqueados desbloqueados
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) as modulos_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name
HAVING COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) < (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
   OR COUNT(DISTINCT CASE WHEN m.is_locked = true THEN um.module_id END) IS NULL
ORDER BY p.username;

