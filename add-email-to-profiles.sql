-- =====================================================
-- ADICIONAR EMAIL NA TABELA PROFILES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. ADICIONAR COLUNA EMAIL NA TABELA PROFILES
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email TEXT;

-- 2. ATUALIZAR EMAILS DOS USUÁRIOS EXISTENTES
UPDATE public.profiles p
SET email = u.email
FROM auth.users u
WHERE p.user_id = u.id
  AND p.email IS NULL;

-- 3. CRIAR ÍNDICE PARA BUSCA POR EMAIL
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
  );
  RETURN NEW;
END;
$$;

-- 5. CRIAR FUNÇÃO PARA SINCRONIZAR EMAIL QUANDO MUDAR NO AUTH
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

-- 6. CRIAR TRIGGER PARA SINCRONIZAR EMAIL AUTOMATICAMENTE
DROP TRIGGER IF EXISTS sync_email_on_auth_update ON auth.users;
CREATE TRIGGER sync_email_on_auth_update
  AFTER UPDATE OF email ON auth.users
  FOR EACH ROW
  WHEN (OLD.email IS DISTINCT FROM NEW.email)
  EXECUTE FUNCTION public.sync_user_email();

-- 7. VERIFICAR RESULTADO
SELECT 
  'Email adicionado à tabela profiles com sucesso!' as status,
  COUNT(*) FILTER (WHERE email IS NOT NULL) as perfis_com_email,
  COUNT(*) FILTER (WHERE email IS NULL) as perfis_sem_email,
  COUNT(*) as total_perfis
FROM public.profiles;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

