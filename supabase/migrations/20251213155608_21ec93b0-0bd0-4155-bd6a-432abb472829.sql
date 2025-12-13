-- 1. Adicionar coluna telefone na tabela profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS telefone TEXT;

-- 2. Atualizar função handle_new_user para salvar email e telefone
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public 
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, username, full_name, avatar_url, email, telefone)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    NEW.raw_user_meta_data ->> 'avatar_url',
    NEW.email,
    NEW.raw_user_meta_data ->> 'telefone'
  );
  RETURN NEW;
END;
$$;

-- 3. Migrar dados existentes - atualizar telefone dos metadados
UPDATE public.profiles p
SET telefone = u.raw_user_meta_data->>'telefone'
FROM auth.users u
WHERE p.user_id = u.id
  AND (p.telefone IS NULL OR p.telefone = '')
  AND u.raw_user_meta_data->>'telefone' IS NOT NULL;

-- 4. Garantir que email está atualizado para todos os perfis
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id
  AND (p.email IS NULL OR p.email = '')
  AND u.email IS NOT NULL;

-- Comentário
COMMENT ON COLUMN public.profiles.telefone IS 'Telefone do usuário';