-- =====================================================
-- DIAGNÓSTICO COMPLETO - USUÁRIOS SEM PERFIL
-- =====================================================
-- Este script faz uma análise completa para entender
-- por que usuários não estão na tabela profiles
-- =====================================================

-- 1. VERIFICAR SE O TRIGGER EXISTE E ESTÁ ATIVO
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created'
  OR event_object_table = 'users';

-- 2. VERIFICAR SE A FUNÇÃO handle_new_user EXISTE
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

-- 3. CONTAR TOTAL DE USUÁRIOS EM auth.users
SELECT 
  COUNT(*) as total_usuarios_auth,
  COUNT(*) FILTER (WHERE email_confirmed_at IS NOT NULL) as usuarios_confirmados,
  COUNT(*) FILTER (WHERE email_confirmed_at IS NULL) as usuarios_nao_confirmados,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '1 day') as usuarios_ontem,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as usuarios_ultimos_7_dias
FROM auth.users;

-- 4. CONTAR TOTAL DE PERFIS EM profiles
SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '1 day') as perfis_ontem,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as perfis_ultimos_7_dias
FROM public.profiles;

-- 5. LISTAR TODOS OS USUÁRIOS DE ONTEM QUE NÃO TÊM PERFIL
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro_auth,
  u.email_confirmed_at as email_confirmado,
  u.raw_user_meta_data->>'username' as username_metadata,
  u.raw_user_meta_data->>'full_name' as full_name_metadata,
  u.raw_user_meta_data->>'cpf' as cpf_metadata,
  u.raw_user_meta_data->>'telefone' as telefone_metadata,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento_metadata,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ SEM PERFIL'
    ELSE '✅ TEM PERFIL'
  END as status
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE u.created_at >= CURRENT_DATE - INTERVAL '1 day'
ORDER BY u.created_at DESC;

-- 6. COMPARAÇÃO: USUÁRIOS vs PERFIS (últimos 7 dias)
SELECT 
  DATE(u.created_at) as data,
  COUNT(DISTINCT u.id) as usuarios_criados,
  COUNT(DISTINCT p.user_id) as perfis_criados,
  COUNT(DISTINCT u.id) - COUNT(DISTINCT p.user_id) as diferenca
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id AND DATE(p.created_at) = DATE(u.created_at)
WHERE u.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(u.created_at)
ORDER BY DATE(u.created_at) DESC;

-- 7. LISTAR TODOS OS USUÁRIOS SEM PERFIL (TODOS OS TEMPOS)
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro_auth,
  u.email_confirmed_at as email_confirmado,
  u.raw_user_meta_data->>'username' as username_metadata,
  u.raw_user_meta_data->>'full_name' as full_name_metadata,
  u.raw_user_meta_data->>'cpf' as cpf_metadata,
  u.raw_user_meta_data->>'telefone' as telefone_metadata,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ SEM PERFIL'
    ELSE '✅ TEM PERFIL'
  END as status
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE p.user_id IS NULL
ORDER BY u.created_at DESC;

-- 8. VERIFICAR POLÍTICAS RLS NA TABELA PROFILES
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'profiles';

-- 9. TESTAR SE A FUNÇÃO CONSEGUE INSERIR (simulação)
-- Esta query mostra o que a função tentaria inserir
SELECT 
  u.id as user_id,
  COALESCE(
    u.raw_user_meta_data->>'username',
    split_part(u.email, '@', 1)
  ) as username_que_seria_criado,
  COALESCE(u.raw_user_meta_data->>'full_name', '') as full_name_que_seria_criado,
  u.raw_user_meta_data->>'cpf' as cpf_que_seria_criado,
  u.raw_user_meta_data->>'telefone' as telefone_que_seria_criado,
  u.email as email_que_seria_criado
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
LIMIT 10;

