-- =====================================================
-- TESTE COMPLETO: Liberação Automática de Módulos Diamond
-- =====================================================
-- Execute este script no Supabase SQL Editor para testar
-- se a liberação automática está funcionando corretamente

DO $$
DECLARE
  v_test_user_id UUID;
  v_test_module_id UUID;
  v_modules_count INTEGER;
  v_unlocked_count INTEGER;
  v_old_plan TEXT;
  v_test_passed BOOLEAN := true;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'INICIANDO TESTE DE LIBERAÇÃO AUTOMÁTICA';
  RAISE NOTICE '========================================';
  
  -- 1. Verificar se a função existe
  RAISE NOTICE '';
  RAISE NOTICE '1. Verificando se a função existe...';
  IF EXISTS (
    SELECT 1 FROM information_schema.routines 
    WHERE routine_name = 'auto_unlock_modules_on_diamond'
  ) THEN
    RAISE NOTICE '   ✅ Função auto_unlock_modules_on_diamond encontrada';
  ELSE
    RAISE NOTICE '   ❌ ERRO: Função não encontrada! Execute a migration primeiro.';
    v_test_passed := false;
  END IF;
  
  -- 2. Verificar se o trigger existe
  RAISE NOTICE '';
  RAISE NOTICE '2. Verificando se o trigger existe...';
  IF EXISTS (
    SELECT 1 FROM information_schema.triggers 
    WHERE trigger_name = 'trigger_auto_unlock_modules_on_diamond'
  ) THEN
    RAISE NOTICE '   ✅ Trigger trigger_auto_unlock_modules_on_diamond encontrado';
  ELSE
    RAISE NOTICE '   ❌ ERRO: Trigger não encontrado! Execute a migration primeiro.';
    v_test_passed := false;
  END IF;
  
  -- 3. Verificar se existem módulos bloqueados
  RAISE NOTICE '';
  RAISE NOTICE '3. Verificando módulos bloqueados...';
  SELECT COUNT(*) INTO v_modules_count 
  FROM public.modules 
  WHERE is_locked = true;
  
  IF v_modules_count > 0 THEN
    RAISE NOTICE '   ✅ Encontrados % módulos bloqueados', v_modules_count;
  ELSE
    RAISE NOTICE '   ⚠️  Nenhum módulo bloqueado encontrado. Criando um módulo de teste...';
    -- Criar um módulo de teste bloqueado
    INSERT INTO public.modules (title, is_locked, is_published, order_index)
    VALUES ('Módulo de Teste - Bloqueado', true, true, 999)
    RETURNING id INTO v_test_module_id;
    RAISE NOTICE '   ✅ Módulo de teste criado: %', v_test_module_id;
    v_modules_count := 1;
  END IF;
  
  -- 4. Buscar um usuário de teste (ou criar um temporário)
  RAISE NOTICE '';
  RAISE NOTICE '4. Preparando usuário de teste...';
  
  -- Tentar encontrar um usuário existente que não seja Diamond
  SELECT user_id INTO v_test_user_id
  FROM public.profiles
  WHERE subscription_plan IS NULL OR subscription_plan != 'diamond'
  LIMIT 1;
  
  IF v_test_user_id IS NULL THEN
    RAISE NOTICE '   ⚠️  Nenhum usuário não-Diamond encontrado. Usando primeiro usuário disponível...';
    SELECT user_id INTO v_test_user_id
    FROM public.profiles
    LIMIT 1;
  END IF;
  
  IF v_test_user_id IS NULL THEN
    RAISE NOTICE '   ❌ ERRO: Nenhum usuário encontrado no sistema!';
    v_test_passed := false;
  ELSE
    RAISE NOTICE '   ✅ Usuário de teste selecionado: %', v_test_user_id;
    
    -- Salvar plano atual
    SELECT subscription_plan INTO v_old_plan
    FROM public.profiles
    WHERE user_id = v_test_user_id;
    
    RAISE NOTICE '   📋 Plano atual: %', COALESCE(v_old_plan, 'NULL');
    
    -- 5. Limpar módulos desbloqueados anteriores para este teste
    RAISE NOTICE '';
    RAISE NOTICE '5. Limpando desbloqueios anteriores do usuário de teste...';
    DELETE FROM public.unlocked_modules WHERE user_id = v_test_user_id;
    RAISE NOTICE '   ✅ Limpeza concluída';
    
    -- 6. Verificar estado antes do teste
    RAISE NOTICE '';
    RAISE NOTICE '6. Estado ANTES do teste:';
    SELECT COUNT(*) INTO v_unlocked_count
    FROM public.unlocked_modules
    WHERE user_id = v_test_user_id;
    RAISE NOTICE '   📊 Módulos desbloqueados: %', v_unlocked_count;
    RAISE NOTICE '   📊 Módulos bloqueados no sistema: %', v_modules_count;
    
    -- 7. SIMULAR MUDANÇA PARA DIAMOND (isso vai acionar o trigger)
    RAISE NOTICE '';
    RAISE NOTICE '7. Simulando mudança de plano para Diamond...';
    UPDATE public.profiles
    SET subscription_plan = 'diamond'
    WHERE user_id = v_test_user_id;
    RAISE NOTICE '   ✅ Plano atualizado para Diamond';
    
    -- 8. Verificar se os módulos foram desbloqueados
    RAISE NOTICE '';
    RAISE NOTICE '8. Verificando se os módulos foram desbloqueados...';
    SELECT COUNT(*) INTO v_unlocked_count
    FROM public.unlocked_modules
    WHERE user_id = v_test_user_id;
    
    RAISE NOTICE '   📊 Módulos desbloqueados APÓS: %', v_unlocked_count;
    
    -- 9. Validar resultado
    RAISE NOTICE '';
    RAISE NOTICE '9. Validação do teste:';
    IF v_unlocked_count >= v_modules_count THEN
      RAISE NOTICE '   ✅ SUCESSO: Todos os módulos bloqueados foram desbloqueados!';
      RAISE NOTICE '   ✅ Esperado: % | Obtido: %', v_modules_count, v_unlocked_count;
    ELSE
      RAISE NOTICE '   ❌ FALHA: Nem todos os módulos foram desbloqueados!';
      RAISE NOTICE '   ❌ Esperado: % | Obtido: %', v_modules_count, v_unlocked_count;
      v_test_passed := false;
    END IF;
    
    -- 10. Restaurar plano original (se não era Diamond)
    RAISE NOTICE '';
    RAISE NOTICE '10. Restaurando plano original...';
    IF v_old_plan IS NULL OR v_old_plan != 'diamond' THEN
      UPDATE public.profiles
      SET subscription_plan = v_old_plan
      WHERE user_id = v_test_user_id;
      RAISE NOTICE '   ✅ Plano restaurado para: %', COALESCE(v_old_plan, 'NULL');
    ELSE
      RAISE NOTICE '   ℹ️  Usuário já era Diamond, mantendo como está';
    END IF;
    
    -- 11. Limpar módulo de teste se foi criado
    IF v_test_module_id IS NOT NULL THEN
      RAISE NOTICE '';
      RAISE NOTICE '11. Removendo módulo de teste...';
      DELETE FROM public.unlocked_modules WHERE module_id = v_test_module_id;
      DELETE FROM public.modules WHERE id = v_test_module_id;
      RAISE NOTICE '   ✅ Módulo de teste removido';
    END IF;
    
  END IF;
  
  -- 12. Resultado final
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  IF v_test_passed THEN
    RAISE NOTICE '✅ TESTE PASSOU COM SUCESSO!';
    RAISE NOTICE '✅ A liberação automática está funcionando corretamente.';
  ELSE
    RAISE NOTICE '❌ TESTE FALHOU!';
    RAISE NOTICE '❌ Verifique os erros acima e execute a migration novamente.';
  END IF;
  RAISE NOTICE '========================================';
  
END $$;

-- Verificação adicional: Listar todos os módulos bloqueados e seus desbloqueios
SELECT 
  m.id as module_id,
  m.title as module_title,
  m.is_locked,
  COUNT(um.user_id) as usuarios_com_acesso
FROM public.modules m
LEFT JOIN public.unlocked_modules um ON um.module_id = m.id
WHERE m.is_locked = true
GROUP BY m.id, m.title, m.is_locked
ORDER BY m.title;

