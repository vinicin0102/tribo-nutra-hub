-- =====================================================
-- DIAGNÓSTICO: Verificar se a função RPC existe
-- =====================================================

-- 1. Verificar se a função existe
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments,
  prorettype::regtype as return_type
FROM pg_proc
WHERE proname = 'change_user_plan_admin';

-- 2. Se não retornar nada, a função não existe
-- Execute o SQL criar-funcao-change-plan-admin-final.sql

-- 3. Verificar permissões
SELECT 
  grantee,
  privilege_type
FROM information_schema.routine_privileges
WHERE routine_name = 'change_user_plan_admin';

-- 4. Testar a função manualmente (substitua USER_ID_AQUI)
-- SELECT change_user_plan_admin(
--   'USER_ID_AQUI'::UUID,
--   'diamond',
--   NULL
-- );

