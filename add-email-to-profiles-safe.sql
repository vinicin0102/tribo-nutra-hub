-- =====================================================
-- ADICIONAR EMAIL NA TABELA PROFILES (VERSÃO SEGURA)
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- Este script é seguro para executar mesmo se a tabela já existe
-- =====================================================

-- 1. ADICIONAR COLUNA EMAIL NA TABELA PROFILES (se não existir)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'email'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN email TEXT;
    RAISE NOTICE 'Coluna email adicionada à tabela profiles';
  ELSE
    RAISE NOTICE 'Coluna email já existe na tabela profiles';
  END IF;
END $$;

-- 2. ATUALIZAR EMAILS DOS USUÁRIOS EXISTENTES (apenas os que não têm email)
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id
  AND (p.email IS NULL OR p.email = '');

-- 3. CRIAR ÍNDICE PARA BUSCA POR EMAIL (se não existir)
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- 4. ATUALIZAR FUNÇÃO handle_new_user PARA INCLUIR EMAIL
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, username, full_name, avatar_url, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''),
    NEW.raw_user_meta_data ->> 'avatar_url',
    NEW.email
  )
  ON CONFLICT (user_id) DO UPDATE
  SET email = NEW.email;
  RETURN NEW;
END;
$$;

-- 5. CRIAR OU ATUALIZAR FUNÇÃO PARA SINCRONIZAR EMAIL QUANDO MUDAR NO AUTH
CREATE OR REPLACE FUNCTION public.sync_user_email()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  -- Atualizar email no perfil quando mudar no auth.users
  UPDATE public.profiles
  SET email = NEW.email
  WHERE user_id = NEW.id;
  
  RETURN NEW;
END;
$$;

-- 6. CRIAR OU RECRIAR TRIGGER PARA SINCRONIZAR EMAIL AUTOMATICAMENTE
DROP TRIGGER IF EXISTS sync_email_on_auth_update ON auth.users;
CREATE TRIGGER sync_email_on_auth_update
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW
  WHEN (OLD.email IS DISTINCT FROM NEW.email)
  EXECUTE FUNCTION public.sync_user_email();

-- 7. VERIFICAR RESULTADO
SELECT 
  'Email adicionado à tabela profiles com sucesso!' as status,
  COUNT(*) FILTER (WHERE email IS NOT NULL AND email != '') as perfis_com_email,
  COUNT(*) FILTER (WHERE email IS NULL OR email = '') as perfis_sem_email,
  COUNT(*) as total_perfis
FROM public.profiles;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

