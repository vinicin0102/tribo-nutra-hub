-- =====================================================
-- CORRIGIR FUNÇÃO handle_new_user E RECRIAR TRIGGER
-- =====================================================
-- Esta migration corrige a função handle_new_user
-- e recria o trigger on_auth_user_created
-- Execute via Supabase CLI ou Dashboard
-- =====================================================

-- 1. Garantir que a coluna email existe
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

COMMENT ON COLUMN public.profiles.email IS 'Email do usuário (cópia de auth.users.email)';

-- 2. Recriar a função handle_new_user com tratamento de erros
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Tentar inserir o perfil completo
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

-- 3. Remover trigger antigo se existir
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 4. Recriar o trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS 
'Cria automaticamente um perfil quando um novo usuário é criado. Recriado para garantir funcionamento.';

