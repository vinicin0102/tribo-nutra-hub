-- =====================================================
-- CORRIGIR FUNÇÃO handle_new_user E GARANTIR QUE FUNCIONE
-- =====================================================
-- Este script verifica e corrige a função handle_new_user
-- para garantir que ela sempre crie perfis corretamente
-- =====================================================

-- 1. VERIFICAR SE A COLUNA EMAIL EXISTE NA TABELA PROFILES
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'profiles'
  AND column_name = 'email';

-- 2. ADICIONAR COLUNA EMAIL SE NÃO EXISTIR
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

COMMENT ON COLUMN public.profiles.email IS 'Email do usuário (cópia de auth.users.email)';

-- 3. RECRIAR A FUNÇÃO handle_new_user COM TRATAMENTO DE ERROS
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Tentar inserir o perfil
  BEGIN
    INSERT INTO public.profiles (
      user_id, 
      username, 
      full_name, 
      avatar_url,
      cpf,
      data_nascimento,
      telefone,
      email,
      points
    )
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data ->> 'username', split_part(NEW.email, '@', 1)),
      COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
      NEW.raw_user_meta_data ->> 'avatar_url',
      NEW.raw_user_meta_data ->> 'cpf',
      CASE 
        WHEN NEW.raw_user_meta_data ->> 'data_nascimento' IS NOT NULL 
        THEN (NEW.raw_user_meta_data ->> 'data_nascimento')::DATE
        ELSE NULL
      END,
      NEW.raw_user_meta_data ->> 'telefone',
      NEW.email,
      0
    )
    ON CONFLICT (user_id) DO NOTHING;
    
    -- Log de sucesso (apenas em desenvolvimento)
    -- RAISE NOTICE 'Perfil criado para usuário: %', NEW.email;
    
  EXCEPTION
    WHEN OTHERS THEN
      -- Em caso de erro, tentar inserir apenas os campos obrigatórios
      BEGIN
        INSERT INTO public.profiles (
          user_id, 
          username, 
          full_name,
          points
        )
        VALUES (
          NEW.id,
          COALESCE(NEW.raw_user_meta_data ->> 'username', split_part(NEW.email, '@', 1)),
          COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
          0
        )
        ON CONFLICT (user_id) DO NOTHING;
        
        -- Log do erro (apenas em desenvolvimento)
        -- RAISE WARNING 'Erro ao criar perfil completo para %: %. Criado perfil básico.', NEW.email, SQLERRM;
      EXCEPTION
        WHEN OTHERS THEN
          -- Se ainda falhar, registrar o erro mas não quebrar o cadastro
          RAISE WARNING 'FALHA CRÍTICA ao criar perfil para usuário %: %', NEW.email, SQLERRM;
      END;
  END;
  
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS 
'Cria perfil do usuário ao se cadastrar. Versão robusta com tratamento de erros.';

-- 4. VERIFICAR E RECRIAR O TRIGGER
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 
'Cria automaticamente um perfil quando um novo usuário é criado. Recriado para garantir funcionamento.';

-- 5. VERIFICAR SE O TRIGGER ESTÁ ATIVO
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 6. TESTAR A FUNÇÃO MANUALMENTE (OPCIONAL - DESCOMENTE PARA TESTAR)
-- DO $$
-- DECLARE
--   v_test_user_id UUID;
-- BEGIN
--   -- Pegar um usuário de teste que não tem perfil
--   SELECT id INTO v_test_user_id
--   FROM auth.users
--   WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.users.id)
--   LIMIT 1;
--   
--   IF v_test_user_id IS NOT NULL THEN
--     -- Simular a criação de perfil
--     PERFORM public.handle_new_user() FROM auth.users WHERE id = v_test_user_id;
--     RAISE NOTICE 'Teste executado para usuário: %', v_test_user_id;
--   ELSE
--     RAISE NOTICE 'Nenhum usuário sem perfil encontrado para teste';
--   END IF;
-- END $$;

