-- =====================================================
-- LIBERAR MENTORIA PARA TODOS OS USUÁRIOS DIAMOND
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- Este script libera TODOS os módulos bloqueados (incluindo a mentoria avançada)
-- para TODOS os usuários que têm o plano Diamond

DO $$
DECLARE
  v_user_id UUID;
  v_module_id UUID;
  v_users_processed INTEGER := 0;
  v_modules_unlocked_total INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA PARA DIAMOND';
  RAISE NOTICE '========================================';
  
  -- Para cada usuário com plano Diamond
  FOR v_user_id IN 
    SELECT user_id 
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
  LOOP
    v_users_processed := v_users_processed + 1;
    RAISE NOTICE 'Processando usuário %...', v_user_id;
    
    -- Desbloquear todos os módulos bloqueados para este usuário
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (v_user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
      
      -- Contar apenas se foi inserido
      IF FOUND THEN
        v_modules_unlocked_total := v_modules_unlocked_total + 1;
      END IF;
    END LOOP;
    
    RAISE NOTICE '  ✅ Usuário % processado', v_user_id;
  END LOOP;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO:';
  RAISE NOTICE '  Usuários Diamond processados: %', v_users_processed;
  RAISE NOTICE '  Módulos desbloqueados (novos): %', v_modules_unlocked_total;
  RAISE NOTICE '========================================';
  
END $$;

-- Verificação: Listar usuários Diamond e quantos módulos têm desbloqueados
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  COUNT(um.module_id) as modulos_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name, p.subscription_plan
ORDER BY p.username;

