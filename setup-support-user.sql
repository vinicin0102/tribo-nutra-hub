-- ============================================
-- SCRIPT COMPLETO PARA CRIAR USUÁRIO DE SUPORTE
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- IMPORTANTE: Você precisa criar o usuário primeiro no Dashboard!

-- PASSO 1: Criar o usuário no Dashboard
-- 1. Vá em Authentication > Users
-- 2. Clique em "Add User" > "Create new user"
-- 3. Preencha:
--    - Email: suporte@gmail.com
--    - Password: suporte123
--    - Marque "Auto Confirm User"
-- 4. Clique em "Create User"

-- PASSO 2: Execute este SQL após criar o usuário

-- Verificar se o usuário existe
DO $$
DECLARE
  user_id_val UUID;
  profile_exists BOOLEAN;
BEGIN
  -- Buscar user_id
  SELECT id INTO user_id_val 
  FROM auth.users 
  WHERE email = 'suporte@gmail.com';
  
  IF user_id_val IS NULL THEN
    RAISE EXCEPTION 'Usuário não encontrado! Crie o usuário primeiro em Authentication > Users';
  END IF;
  
  RAISE NOTICE 'Usuário encontrado: %', user_id_val;
  
  -- Verificar se o perfil existe
  SELECT EXISTS(SELECT 1 FROM profiles WHERE user_id = user_id_val) INTO profile_exists;
  
  -- Criar perfil se não existir
  IF NOT profile_exists THEN
    INSERT INTO profiles (user_id, username, full_name, role)
    VALUES (user_id_val, 'suporte', 'Equipe de Suporte', 'support');
    RAISE NOTICE 'Perfil criado!';
  ELSE
    -- Atualizar perfil existente
    UPDATE profiles 
    SET 
      role = 'support',
      username = COALESCE(NULLIF(username, ''), 'suporte'),
      full_name = COALESCE(NULLIF(full_name, ''), 'Equipe de Suporte')
    WHERE user_id = user_id_val;
    RAISE NOTICE 'Perfil atualizado!';
  END IF;
  
  -- Confirmar email se não estiver confirmado
  UPDATE auth.users
  SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
  WHERE id = user_id_val;
  
  RAISE NOTICE 'Email confirmado!';
  
END $$;

-- PASSO 3: Verificar se tudo está correto
SELECT 
  '✓ Configuração Completa' as status,
  u.email,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN '✓ Email confirmado'
    ELSE '✗ Email NÃO confirmado'
  END as email_status,
  p.username,
  p.role,
  CASE 
    WHEN p.role = 'support' THEN '✓ Role configurado'
    ELSE '✗ Role NÃO configurado'
  END as role_status
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

-- Se tudo estiver correto, você verá:
-- - email: suporte@gmail.com
-- - email_status: ✓ Email confirmado
-- - username: suporte
-- - role: support
-- - role_status: ✓ Role configurado

