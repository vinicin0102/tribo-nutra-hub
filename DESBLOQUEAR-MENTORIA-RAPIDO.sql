-- =====================================================
-- DESBLOQUEAR MENTORIA PARA UM ALUNO DIAMOND
-- VERSÃO SIMPLES - USE APENAS O USERNAME
-- =====================================================

-- PASSO 1: Encontre o username do aluno que você passou para Diamond
-- Execute esta query para listar usuários Diamond:

SELECT user_id, username, full_name, subscription_plan 
FROM public.profiles 
WHERE subscription_plan = 'diamond'
ORDER BY username;

-- PASSO 2: Copie o username do aluno e cole na linha abaixo, depois execute apenas esta parte:

DO $$
DECLARE
  v_username TEXT := 'COLE_O_USERNAME_AQUI';  -- ⚠️ SUBSTITUA pelo username do aluno
  v_user_id UUID;
  v_module_id UUID;
  v_total_modulos INTEGER := 0;
BEGIN
  -- Buscar user_id pelo username
  SELECT user_id INTO v_user_id
  FROM public.profiles 
  WHERE username = v_username;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuário "%" não encontrado! Verifique o username.', v_username;
  END IF;
  
  -- Verificar se é Diamond
  IF NOT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = v_user_id AND subscription_plan = 'diamond'
  ) THEN
    RAISE WARNING '⚠️  Usuário "%" não tem plano Diamond! Desbloqueando mesmo assim...', v_username;
  END IF;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Desbloqueando mentoria para: %', v_username;
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE '========================================';
  
  -- Desbloquear TODOS os módulos bloqueados
  FOR v_module_id IN 
    SELECT id FROM public.modules WHERE is_locked = true
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (v_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
    
    v_total_modulos := v_total_modulos + 1;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ SUCESSO!';
  RAISE NOTICE '   % módulos bloqueados desbloqueados para %', v_total_modulos, v_username;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 3: Verificar se funcionou
-- Execute esta query substituindo 'COLE_O_USERNAME_AQUI' pelo username:

SELECT 
  p.username,
  p.subscription_plan,
  COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) as modulos_mentoria_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ ACESSO COMPLETO À MENTORIA'
    ELSE '❌ AINDA SEM ACESSO'
  END as status
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.username = 'COLE_O_USERNAME_AQUI'  -- ⚠️ SUBSTITUA pelo username
GROUP BY p.username, p.subscription_plan;

