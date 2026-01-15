-- ============================================
-- CORRIGIR ACESSO DE SUPORTE
-- ============================================
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se o usuário existe
SELECT 
  'Verificando usuário...' as status,
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'suporte@gmail.com';

-- 2. Verificar perfil do usuário
SELECT 
  'Verificando perfil...' as status,
  p.user_id,
  p.username,
  p.role,
  p.points,
  u.email,
  u.email_confirmed_at
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

-- 3. Se o usuário não existir, você precisa criá-lo primeiro no Dashboard:
--    Authentication > Users > Add User
--    Email: suporte@gmail.com
--    Password: suporte123
--    Auto Confirm User: true

-- 4. Atualizar/Criar perfil de suporte
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
    RAISE EXCEPTION 'Usuário não encontrado! Crie o usuário primeiro em Authentication > Users com email: suporte@gmail.com';
  END IF;
  
  -- Verificar se perfil existe
  SELECT EXISTS(SELECT 1 FROM profiles WHERE user_id = user_id_val) INTO profile_exists;
  
  IF NOT profile_exists THEN
    -- Criar perfil
    INSERT INTO profiles (user_id, username, full_name, role, points)
    VALUES (user_id_val, 'suporte', 'Equipe de Suporte', 'support', 0);
    RAISE NOTICE 'Perfil criado!';
  ELSE
    -- Atualizar perfil
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

-- 5. Verificar resultado final
SELECT 
  '✅ Configuração Completa' as status,
  u.email,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN '✓ Email confirmado'
    ELSE '✗ Email NÃO confirmado'
  END as email_status,
  p.username,
  p.role,
  CASE 
    WHEN p.role = 'support' THEN '✓ Role configurado como suporte'
    ELSE '✗ Role NÃO configurado'
  END as role_status
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

