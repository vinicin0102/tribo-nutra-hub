-- =====================================================
-- 🔴 URGENTE: CRIAR PERFIS PARA TODOS OS USUÁRIOS FALTANTES
-- =====================================================
-- Este script cria perfis para TODOS os usuários que não têm,
-- incluindo os 40+ alunos que entraram ontem
-- Execute no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Verificar quantos usuários estão sem perfil
SELECT 
  COUNT(*) as usuarios_sem_perfil,
  COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '1 day') as usuarios_ontem_sem_perfil,
  COUNT(*) FILTER (WHERE last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day') as usuarios_login_ontem_sem_perfil
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
);

-- PASSO 2: Garantir que a coluna email existe
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

-- PASSO 3: CRIAR PERFIS PARA TODOS OS USUÁRIOS SEM PERFIL
DO $$
DECLARE
  v_user RECORD;
  v_perfis_criados INTEGER := 0;
  v_perfis_com_erro INTEGER := 0;
  v_total_processados INTEGER := 0;
  v_usuarios_ontem INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔴 URGENTE: CRIANDO PERFIS FALTANTES';
  RAISE NOTICE '========================================';
  
  FOR v_user IN 
    SELECT 
      u.id,
      u.email,
      u.created_at,
      u.last_sign_in_at,
      u.raw_user_meta_data
    FROM auth.users u
    WHERE NOT EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
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
    
    -- Contar usuários de ontem
    IF v_user.created_at >= CURRENT_DATE - INTERVAL '1 day' 
       OR v_user.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN
      v_usuarios_ontem := v_usuarios_ontem + 1;
    END IF;
    
    BEGIN
      -- Verificar se o perfil já existe antes de tentar inserir
      IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = v_user.id) THEN
        INSERT INTO public.profiles (
          user_id,
          username,
          full_name,
          avatar_url,
          cpf,
          data_nascimento,
          telefone,
          email,
          points,
          created_at,
          updated_at
        )
        VALUES (
          v_user.id,
          COALESCE(
            v_user.raw_user_meta_data->>'username',
            split_part(v_user.email, '@', 1)
          ),
          COALESCE(v_user.raw_user_meta_data->>'full_name', ''),
          v_user.raw_user_meta_data->>'avatar_url',
          v_user.raw_user_meta_data->>'cpf',
          CASE 
            WHEN v_user.raw_user_meta_data->>'data_nascimento' IS NOT NULL 
            THEN (v_user.raw_user_meta_data->>'data_nascimento')::DATE
            ELSE NULL
          END,
          v_user.raw_user_meta_data->>'telefone',
          v_user.email,
          0,
          COALESCE(v_user.created_at, NOW()),
          NOW()
        );
        
        v_perfis_criados := v_perfis_criados + 1;
        
        -- Log para usuários de ontem
        IF v_user.created_at >= CURRENT_DATE - INTERVAL '1 day' 
           OR v_user.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day' THEN
          RAISE NOTICE '✅ Perfil criado para usuário de ONTEM: % (Email: %, Telefone: %)', 
            v_user.raw_user_meta_data->>'username', 
            v_user.email,
            v_user.raw_user_meta_data->>'telefone';
        END IF;
      END IF;
      
      -- Log a cada 10 perfis criados
      IF v_total_processados % 10 = 0 THEN
        RAISE NOTICE 'Processados: %, Criados: %, Usuários de ontem: %', 
          v_total_processados, v_perfis_criados, v_usuarios_ontem;
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_perfis_com_erro := v_perfis_com_erro + 1;
        RAISE WARNING '❌ Erro ao criar perfil para usuário % (%): %', 
          v_user.email, v_user.id, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO FINAL:';
  RAISE NOTICE 'Total processados: %', v_total_processados;
  RAISE NOTICE 'Perfis criados com sucesso: %', v_perfis_criados;
  RAISE NOTICE 'Usuários de ONTEM recuperados: %', v_usuarios_ontem;
  RAISE NOTICE 'Perfis com erro: %', v_perfis_com_erro;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 4: Verificar quantos perfis foram criados AGORA
SELECT 
  COUNT(*) as perfis_criados_agora
FROM public.profiles p
WHERE p.created_at >= NOW() - INTERVAL '5 minutes';

-- PASSO 5: Verificar se ainda há usuários sem perfil
SELECT 
  COUNT(*) as usuarios_ainda_sem_perfil
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
);

-- PASSO 6: Listar usuários de ONTEM que foram recuperados
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.telefone,
  p.cpf,
  p.full_name,
  p.created_at as perfil_criado_em,
  u.created_at as usuario_criado_em,
  u.last_sign_in_at as ultimo_login
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE p.created_at >= NOW() - INTERVAL '5 minutes'
  AND (
    u.created_at >= CURRENT_DATE - INTERVAL '1 day'
    OR u.last_sign_in_at >= CURRENT_DATE - INTERVAL '1 day'
  )
ORDER BY p.created_at DESC;

-- PASSO 7: Verificação final - todos os usuários devem ter perfil agora
SELECT 
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_auth,
  (SELECT COUNT(*) FROM public.profiles) as total_perfis,
  (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM public.profiles) as diferenca,
  CASE 
    WHEN (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM public.profiles) = 0 
    THEN '✅ SUCESSO: Todos os usuários têm perfil!'
    ELSE '❌ ATENÇÃO: Ainda há usuários sem perfil!'
  END as status;

