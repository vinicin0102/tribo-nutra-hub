-- =====================================================
-- 🔴 FORÇAR ATUALIZAÇÃO DE TELEFONE E CPF
-- =====================================================
-- Este script força a atualização de telefone e CPF
-- de auth.users para profiles, mesmo que estejam vazios
-- Execute no Supabase SQL Editor
-- =====================================================

-- ATUALIZAR TODOS OS PERFIS COM DADOS DE auth.users
UPDATE public.profiles p
SET
  telefone = COALESCE(
    NULLIF(p.telefone, ''),
    NULLIF(u.raw_user_meta_data->>'telefone', ''),
    NULL
  ),
  cpf = COALESCE(
    NULLIF(p.cpf, ''),
    NULLIF(u.raw_user_meta_data->>'cpf', ''),
    NULL
  ),
  full_name = COALESCE(
    NULLIF(p.full_name, ''),
    NULLIF(u.raw_user_meta_data->>'full_name', ''),
    NULL
  ),
  data_nascimento = COALESCE(
    p.data_nascimento,
    CASE 
      WHEN u.raw_user_meta_data->>'data_nascimento' IS NOT NULL 
        AND u.raw_user_meta_data->>'data_nascimento' != ''
      THEN (u.raw_user_meta_data->>'data_nascimento')::DATE
      ELSE NULL
    END
  ),
  email = COALESCE(
    NULLIF(p.email, ''),
    u.email,
    NULL
  ),
  updated_at = NOW()
FROM auth.users u
WHERE p.user_id = u.id
  AND (
    -- Atualizar se telefone existe em auth mas não em profile
    (u.raw_user_meta_data->>'telefone' IS NOT NULL 
     AND u.raw_user_meta_data->>'telefone' != ''
     AND (p.telefone IS NULL OR p.telefone = ''))
    -- OU se CPF existe em auth mas não em profile
    OR (u.raw_user_meta_data->>'cpf' IS NOT NULL 
        AND u.raw_user_meta_data->>'cpf' != ''
        AND (p.cpf IS NULL OR p.cpf = ''))
    -- OU se nome existe em auth mas não em profile
    OR (u.raw_user_meta_data->>'full_name' IS NOT NULL 
        AND u.raw_user_meta_data->>'full_name' != ''
        AND (p.full_name IS NULL OR p.full_name = ''))
    -- OU se email existe em auth mas não em profile
    OR (u.email IS NOT NULL 
        AND (p.email IS NULL OR p.email = ''))
  );

-- Verificar quantos foram atualizados
SELECT 
  COUNT(*) as perfis_atualizados
FROM public.profiles p
WHERE p.updated_at >= NOW() - INTERVAL '5 minutes';

-- Verificar resultado final
SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL AND telefone != '') as perfis_com_telefone,
  COUNT(*) FILTER (WHERE cpf IS NOT NULL AND cpf != '') as perfis_com_cpf,
  COUNT(*) FILTER (WHERE email IS NOT NULL AND email != '') as perfis_com_email,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL AND telefone != '' 
                    AND cpf IS NOT NULL AND cpf != ''
                    AND email IS NOT NULL AND email != '') as perfis_completos
FROM public.profiles;

