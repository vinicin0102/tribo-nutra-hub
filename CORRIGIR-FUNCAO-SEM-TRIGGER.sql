-- =====================================================
-- CORRIGIR FUNÇÃO handle_new_user (SEM MODIFICAR TRIGGER)
-- =====================================================
-- Este script apenas atualiza a função handle_new_user,
-- SEM tentar modificar o trigger (que requer permissões especiais)
-- Execute no Supabase SQL Editor
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

-- 4. VERIFICAR SE A FUNÇÃO FOI CRIADA
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

-- =====================================================
-- NOTA SOBRE O TRIGGER
-- =====================================================
-- Para criar ou recriar o trigger on_auth_user_created,
-- você precisa usar uma migration no Supabase ou o Dashboard,
-- pois requer permissões de owner da tabela auth.users.
--
-- O trigger deve ser criado assim:
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW 
--   EXECUTE FUNCTION public.handle_new_user();
--
-- Para verificar se o trigger existe:
-- SELECT trigger_name, event_manipulation, action_timing
-- FROM information_schema.triggers
-- WHERE trigger_name = 'on_auth_user_created';

