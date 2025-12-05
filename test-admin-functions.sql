-- =====================================================
-- SCRIPT DE TESTE PARA FUNÇÕES ADMIN
-- =====================================================
-- Execute este SQL para testar se as funções estão funcionando
-- =====================================================

-- 1. Verificar se as colunas existem
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'profiles' 
  AND column_name IN ('is_banned', 'banned_until', 'is_muted', 'mute_until')
ORDER BY column_name;

-- 2. Verificar se as funções existem
SELECT 
  routine_name, 
  routine_type,
  data_type as return_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('ban_user_temporary', 'mute_user', 'unban_user', 'unmute_user')
ORDER BY routine_name;

-- 3. Verificar permissões das funções
SELECT 
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  r.rolname as grantee
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_proc_acl pga ON p.oid = pga.oid
LEFT JOIN pg_roles r ON pga.grantee = r.oid
WHERE n.nspname = 'public' 
  AND p.proname IN ('ban_user_temporary', 'mute_user', 'unban_user', 'unmute_user')
ORDER BY p.proname;

-- 4. Listar alguns usuários para teste (substitua pelos IDs reais)
SELECT 
  user_id,
  username,
  is_banned,
  banned_until,
  is_muted,
  mute_until
FROM profiles
LIMIT 5;

-- 5. Testar função de ban (substitua 'USER_ID_AQUI' por um ID real)
-- SELECT ban_user_temporary('USER_ID_AQUI'::UUID, 3);

-- 6. Testar função de mute (substitua 'USER_ID_AQUI' por um ID real)
-- SELECT mute_user('USER_ID_AQUI'::UUID, 7);

-- =====================================================
-- Se alguma dessas queries retornar vazio, há um problema
-- =====================================================

