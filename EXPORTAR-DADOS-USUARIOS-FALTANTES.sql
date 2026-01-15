-- =====================================================
-- 📊 EXPORTAR DADOS DOS USUÁRIOS FALTANTES
-- =====================================================
-- Este script exporta todos os dados dos usuários
-- que não têm perfil, para você verificar o que está faltando
-- Execute no Supabase SQL Editor e exporte para CSV
-- =====================================================

-- EXPORTAR TODOS OS DADOS DOS USUÁRIOS SEM PERFIL
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro,
  u.last_sign_in_at as ultimo_login,
  u.email_confirmed_at as email_confirmado,
  u.phone as telefone_auth,
  u.raw_user_meta_data->>'username' as username,
  u.raw_user_meta_data->>'full_name' as full_name,
  u.raw_user_meta_data->>'cpf' as cpf,
  u.raw_user_meta_data->>'telefone' as telefone_metadata,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento,
  u.raw_user_meta_data as todos_os_metadados,
  CASE 
    WHEN u.created_at >= CURRENT_DATE - INTERVAL '1 day' THEN 'Criado ontem'
    WHEN u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN 'Login ontem'
    ELSE 'Antigo'
  END as categoria,
  '❌ SEM PERFIL' as status
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
ORDER BY 
  CASE 
    WHEN u.created_at >= CURRENT_DATE - INTERVAL '1 day' THEN 1
    WHEN u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN 2
    ELSE 3
  END,
  u.created_at DESC;

-- VERSÃO SIMPLIFICADA (apenas dados essenciais)
SELECT 
  u.email,
  u.raw_user_meta_data->>'telefone' as telefone,
  u.raw_user_meta_data->>'cpf' as cpf,
  u.raw_user_meta_data->>'full_name' as nome_completo,
  u.created_at as data_cadastro,
  u.last_sign_in_at as ultimo_login
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
ORDER BY u.created_at DESC;

