-- Adicionar campos CPF e data de nascimento na tabela profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS cpf TEXT,
ADD COLUMN IF NOT EXISTS data_nascimento DATE;

-- Criar índice único para CPF (garantir que não haja duplicatas)
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_cpf_unique 
ON public.profiles(cpf) 
WHERE cpf IS NOT NULL;

-- Comentários
COMMENT ON COLUMN public.profiles.cpf IS 'CPF do usuário (formato: apenas números)';
COMMENT ON COLUMN public.profiles.data_nascimento IS 'Data de nascimento do usuário';

-- Atualizar função handle_new_user para incluir os novos campos
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
    email,
    cpf,
    data_nascimento
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    NEW.raw_user_meta_data ->> 'avatar_url',
    NEW.email,
    NEW.raw_user_meta_data ->> 'cpf',
    CASE 
      WHEN NEW.raw_user_meta_data ->> 'data_nascimento' IS NOT NULL 
      THEN (NEW.raw_user_meta_data ->> 'data_nascimento')::DATE
      ELSE NULL
    END
  );
  RETURN NEW;
END;
$$;

