-- =====================================================
-- 🔴 URGENTE: VERIFICAR LOGINS FALTANTES
-- =====================================================
-- Este script verifica se usuários que fizeram login
-- estão aparecendo nas tabelas profiles
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. CONTAR USUÁRIOS QUE FIZERAM LOGIN ONTEM
SELECT 
  COUNT(*) as usuarios_login_ontem,
  COUNT(*) FILTER (WHERE email_confirmed_at IS NOT NULL) as usuarios_confirmados_ontem
FROM auth.users
WHERE created_at >= CURRENT_DATE - INTERVAL '1 day'
   OR last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day';

-- 2. CONTAR PERFIS CRIADOS ONTEM
SELECT 
  COUNT(*) as perfis_criados_ontem
FROM public.profiles
WHERE created_at >= CURRENT_DATE - INTERVAL '1 day';

-- 3. USUÁRIOS QUE FIZERAM LOGIN ONTEM MAS NÃO TÊM PERFIL
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro,
  u.last_sign_in_at as ultimo_login,
  u.email_confirmed_at as email_confirmado,
  u.raw_user_meta_data->>'username' as username_metadata,
  u.raw_user_meta_data->>'full_name' as full_name_metadata,
  u.raw_user_meta_data->>'cpf' as cpf_metadata,
  u.raw_user_meta_data->>'telefone' as telefone_metadata,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento_metadata,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ SEM PERFIL - DADOS PERDIDOS!'
    ELSE '✅ TEM PERFIL'
  END as status
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE (
  u.created_at >= CURRENT_DATE - INTERVAL '1 day'
  OR u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day'
)
AND p.user_id IS NULL
ORDER BY u.created_at DESC, u.last_sign_in_at DESC;

-- 4. CONTAR QUANTOS USUÁRIOS ESTÃO SEM PERFIL (TODOS OS TEMPOS)
SELECT 
  COUNT(*) as total_usuarios_sem_perfil
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
);

-- 5. LISTAR TODOS OS USUÁRIOS SEM PERFIL COM SEUS DADOS
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro,
  u.last_sign_in_at as ultimo_login,
  u.email_confirmed_at as email_confirmado,
  u.raw_user_meta_data->>'username' as username,
  u.raw_user_meta_data->>'full_name' as full_name,
  u.raw_user_meta_data->>'cpf' as cpf,
  u.raw_user_meta_data->>'telefone' as telefone,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento,
  '❌ SEM PERFIL' as status
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
ORDER BY u.created_at DESC
LIMIT 100;

-- 6. VERIFICAR SE O TRIGGER ESTÁ ATIVO
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created'
   OR event_object_table = 'users';

-- 7. COMPARAÇÃO: USUÁRIOS vs PERFIS (últimos 7 dias)
SELECT 
  DATE(COALESCE(u.created_at, u.last_sign_in_at)) as data,
  COUNT(DISTINCT u.id) as usuarios_criados_ou_login,
  COUNT(DISTINCT p.user_id) as perfis_criados,
  COUNT(DISTINCT u.id) - COUNT(DISTINCT p.user_id) as usuarios_sem_perfil
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id 
  AND DATE(p.created_at) = DATE(COALESCE(u.created_at, u.last_sign_in_at))
WHERE u.created_at >= CURRENT_DATE - INTERVAL '7 days'
   OR u.last_sign_in_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(COALESCE(u.created_at, u.last_sign_in_at))
ORDER BY DATE(COALESCE(u.created_at, u.last_sign_in_at)) DESC;

