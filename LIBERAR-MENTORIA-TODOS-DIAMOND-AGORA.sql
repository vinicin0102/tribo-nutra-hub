-- =====================================================
-- LIBERAR MENTORIA PARA TODOS OS USUÁRIOS DIAMOND
-- Execute este script no Supabase SQL Editor
-- =====================================================

DO $$
DECLARE
  v_user RECORD;
  v_module_id UUID;
  v_total_usuarios INTEGER := 0;
  v_total_modulos INTEGER := 0;
  v_usuarios_processados INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA PARA TODOS OS DIAMOND';
  RAISE NOTICE '========================================';
  
  -- Contar módulos bloqueados
  SELECT COUNT(*) INTO v_total_modulos
  FROM public.modules 
  WHERE is_locked = true;
  
  -- Contar usuários Diamond
  SELECT COUNT(*) INTO v_total_usuarios
  FROM public.profiles 
  WHERE subscription_plan = 'diamond';
  
  RAISE NOTICE 'Usuários Diamond encontrados: %', v_total_usuarios;
  RAISE NOTICE 'Módulos bloqueados encontrados: %', v_total_modulos;
  RAISE NOTICE '';
  
  -- Para CADA usuário Diamond
  FOR v_user IN 
    SELECT DISTINCT user_id, username, full_name
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
    ORDER BY username
  LOOP
    v_usuarios_processados := v_usuarios_processados + 1;
    
    -- Desbloquear TODOS os módulos bloqueados para este usuário
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (v_user.user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
    END LOOP;
    
    -- Mostrar progresso a cada 5 usuários
    IF v_usuarios_processados % 5 = 0 THEN
      RAISE NOTICE 'Processados: % de % usuários...', v_usuarios_processados, v_total_usuarios;
    END IF;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CONCLUÍDO!';
  RAISE NOTICE 'Total de usuários Diamond processados: %', v_usuarios_processados;
  RAISE NOTICE 'Total de módulos bloqueados: %', v_total_modulos;
  RAISE NOTICE '========================================';
END $$;

-- Verificação: Listar todos os usuários Diamond e seus status
SELECT 
  p.username,
  p.full_name,
  p.subscription_plan,
  COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) as modulos_mentoria_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ ACESSO COMPLETO'
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = 0 OR COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) IS NULL
    THEN '❌ SEM ACESSO'
    ELSE '⚠️ ACESSO PARCIAL'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name, p.subscription_plan
ORDER BY 
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) THEN 1
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = 0 OR COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) IS NULL THEN 3
    ELSE 2
  END,
  p.username;

