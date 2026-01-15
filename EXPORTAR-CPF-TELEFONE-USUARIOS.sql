-- =====================================================
-- EXPORTAR CPF E TELEFONE DOS USUÁRIOS EXISTENTES
-- =====================================================
-- Este script lista todos os CPFs e telefones dos usuários
-- que já estão cadastrados na comunidade
-- Execute no Supabase SQL Editor
-- =====================================================

-- Listar CPF e telefone de todos os usuários
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.email,
  COALESCE(
    p.cpf,
    (SELECT raw_user_meta_data->>'cpf' FROM auth.users WHERE id = p.user_id)
  ) as cpf,
  COALESCE(
    p.telefone,
    (SELECT raw_user_meta_data->>'telefone' FROM auth.users WHERE id = p.user_id)
  ) as telefone,
  COALESCE(
    p.data_nascimento,
    CASE 
      WHEN (SELECT raw_user_meta_data->>'data_nascimento' FROM auth.users WHERE id = p.user_id) IS NOT NULL
      THEN (SELECT (raw_user_meta_data->>'data_nascimento')::DATE FROM auth.users WHERE id = p.user_id)
      ELSE NULL
    END
  ) as data_nascimento,
  p.created_at as data_cadastro
FROM public.profiles p
ORDER BY p.created_at DESC;

-- =====================================================
-- VERSÃO SIMPLIFICADA - APENAS CPF E TELEFONE
-- =====================================================
SELECT 
  p.username,
  p.full_name,
  p.email,
  COALESCE(
    p.cpf,
    (SELECT raw_user_meta_data->>'cpf' FROM auth.users WHERE id = p.user_id)
  ) as cpf,
  COALESCE(
    p.telefone,
    (SELECT raw_user_meta_data->>'telefone' FROM auth.users WHERE id = p.user_id)
  ) as telefone
FROM public.profiles p
WHERE 
  COALESCE(
    p.cpf,
    (SELECT raw_user_meta_data->>'cpf' FROM auth.users WHERE id = p.user_id)
  ) IS NOT NULL
  OR COALESCE(
    p.telefone,
    (SELECT raw_user_meta_data->>'telefone' FROM auth.users WHERE id = p.user_id)
  ) IS NOT NULL
ORDER BY p.username;

-- =====================================================
-- CONTAGEM DE USUÁRIOS COM DADOS
-- =====================================================
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(COALESCE(
    p.cpf,
    (SELECT raw_user_meta_data->>'cpf' FROM auth.users WHERE id = p.user_id)
  )) as usuarios_com_cpf,
  COUNT(COALESCE(
    p.telefone,
    (SELECT raw_user_meta_data->>'telefone' FROM auth.users WHERE id = p.user_id)
  )) as usuarios_com_telefone,
  COUNT(COALESCE(
    p.data_nascimento,
    CASE 
      WHEN (SELECT raw_user_meta_data->>'data_nascimento' FROM auth.users WHERE id = p.user_id) IS NOT NULL
      THEN (SELECT (raw_user_meta_data->>'data_nascimento')::DATE FROM auth.users WHERE id = p.user_id)
      ELSE NULL
    END
  )) as usuarios_com_data_nascimento
FROM public.profiles p;

