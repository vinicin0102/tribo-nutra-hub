-- =====================================================
-- DIAGNÓSTICO COMPLETO - FUNÇÕES ADMIN
-- =====================================================
-- Execute este SQL para verificar o que está faltando
-- =====================================================

-- 1. VERIFICAR SE AS COLUNAS EXISTEM
SELECT 
  'COLUNAS' as tipo,
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
  AND column_name IN ('is_banned', 'banned_until', 'is_muted', 'mute_until', 'email')
ORDER BY column_name;

-- 2. VERIFICAR SE AS FUNÇÕES EXISTEM
SELECT 
  'FUNÇÕES' as tipo,
  routine_name, 
  routine_type,
  data_type as return_type,
  routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('ban_user_temporary', 'mute_user', 'unban_user', 'unmute_user')
ORDER BY routine_name;

-- 3. VERIFICAR PERMISSÕES DAS FUNÇÕES
SELECT 
  'PERMISSÕES' as tipo,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as arguments,
  CASE 
    WHEN p.prosecdef THEN 'SECURITY DEFINER'
    ELSE 'SECURITY INVOKER'
  END as security_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
  AND p.proname IN ('ban_user_temporary', 'mute_user', 'unban_user', 'unmute_user')
ORDER BY p.proname;

-- 4. TESTAR FUNÇÃO DE BAN (substitua pelo user_id real de um usuário de teste)
-- Descomente e substitua 'USER_ID_AQUI' por um ID real:
/*
SELECT ban_user_temporary('USER_ID_AQUI'::UUID, 3);
*/

-- 5. VERIFICAR USUÁRIOS PARA TESTE
SELECT 
  'USUÁRIOS' as tipo,
  user_id,
  username,
  email,
  is_banned,
  banned_until,
  is_muted,
  mute_until
FROM profiles
ORDER BY created_at DESC
LIMIT 5;

-- 6. VERIFICAR SE HÁ ERROS NAS FUNÇÕES
SELECT 
  'STATUS' as tipo,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'is_banned'
    ) THEN '✅ Coluna is_banned existe'
    ELSE '❌ Coluna is_banned NÃO existe'
  END as status_is_banned,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'ban_user_temporary'
    ) THEN '✅ Função ban_user_temporary existe'
    ELSE '❌ Função ban_user_temporary NÃO existe'
  END as status_ban_function,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'mute_user'
    ) THEN '✅ Função mute_user existe'
    ELSE '❌ Função mute_user NÃO existe'
  END as status_mute_function;

