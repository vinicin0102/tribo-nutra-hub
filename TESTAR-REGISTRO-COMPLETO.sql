-- =====================================================
-- 🧪 TESTE COMPLETO: VERIFICAR SE REGISTRO ESTÁ FUNCIONANDO
-- =====================================================
-- Este script verifica se o sistema de registro está
-- salvando todos os dados corretamente
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. VERIFICAR SE O TRIGGER EXISTE E ESTÁ ATIVO
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement,
  CASE 
    WHEN trigger_name = 'on_auth_user_created' THEN '✅ TRIGGER EXISTE'
    ELSE '❌ TRIGGER NÃO ENCONTRADO'
  END as status_trigger
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created'
   OR event_object_table = 'users';

-- 2. VERIFICAR SE A FUNÇÃO handle_new_user EXISTE
SELECT 
  routine_name,
  routine_type,
  CASE 
    WHEN routine_name = 'handle_new_user' THEN '✅ FUNÇÃO EXISTE'
    ELSE '❌ FUNÇÃO NÃO ENCONTRADA'
  END as status_funcao
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

-- 3. VERIFICAR SE AS COLUNAS EXISTEM NA TABELA PROFILES
SELECT 
  column_name,
  data_type,
  is_nullable,
  CASE 
    WHEN column_name IN ('email', 'cpf', 'telefone', 'data_nascimento', 'full_name', 'username') 
    THEN '✅ COLUNA EXISTE'
    ELSE '⚠️ COLUNA OPCIONAL'
  END as status_coluna
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name IN ('email', 'cpf', 'telefone', 'data_nascimento', 'full_name', 'username', 'user_id', 'points')
ORDER BY column_name;

-- 4. VERIFICAR ÚLTIMOS 5 USUÁRIOS CRIADOS E SEUS PERFIS
SELECT 
  u.id as user_id,
  u.email as email_auth,
  u.created_at as usuario_criado_em,
  u.raw_user_meta_data->>'username' as username_metadata,
  u.raw_user_meta_data->>'full_name' as full_name_metadata,
  u.raw_user_meta_data->>'cpf' as cpf_metadata,
  u.raw_user_meta_data->>'telefone' as telefone_metadata,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento_metadata,
  p.username as username_profile,
  p.full_name as full_name_profile,
  p.email as email_profile,
  p.cpf as cpf_profile,
  p.telefone as telefone_profile,
  p.data_nascimento as data_nascimento_profile,
  p.created_at as perfil_criado_em,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ PERFIL NÃO CRIADO'
    WHEN p.email IS NULL AND u.email IS NOT NULL THEN '⚠️ PERFIL CRIADO MAS SEM EMAIL'
    WHEN p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL THEN '⚠️ PERFIL CRIADO MAS SEM TELEFONE'
    WHEN p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL THEN '⚠️ PERFIL CRIADO MAS SEM CPF'
    WHEN p.full_name IS NULL AND u.raw_user_meta_data->>'full_name' IS NOT NULL THEN '⚠️ PERFIL CRIADO MAS SEM NOME'
    ELSE '✅ PERFIL COMPLETO'
  END as status
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 5;

-- 5. ESTATÍSTICAS: Quantos perfis estão completos vs incompletos
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(p.user_id) as total_perfis_criados,
  COUNT(*) FILTER (WHERE p.user_id IS NULL) as usuarios_sem_perfil,
  COUNT(*) FILTER (WHERE p.user_id IS NOT NULL 
                   AND p.email IS NOT NULL 
                   AND p.telefone IS NOT NULL 
                   AND p.cpf IS NOT NULL 
                   AND p.full_name IS NOT NULL) as perfis_completos,
  COUNT(*) FILTER (WHERE p.user_id IS NOT NULL 
                   AND (p.email IS NULL 
                        OR p.telefone IS NULL 
                        OR p.cpf IS NULL 
                        OR p.full_name IS NULL)) as perfis_incompletos
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id;

-- 6. VERIFICAR USUÁRIOS CRIADOS NAS ÚLTIMAS 24H
SELECT 
  COUNT(*) as usuarios_criados_ultimas_24h,
  COUNT(p.user_id) as perfis_criados_ultimas_24h,
  COUNT(*) FILTER (WHERE p.user_id IS NOT NULL 
                   AND p.email IS NOT NULL 
                   AND p.telefone IS NOT NULL 
                   AND p.cpf IS NOT NULL) as perfis_completos_ultimas_24h,
  COUNT(*) FILTER (WHERE p.user_id IS NULL) as usuarios_sem_perfil_ultimas_24h
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '24 hours';

-- 7. LISTAR USUÁRIOS RECENTES COM PROBLEMAS
SELECT 
  u.id,
  u.email,
  u.created_at,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ SEM PERFIL'
    WHEN p.email IS NULL THEN '⚠️ SEM EMAIL NO PERFIL'
    WHEN p.telefone IS NULL THEN '⚠️ SEM TELEFONE NO PERFIL'
    WHEN p.cpf IS NULL THEN '⚠️ SEM CPF NO PERFIL'
    WHEN p.full_name IS NULL THEN '⚠️ SEM NOME NO PERFIL'
    ELSE '✅ OK'
  END as problema,
  u.raw_user_meta_data as dados_em_auth
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '7 days'
  AND (
    p.user_id IS NULL
    OR p.email IS NULL
    OR p.telefone IS NULL
    OR p.cpf IS NULL
    OR p.full_name IS NULL
  )
ORDER BY u.created_at DESC
LIMIT 10;

-- 8. VERIFICAR SE A FUNÇÃO ESTÁ CORRETA (ver definição)
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

-- 9. TESTE FINAL: Verificar se todos os dados estão sendo salvos
SELECT 
  'RESUMO FINAL' as teste,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_auth,
  (SELECT COUNT(*) FROM public.profiles) as total_perfis,
  (SELECT COUNT(*) FROM auth.users WHERE created_at >= NOW() - INTERVAL '24 hours') as usuarios_hoje,
  (SELECT COUNT(*) FROM public.profiles WHERE created_at >= NOW() - INTERVAL '24 hours') as perfis_hoje,
  CASE 
    WHEN (SELECT COUNT(*) FROM auth.users) = (SELECT COUNT(*) FROM public.profiles)
    THEN '✅ Todos os usuários têm perfil'
    ELSE '❌ Alguns usuários não têm perfil'
  END as status_perfis,
  CASE 
    WHEN (SELECT COUNT(*) FROM public.profiles 
          WHERE email IS NOT NULL 
          AND telefone IS NOT NULL 
          AND cpf IS NOT NULL 
          AND full_name IS NOT NULL) = (SELECT COUNT(*) FROM public.profiles)
    THEN '✅ Todos os perfis têm dados completos'
    ELSE '⚠️ Alguns perfis estão incompletos'
  END as status_dados;

