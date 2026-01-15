-- =====================================================
-- 🔍 VERIFICAR SE OS DADOS EXISTEM EM auth.users
-- =====================================================
-- Este script verifica se telefone e CPF estão em
-- auth.users.raw_user_meta_data mas não em profiles
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. Verificar quantos usuários têm telefone em auth.users
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'telefone' IS NOT NULL) as usuarios_com_telefone_metadata,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'cpf' IS NOT NULL) as usuarios_com_cpf_metadata,
  COUNT(*) FILTER (WHERE phone IS NOT NULL) as usuarios_com_phone_auth
FROM auth.users;

-- 2. Verificar quantos perfis têm telefone/CPF
SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL) as perfis_com_telefone,
  COUNT(*) FILTER (WHERE cpf IS NOT NULL) as perfis_com_cpf
FROM public.profiles;

-- 3. COMPARAÇÃO: Dados em auth.users vs profiles
SELECT 
  COUNT(*) as usuarios_com_dados_em_auth_mas_nao_em_profiles,
  COUNT(*) FILTER (WHERE u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL) as telefones_perdidos,
  COUNT(*) FILTER (WHERE u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL) as cpfs_perdidos
FROM auth.users u
JOIN public.profiles p ON p.user_id = u.id
WHERE (
  (u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL)
  OR (u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL)
);

-- 4. LISTAR USUÁRIOS COM DADOS EM auth.users MAS NÃO EM profiles
SELECT 
  u.id as user_id,
  u.email,
  u.raw_user_meta_data->>'telefone' as telefone_em_auth,
  u.raw_user_meta_data->>'cpf' as cpf_em_auth,
  u.raw_user_meta_data->>'full_name' as nome_em_auth,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento_em_auth,
  p.telefone as telefone_em_profile,
  p.cpf as cpf_em_profile,
  p.full_name as nome_em_profile,
  p.data_nascimento as data_nascimento_em_profile,
  CASE 
    WHEN u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL THEN '❌ Telefone em auth mas não em profile'
    WHEN u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL THEN '❌ CPF em auth mas não em profile'
    ELSE '⚠️ Dados diferentes'
  END as problema
FROM auth.users u
JOIN public.profiles p ON p.user_id = u.id
WHERE (
  (u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL)
  OR (u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL)
  OR (u.raw_user_meta_data->>'full_name' IS NOT NULL AND (p.full_name IS NULL OR p.full_name = ''))
)
ORDER BY u.created_at DESC;

-- 5. Verificar TODOS os metadados disponíveis (para debug)
SELECT 
  u.id,
  u.email,
  u.raw_user_meta_data as todos_os_metadados,
  p.telefone as telefone_profile,
  p.cpf as cpf_profile
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE u.raw_user_meta_data IS NOT NULL
ORDER BY u.created_at DESC
LIMIT 10;

