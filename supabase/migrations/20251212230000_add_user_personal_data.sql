-- Adicionar colunas de dados pessoais na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS cpf TEXT,
ADD COLUMN IF NOT EXISTS data_nascimento DATE,
ADD COLUMN IF NOT EXISTS telefone TEXT;

-- Comentários explicativos
COMMENT ON COLUMN public.profiles.cpf IS 'CPF do usuário (apenas números)';
COMMENT ON COLUMN public.profiles.data_nascimento IS 'Data de nascimento do usuário';
COMMENT ON COLUMN public.profiles.telefone IS 'Telefone do usuário';

-- Atualizar função handle_new_user para salvar CPF, data de nascimento e telefone
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (
    user_id, 
    username, 
    full_name, 
    avatar_url,
    cpf,
    data_nascimento,
    telefone,
    email
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
    NEW.email
  );
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS 
'Cria perfil do usuário ao se cadastrar, incluindo CPF, data de nascimento, telefone e email';

