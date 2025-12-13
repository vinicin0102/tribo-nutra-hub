-- =====================================================
-- DESBLOQUEAR MENTORIA PARA UM ALUNO DIAMOND ESPECÍFICO
-- Use este script quando passar alguém para Diamond manualmente
-- =====================================================

-- SUBSTITUA 'USER_ID_AQUI' pelo ID do usuário (UUID) que você acabou de passar para Diamond
-- Você pode encontrar o ID do usuário na tabela profiles ou auth.users

-- EXEMPLO DE USO:
-- 1. Encontre o ID do usuário:
--    SELECT user_id, username, full_name, subscription_plan 
--    FROM public.profiles 
--    WHERE username = 'nome_do_usuario';

-- 2. Execute este script substituindo USER_ID_AQUI pelo ID encontrado

-- =====================================================

-- OPÇÃO 1: Desbloquear usando USER_ID (UUID)
-- Substitua 'USER_ID_AQUI' pelo ID real do usuário
DO $$
DECLARE
  v_user_id UUID := 'USER_ID_AQUI';  -- ⚠️ SUBSTITUA AQUI pelo ID do usuário
  v_module_id UUID;
  v_modules_unlocked INTEGER := 0;
  v_user_exists BOOLEAN;
  v_user_username TEXT;
BEGIN
  -- Verificar se o usuário existe
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE user_id = v_user_id), 
         username 
  INTO v_user_exists, v_user_username
  FROM public.profiles 
  WHERE user_id = v_user_id;
  
  IF NOT v_user_exists THEN
    RAISE EXCEPTION 'Usuário com ID % não encontrado!', v_user_id;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Desbloqueando mentoria para: % (%)', v_user_username, v_user_id;
  RAISE NOTICE '========================================';
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
    
    GET DIAGNOSTICS v_modules_unlocked = ROW_COUNT;
  END LOOP;
  
  RAISE NOTICE '✅ Módulos desbloqueados com sucesso!';
  RAISE NOTICE '========================================';
END $$;

-- =====================================================

-- OPÇÃO 2: Desbloquear usando USERNAME (mais fácil)
-- Substitua 'NOME_DO_USUARIO' pelo username do aluno
DO $$
DECLARE
  v_username TEXT := 'NOME_DO_USUARIO';  -- ⚠️ SUBSTITUA AQUI pelo username
  v_user_id UUID;
  v_module_id UUID;
  v_modules_unlocked INTEGER := 0;
  v_user_exists BOOLEAN;
BEGIN
  -- Buscar user_id pelo username
  SELECT user_id INTO v_user_id
  FROM public.profiles 
  WHERE username = v_username;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário com username "%" não encontrado!', v_username;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Desbloqueando mentoria para: % (%)', v_username, v_user_id;
  RAISE NOTICE '========================================';
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
    
    GET DIAGNOSTICS v_modules_unlocked = ROW_COUNT;
  END LOOP;
  
  RAISE NOTICE '✅ Módulos desbloqueados com sucesso!';
  RAISE NOTICE '========================================';
END $$;

-- =====================================================

-- OPÇÃO 3: Desbloquear TODOS os usuários Diamond que ainda não têm módulos desbloqueados
-- Execute este para corrigir todos de uma vez

DO $$
DECLARE
  v_user RECORD;
  v_module_id UUID;
  v_total INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Desbloqueando mentoria para TODOS os Diamond sem acesso';
  RAISE NOTICE '========================================';
  
  -- Para cada usuário Diamond
  FOR v_user IN 
    SELECT DISTINCT p.user_id, p.username, p.full_name
    FROM public.profiles p
    WHERE p.subscription_plan = 'diamond'
    AND NOT EXISTS (
      SELECT 1 
      FROM public.unlocked_modules um
      INNER JOIN public.modules m ON m.id = um.module_id
      WHERE um.user_id = p.user_id 
      AND m.is_locked = true
      LIMIT 1
    )
  LOOP
    v_total := v_total + 1;
    RAISE NOTICE 'Processando: % (%)', v_user.username, v_user.user_id;
    
    -- Desbloquear todos os módulos bloqueados
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (v_user.user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
    END LOOP;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de usuários processados: %', v_total;
  RAISE NOTICE '========================================';
END $$;

-- =====================================================

-- VERIFICAÇÃO: Ver módulos desbloqueados de um usuário específico
-- Substitua 'USER_ID_AQUI' ou 'NOME_DO_USUARIO' e execute

SELECT 
  m.id as module_id,
  m.title,
  m.is_locked,
  um.created_at as desbloqueado_em
FROM public.unlocked_modules um
INNER JOIN public.modules m ON m.id = um.module_id
WHERE um.user_id = 'USER_ID_AQUI'  -- ⚠️ SUBSTITUA AQUI
  AND m.is_locked = true
ORDER BY m.title;

-- OU usando username:

SELECT 
  m.id as module_id,
  m.title,
  m.is_locked,
  um.created_at as desbloqueado_em
FROM public.unlocked_modules um
INNER JOIN public.modules m ON m.id = um.module_id
INNER JOIN public.profiles p ON p.user_id = um.user_id
WHERE p.username = 'NOME_DO_USUARIO'  -- ⚠️ SUBSTITUA AQUI
  AND m.is_locked = true
ORDER BY m.title;

