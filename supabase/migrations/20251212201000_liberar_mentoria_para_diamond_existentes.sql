-- Liberar mentoria avançada (todos os módulos bloqueados) para usuários Diamond existentes
-- Este script garante que usuários que já eram Diamond antes da implementação do trigger
-- também tenham acesso a todos os módulos bloqueados, incluindo a mentoria avançada

DO $$
DECLARE
  v_user_id UUID;
  v_module_id UUID;
  v_modules_unlocked INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERANDO MENTORIA PARA DIAMOND EXISTENTES';
  RAISE NOTICE '========================================';
  
  -- Para cada usuário com plano Diamond
  FOR v_user_id IN 
    SELECT user_id 
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
  LOOP
    v_modules_unlocked := 0;
    
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
        v_modules_unlocked := v_modules_unlocked + 1;
      END IF;
    END LOOP;
    
    IF v_modules_unlocked > 0 THEN
      RAISE NOTICE '✅ Usuário %: % módulos desbloqueados', v_user_id, v_modules_unlocked;
    END IF;
  END LOOP;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'LIBERAÇÃO CONCLUÍDA';
  RAISE NOTICE '========================================';
END $$;

-- Comentário explicativo
COMMENT ON FUNCTION public.auto_unlock_modules_on_diamond() IS 
'Desbloqueia automaticamente todos os módulos bloqueados (incluindo mentoria avançada) quando o usuário assina o plano Diamond';

