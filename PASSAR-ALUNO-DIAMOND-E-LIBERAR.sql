-- =====================================================
-- PASSAR ALUNO PARA DIAMOND E LIBERAR MENTORIA DE UMA VEZ
-- Use este script quando passar alguém para Diamond manualmente
-- =====================================================

-- SUBSTITUA os valores abaixo:
-- 1. 'USER_ID_AQUI' pelo ID do usuário (UUID)
-- 2. 'DATA_EXPIRACAO' pela data de expiração (ex: '2025-12-31 23:59:59')

-- =====================================================

-- OPÇÃO 1: Passar para Diamond usando USER_ID e liberar mentoria imediatamente

DO $$
DECLARE
  v_user_id UUID := 'USER_ID_AQUI';  -- ⚠️ SUBSTITUA pelo ID do usuário
  v_expires_at TIMESTAMP WITH TIME ZONE := '2025-12-31 23:59:59'::TIMESTAMP WITH TIME ZONE;  -- ⚠️ SUBSTITUA pela data de expiração
  v_module_id UUID;
  v_old_plan TEXT;
  v_username TEXT;
BEGIN
  -- Verificar se usuário existe e pegar plano atual
  SELECT subscription_plan, username INTO v_old_plan, v_username
  FROM public.profiles 
  WHERE user_id = v_user_id;
  
  IF v_username IS NULL THEN
    RAISE EXCEPTION 'Usuário com ID % não encontrado!', v_user_id;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Passando usuário % (%) para Diamond', v_username, v_user_id;
  RAISE NOTICE 'Plano atual: %', COALESCE(v_old_plan, 'NULL');
  RAISE NOTICE '========================================';
  
  -- Atualizar plano para Diamond
  UPDATE public.profiles
  SET 
    subscription_plan = 'diamond',
    subscription_expires_at = v_expires_at,
    updated_at = NOW()
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '✅ Plano atualizado para Diamond';
  
  -- LIBERAR MENTORIA IMEDIATAMENTE (chama a função diretamente)
  RAISE NOTICE '';
  RAISE NOTICE 'Liberando mentoria...';
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '✅ Mentoria liberada com sucesso!';
  RAISE NOTICE '========================================';
END $$;

-- =====================================================

-- OPÇÃO 2: Passar para Diamond usando USERNAME (mais fácil)

DO $$
DECLARE
  v_username TEXT := 'NOME_DO_USUARIO';  -- ⚠️ SUBSTITUA pelo username
  v_expires_at TIMESTAMP WITH TIME ZONE := '2025-12-31 23:59:59'::TIMESTAMP WITH TIME ZONE;  -- ⚠️ SUBSTITUA pela data
  v_user_id UUID;
  v_module_id UUID;
  v_old_plan TEXT;
BEGIN
  -- Buscar user_id pelo username
  SELECT user_id, subscription_plan INTO v_user_id, v_old_plan
  FROM public.profiles 
  WHERE username = v_username;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário com username "%" não encontrado!', v_username;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Passando usuário % (%) para Diamond', v_username, v_user_id;
  RAISE NOTICE 'Plano atual: %', COALESCE(v_old_plan, 'NULL');
  RAISE NOTICE '========================================';
  
  -- Atualizar plano para Diamond
  UPDATE public.profiles
  SET 
    subscription_plan = 'diamond',
    subscription_expires_at = v_expires_at,
    updated_at = NOW()
  WHERE user_id = v_user_id;
  
  RAISE NOTICE '✅ Plano atualizado para Diamond';
  
  -- LIBERAR MENTORIA IMEDIATAMENTE
  RAISE NOTICE '';
  RAISE NOTICE 'Liberando mentoria...';
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '✅ Mentoria liberada com sucesso!';
  RAISE NOTICE '========================================';
END $$;

-- =====================================================

-- OPÇÃO 3: Se você JÁ passou o aluno para Diamond e só precisa liberar a mentoria
-- Use esta versão simplificada

DO $$
DECLARE
  v_username TEXT := 'NOME_DO_USUARIO';  -- ⚠️ SUBSTITUA pelo username
  v_user_id UUID;
  v_module_id UUID;
BEGIN
  -- Buscar user_id
  SELECT user_id INTO v_user_id
  FROM public.profiles 
  WHERE username = v_username;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário "%" não encontrado!', v_username;
  END IF;
  
  RAISE NOTICE 'Liberando mentoria para %...', v_username;
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '✅ Concluído!';
END $$;

-- =====================================================

-- VERIFICAÇÃO: Ver se o aluno tem acesso à mentoria
-- Substitua 'NOME_DO_USUARIO' e execute

SELECT 
  p.username,
  p.subscription_plan,
  COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) as modulos_mentoria_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ ACESSO COMPLETO'
    ELSE '❌ SEM ACESSO'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.username = 'NOME_DO_USUARIO'  -- ⚠️ SUBSTITUA AQUI
GROUP BY p.username, p.subscription_plan;

