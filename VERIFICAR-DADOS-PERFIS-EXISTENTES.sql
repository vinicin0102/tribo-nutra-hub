-- =====================================================
-- 🔍 VERIFICAR DADOS DOS PERFIS EXISTENTES
-- =====================================================
-- Este script verifica quais perfis existem mas estão
-- sem dados (email, telefone, CPF)
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. RESUMO GERAL: Perfis vs Dados
SELECT 
  COUNT(DISTINCT p.user_id) as total_perfis,
  COUNT(DISTINCT CASE WHEN p.email IS NOT NULL THEN p.user_id END) as perfis_com_email,
  COUNT(DISTINCT CASE WHEN p.telefone IS NOT NULL THEN p.user_id END) as perfis_com_telefone,
  COUNT(DISTINCT CASE WHEN p.cpf IS NOT NULL THEN p.user_id END) as perfis_com_cpf,
  COUNT(DISTINCT CASE WHEN p.email IS NOT NULL AND p.telefone IS NOT NULL AND p.cpf IS NOT NULL THEN p.user_id END) as perfis_completos,
  COUNT(DISTINCT CASE WHEN p.email IS NULL OR p.telefone IS NULL OR p.cpf IS NULL THEN p.user_id END) as perfis_incompletos
FROM public.profiles p;

-- 2. PERFIS QUE EXISTEM MAS ESTÃO SEM DADOS
SELECT 
  p.user_id,
  p.username,
  p.email as email_perfil,
  p.telefone as telefone_perfil,
  p.cpf as cpf_perfil,
  p.full_name as nome_perfil,
  u.email as email_auth,
  u.raw_user_meta_data->>'telefone' as telefone_auth,
  u.raw_user_meta_data->>'cpf' as cpf_auth,
  u.raw_user_meta_data->>'full_name' as nome_auth,
  u.created_at as usuario_criado_em,
  u.last_sign_in_at as ultimo_login,
  CASE 
    WHEN p.email IS NULL AND u.email IS NOT NULL THEN '❌ Falta EMAIL'
    WHEN p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL THEN '❌ Falta TELEFONE'
    WHEN p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL THEN '❌ Falta CPF'
    WHEN p.email IS NULL AND p.telefone IS NULL AND p.cpf IS NULL THEN '❌ FALTA TUDO'
    ELSE '⚠️ Dados incompletos'
  END as status
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE (
  (p.email IS NULL AND u.email IS NOT NULL)
  OR (p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL)
  OR (p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL)
  OR (p.full_name IS NULL OR p.full_name = '') AND u.raw_user_meta_data->>'full_name' IS NOT NULL
)
ORDER BY 
  CASE 
    WHEN u.created_at >= CURRENT_DATE - INTERVAL '1 day' THEN 1
    WHEN u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN 1
    ELSE 2
  END,
  u.created_at DESC;

-- 3. PERFIS DE ONTEM QUE ESTÃO SEM DADOS
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.telefone,
  p.cpf,
  u.email as email_auth_users,
  u.raw_user_meta_data->>'telefone' as telefone_auth_users,
  u.raw_user_meta_data->>'cpf' as cpf_auth_users,
  u.created_at as criado_em,
  u.last_sign_in_at as ultimo_login,
  '❌ PERFIL EXISTE MAS SEM DADOS' as problema
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE (
  u.created_at >= CURRENT_DATE - INTERVAL '1 day'
  OR u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day'
)
AND (
  (p.email IS NULL AND u.email IS NOT NULL)
  OR (p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL)
  OR (p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL)
)
ORDER BY u.created_at DESC, u.last_sign_in_at DESC;

-- 4. COMPARAÇÃO: Dados em auth.users vs profiles
SELECT 
  COUNT(*) as total_usuarios_auth,
  COUNT(*) FILTER (WHERE email IS NOT NULL) as usuarios_com_email_auth,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'telefone' IS NOT NULL) as usuarios_com_telefone_auth,
  COUNT(*) FILTER (WHERE raw_user_meta_data->>'cpf' IS NOT NULL) as usuarios_com_cpf_auth
FROM auth.users;

SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE email IS NOT NULL) as perfis_com_email,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL) as perfis_com_telefone,
  COUNT(*) FILTER (WHERE cpf IS NOT NULL) as perfis_com_cpf
FROM public.profiles;

-- 5. DIFERENÇA: Dados disponíveis em auth.users mas não em profiles
SELECT 
  COUNT(*) as dados_perdidos,
  COUNT(*) FILTER (WHERE u.email IS NOT NULL AND p.email IS NULL) as emails_perdidos,
  COUNT(*) FILTER (WHERE u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL) as telefones_perdidos,
  COUNT(*) FILTER (WHERE u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL) as cpfs_perdidos
FROM auth.users u
JOIN public.profiles p ON p.user_id = u.id
WHERE (
  (u.email IS NOT NULL AND p.email IS NULL)
  OR (u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL)
  OR (u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL)
);

