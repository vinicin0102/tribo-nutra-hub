-- =====================================================
-- LIBERAÇÃO DEFINITIVA PARA TODOS OS DIAMOND
-- Este script PROCESSA TODOS OS USUÁRIOS DIAMOND SEM EXCEÇÃO
-- =====================================================

-- PASSO 1: IDENTIFICAR TODOS OS POSSÍVEIS USUÁRIOS DIAMOND
-- Mostra TODOS os candidatos (mesmo que subscription_plan não esteja correto)

SELECT '=== IDENTIFICANDO TODOS OS USUÁRIOS DIAMOND ===' as etapa;

-- Lista TODOS que podem ser Diamond
WITH todos_diamond AS (
  SELECT DISTINCT p.user_id, p.username, p.full_name, p.subscription_plan, p.subscription_expires_at
  FROM public.profiles p
  WHERE 
    -- Tem subscription_plan = 'diamond'
    p.subscription_plan = 'diamond'
    -- OU tem subscription_expires_at preenchido (pode ter sido dado manualmente)
    OR p.subscription_expires_at IS NOT NULL
)
SELECT 
  user_id,
  username,
  full_name,
  subscription_plan,
  subscription_expires_at,
  CASE 
    WHEN subscription_plan = 'diamond' THEN '✅ Plano correto'
    WHEN subscription_expires_at IS NOT NULL THEN '⚠️ Precisa corrigir plano'
    ELSE '❓ Verificar'
  END as acao_necessaria
FROM todos_diamond
ORDER BY username;

-- PASSO 2: GARANTIR QUE TODOS TENHAM subscription_plan = 'diamond'
-- Atualiza TODOS que têm subscription_expires_at mas não têm subscription_plan = 'diamond'

UPDATE public.profiles
SET subscription_plan = 'diamond'
WHERE subscription_expires_at IS NOT NULL
  AND (subscription_plan IS NULL OR subscription_plan != 'diamond');

-- Mostra quantos foram corrigidos
SELECT 
  COUNT(*) as usuarios_corrigidos
FROM public.profiles
WHERE subscription_plan = 'diamond'
  AND subscription_expires_at IS NOT NULL
  AND updated_at >= NOW() - INTERVAL '1 minute';

-- PASSO 3: LIBERAR MENTORIA PARA TODOS OS DIAMOND
-- Processa CADA usuário Diamond encontrado

DO $$
DECLARE
  v_user RECORD;
  v_module_id UUID;
  v_total_usuarios INTEGER := 0;
  v_total_modulos INTEGER := 0;
  v_usuario_atual INTEGER := 0;
  v_inseridos INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'INICIANDO LIBERAÇÃO PARA TODOS OS DIAMOND';
  RAISE NOTICE '========================================';
  
  -- Contar módulos bloqueados
  SELECT COUNT(*) INTO v_total_modulos
  FROM public.modules 
  WHERE is_locked = true;
  
  RAISE NOTICE 'Módulos bloqueados encontrados: %', v_total_modulos;
  RAISE NOTICE '';
  
  -- Para CADA usuário Diamond (sem exceções)
  FOR v_user IN 
    SELECT DISTINCT user_id, username, full_name
    FROM public.profiles 
    WHERE subscription_plan = 'diamond'
    ORDER BY user_id
  LOOP
    v_total_usuarios := v_total_usuarios + 1;
    v_usuario_atual := v_usuario_atual + 1;
    
    -- Desbloquear TODOS os módulos bloqueados
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (v_user.user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
    END LOOP;
    
    -- A cada 5 usuários, mostrar progresso
    IF v_usuario_atual % 5 = 0 THEN
      RAISE NOTICE 'Progresso: % usuários processados', v_usuario_atual;
    END IF;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'CONCLUÍDO!';
  RAISE NOTICE 'Total de usuários Diamond processados: %', v_total_usuarios;
  RAISE NOTICE 'Total de módulos bloqueados: %', v_total_modulos;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 4: VERIFICAÇÃO FINAL - Mostra TODOS os Diamond e seus status

SELECT '=== VERIFICAÇÃO FINAL ===' as etapa;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.subscription_plan,
  COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) as modulos_bloqueados_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  CASE 
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
    THEN '✅ COMPLETO'
    WHEN COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) = 0 OR COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true) IS NULL
    THEN '❌ SEM ACESSO'
    ELSE '⚠️ INCOMPLETO'
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

-- PASSO 5: Se ainda houver alguém incompleto, lista para correção manual

SELECT '=== USUÁRIOS QUE AINDA PRECISAM DE ATENÇÃO ===' as etapa;

SELECT 
  p.user_id,
  p.username,
  p.full_name,
  COALESCE(COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true), 0) as modulos_desbloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) as total_modulos_bloqueados,
  (SELECT COUNT(*) FROM public.modules WHERE is_locked = true) - COALESCE(COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true), 0) as faltando
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name
HAVING COALESCE(COUNT(DISTINCT um.module_id) FILTER (WHERE m.is_locked = true), 0) < (SELECT COUNT(*) FROM public.modules WHERE is_locked = true)
ORDER BY faltando DESC, p.username;

