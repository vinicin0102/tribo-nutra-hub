-- =====================================================
-- CRIAR PERFIS FALTANTES - VERSÃO SIMPLES E SEGURA
-- =====================================================
-- Este script apenas cria perfis para usuários que não têm,
-- SEM tentar modificar triggers ou funções do sistema
-- Execute no Supabase SQL Editor
-- =====================================================

-- PASSO 1: Verificar quantos usuários estão sem perfil
SELECT 
  COUNT(*) as usuarios_sem_perfil
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
);

-- PASSO 2: Garantir que a coluna email existe
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

-- PASSO 3: Criar perfis para TODOS os usuários sem perfil
-- Usando INSERT direto com tratamento de erros
DO $$
DECLARE
  v_user RECORD;
  v_perfis_criados INTEGER := 0;
  v_perfis_com_erro INTEGER := 0;
  v_total_processados INTEGER := 0;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'CRIANDO PERFIS FALTANTES...';
  RAISE NOTICE '========================================';
  
  FOR v_user IN 
    SELECT 
      u.id,
      u.email,
      u.created_at,
      u.raw_user_meta_data
    FROM auth.users u
    WHERE NOT EXISTS (
      SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
    )
    ORDER BY u.created_at DESC
  LOOP
    v_total_processados := v_total_processados + 1;
    
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
          v_user.created_at,
          NOW()
        );
        
        v_perfis_criados := v_perfis_criados + 1;
      END IF;
      
      -- Log a cada 10 perfis criados
      IF v_total_processados % 10 = 0 THEN
        RAISE NOTICE 'Processados: %, Criados: %', v_total_processados, v_perfis_criados;
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        v_perfis_com_erro := v_perfis_com_erro + 1;
        RAISE WARNING 'Erro ao criar perfil para usuário % (%): %', v_user.email, v_user.id, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULTADO:';
  RAISE NOTICE 'Total processados: %', v_total_processados;
  RAISE NOTICE 'Perfis criados com sucesso: %', v_perfis_criados;
  RAISE NOTICE 'Perfis com erro: %', v_perfis_com_erro;
  RAISE NOTICE '========================================';
END $$;

-- PASSO 4: Verificar quantos perfis foram criados
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

-- PASSO 6: Listar usuários que ainda estão sem perfil (se houver)
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro,
  u.raw_user_meta_data->>'username' as username_metadata,
  u.raw_user_meta_data->>'cpf' as cpf_metadata,
  u.raw_user_meta_data->>'telefone' as telefone_metadata
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
ORDER BY u.created_at DESC
LIMIT 20;

-- PASSO 7: Verificação final
SELECT 
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_auth,
  (SELECT COUNT(*) FROM public.profiles) as total_perfis,
  (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM public.profiles) as diferenca;

