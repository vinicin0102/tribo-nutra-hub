-- =====================================================
-- MIGRAR DADOS EXISTENTES DE auth.users PARA profiles
-- =====================================================
-- Este script migra CPF, data de nascimento, telefone e email
-- dos metadados de auth.users para a tabela profiles
-- Execute APÓS executar ADICIONAR-DADOS-PESSOAIS-PROFILES.sql
-- =====================================================

-- Migrar dados existentes de auth.users para profiles
UPDATE public.profiles p
SET 
  cpf = COALESCE(
    p.cpf, 
    (SELECT raw_user_meta_data->>'cpf' FROM auth.users WHERE id = p.user_id)
  ),
  data_nascimento = COALESCE(
    p.data_nascimento,
    CASE 
      WHEN (SELECT raw_user_meta_data->>'data_nascimento' FROM auth.users WHERE id = p.user_id) IS NOT NULL
      THEN (SELECT (raw_user_meta_data->>'data_nascimento')::DATE FROM auth.users WHERE id = p.user_id)
      ELSE NULL
    END
  ),
  telefone = COALESCE(
    p.telefone,
    (SELECT raw_user_meta_data->>'telefone' FROM auth.users WHERE id = p.user_id)
  ),
  email = COALESCE(
    p.email,
    (SELECT email FROM auth.users WHERE id = p.user_id)
  )
WHERE EXISTS (SELECT 1 FROM auth.users WHERE id = p.user_id);

-- Verificar quantos registros foram atualizados
SELECT 
  COUNT(*) FILTER (WHERE cpf IS NOT NULL) as perfis_com_cpf,
  COUNT(*) FILTER (WHERE data_nascimento IS NOT NULL) as perfis_com_data_nascimento,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL) as perfis_com_telefone,
  COUNT(*) FILTER (WHERE email IS NOT NULL) as perfis_com_email,
  COUNT(*) as total_perfis
FROM public.profiles;

-- =====================================================
-- APÓS EXECUTAR, OS DADOS EXISTENTES SERÃO MIGRADOS
-- =====================================================

