-- =====================================================
-- 🔴 URGENTE: ATUALIZAR DADOS DOS PERFIS EXISTENTES
-- =====================================================
-- Este script atualiza perfis que JÁ EXISTEM mas estão
-- sem dados (email, telefone, CPF) com os dados de auth.users
-- Execute no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Verificar quantos perfis estão sem dados
SELECT 
  COUNT(*) as perfis_sem_email,
  COUNT(*) FILTER (WHERE telefone IS NULL) as perfis_sem_telefone,
  COUNT(*) FILTER (WHERE cpf IS NULL) as perfis_sem_cpf,
  COUNT(*) FILTER (WHERE email IS NULL OR telefone IS NULL OR cpf IS NULL) as perfis_com_dados_faltantes
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE p.email IS NULL 
   OR p.telefone IS NULL 
   OR p.cpf IS NULL
   OR (u.raw_user_meta_data->>'telefone' IS NOT NULL AND p.telefone IS NULL)
   OR (u.raw_user_meta_data->>'cpf' IS NOT NULL AND p.cpf IS NULL);

-- PASSO 2: Listar perfis que precisam ser atualizados
SELECT 
  p.user_id,
  p.username,
  p.email as email_atual,
  p.telefone as telefone_atual,
  p.cpf as cpf_atual,
  u.email as email_auth,
  u.raw_user_meta_data->>'telefone' as telefone_auth,
  u.raw_user_meta_data->>'cpf' as cpf_auth,
  u.raw_user_meta_data->>'full_name' as full_name_auth,
  u.raw_user_meta_data->>'data_nascimento' as data_nascimento_auth,
  CASE 
    WHEN p.email IS NULL AND u.email IS NOT NULL THEN '❌ Falta EMAIL'
    WHEN p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL THEN '❌ Falta TELEFONE'
    WHEN p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL THEN '❌ Falta CPF'
    ELSE '⚠️ Dados incompletos'
  END as status
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE (
  (p.email IS NULL AND u.email IS NOT NULL)
  OR (p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL)
  OR (p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL)
  OR (p.full_name IS NULL AND u.raw_user_meta_data->>'full_name' IS NOT NULL)
  OR (p.data_nascimento IS NULL AND u.raw_user_meta_data->>'data_nascimento' IS NOT NULL)
)
ORDER BY u.created_at DESC
LIMIT 100;

-- PASSO 3: ATUALIZAR TODOS OS PERFIS COM DADOS DE auth.users
DO $$
DECLARE
  v_profile RECORD;
  v_atualizados INTEGER := 0;
  v_com_erro INTEGER := 0;
  v_total_processados INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔴 ATUALIZANDO DADOS DOS PERFIS...';
  RAISE NOTICE '========================================';
  
  FOR v_profile IN 
    SELECT 
      p.user_id,
      p.id as profile_id,
      p.email as email_atual,
      p.telefone as telefone_atual,
      p.cpf as cpf_atual,
      p.full_name as full_name_atual,
      p.data_nascimento as data_nascimento_atual,
      u.email as email_auth,
      u.raw_user_meta_data->>'telefone' as telefone_auth,
      u.raw_user_meta_data->>'cpf' as cpf_auth,
      u.raw_user_meta_data->>'full_name' as full_name_auth,
      u.raw_user_meta_data->>'data_nascimento' as data_nascimento_auth,
      u.created_at as usuario_criado_em
    FROM public.profiles p
    JOIN auth.users u ON u.id = p.user_id
    WHERE (
      (p.email IS NULL AND u.email IS NOT NULL)
      OR (p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL)
      OR (p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL)
      OR (p.full_name IS NULL OR p.full_name = '') AND u.raw_user_meta_data->>'full_name' IS NOT NULL
      OR (p.data_nascimento IS NULL AND u.raw_user_meta_data->>'data_nascimento' IS NOT NULL)
    )
    ORDER BY 
      CASE 
        WHEN u.created_at >= CURRENT_DATE - INTERVAL '1 day' THEN 1
        WHEN u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN 1
        ELSE 2
      END,
      u.created_at DESC
  LOOP
    v_total_processados := v_total_processados + 1;
    
    BEGIN
      -- Atualizar perfil com dados de auth.users
      UPDATE public.profiles
      SET
        email = COALESCE(
          NULLIF(profiles.email, ''),
          v_profile.email_auth
        ),
        telefone = COALESCE(
          NULLIF(profiles.telefone, ''),
          v_profile.telefone_auth
        ),
        cpf = COALESCE(
          NULLIF(profiles.cpf, ''),
          v_profile.cpf_auth
        ),
        full_name = COALESCE(
          NULLIF(profiles.full_name, ''),
          v_profile.full_name_auth
        ),
        data_nascimento = COALESCE(
          profiles.data_nascimento,
          CASE 
            WHEN v_profile.data_nascimento_auth IS NOT NULL 
            THEN (v_profile.data_nascimento_auth)::DATE
            ELSE NULL
          END
        ),
        updated_at = NOW()
      WHERE user_id = v_profile.user_id;
      
      v_atualizados := v_atualizados + 1;
      
      -- Log para usuários de ontem
      IF v_profile.usuario_criado_em >= CURRENT_DATE - INTERVAL '1 day' THEN
        RAISE NOTICE '✅ Atualizado usuário de ONTEM: % (Email: %, Telefone: %, CPF: %)', 
          v_profile.user_id,
          COALESCE(v_profile.email_auth, 'N/A'),
          COALESCE(v_profile.telefone_auth, 'N/A'),
          COALESCE(v_profile.cpf_auth, 'N/A');
      END IF;
      
      -- Log a cada 10 atualizações
      IF v_total_processados % 10 = 0 THEN
        RAISE NOTICE 'Processados: %, Atualizados: %', v_total_processados, v_atualizados;
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_com_erro := v_com_erro + 1;
        RAISE WARNING '❌ Erro ao atualizar perfil % (%): %', 
          v_profile.user_id, v_profile.email_auth, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO FINAL:';
  RAISE NOTICE 'Total processados: %', v_total_processados;
  RAISE NOTICE 'Perfis atualizados com sucesso: %', v_atualizados;
  RAISE NOTICE 'Perfis com erro: %', v_com_erro;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 4: Verificar quantos perfis foram atualizados
SELECT 
  COUNT(*) as perfis_atualizados_agora
FROM public.profiles p
WHERE p.updated_at >= NOW() - INTERVAL '5 minutes';

-- PASSO 5: Verificar se ainda há perfis sem dados
SELECT 
  COUNT(*) as perfis_ainda_sem_dados,
  COUNT(*) FILTER (WHERE p.email IS NULL) as sem_email,
  COUNT(*) FILTER (WHERE p.telefone IS NULL) as sem_telefone,
  COUNT(*) FILTER (WHERE p.cpf IS NULL) as sem_cpf
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE (
  (p.email IS NULL AND u.email IS NOT NULL)
  OR (p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL)
  OR (p.cpf IS NULL AND u.raw_user_meta_data->>'cpf' IS NOT NULL)
);

-- PASSO 6: Listar perfis de ONTEM que foram atualizados
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.telefone,
  p.cpf,
  p.full_name,
  p.data_nascimento,
  p.updated_at as dados_atualizados_em,
  u.created_at as usuario_criado_em,
  u.last_sign_in_at as ultimo_login
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE p.updated_at >= NOW() - INTERVAL '5 minutes'
  AND (
    u.created_at >= CURRENT_DATE - INTERVAL '1 day'
    OR u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day'
  )
ORDER BY p.updated_at DESC;

-- PASSO 7: Verificação final - todos os perfis devem ter dados agora
SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE email IS NOT NULL) as perfis_com_email,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL) as perfis_com_telefone,
  COUNT(*) FILTER (WHERE cpf IS NOT NULL) as perfis_com_cpf,
  COUNT(*) FILTER (WHERE email IS NOT NULL AND telefone IS NOT NULL AND cpf IS NOT NULL) as perfis_completos,
  CASE 
    WHEN COUNT(*) FILTER (WHERE email IS NOT NULL AND telefone IS NOT NULL AND cpf IS NOT NULL) = COUNT(*)
    THEN '✅ SUCESSO: Todos os perfis têm dados completos!'
    ELSE '⚠️ ATENÇÃO: Alguns perfis ainda estão sem dados'
  END as status
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email IS NOT NULL 
   OR u.raw_user_meta_data->>'telefone' IS NOT NULL
   OR u.raw_user_meta_data->>'cpf' IS NOT NULL;

