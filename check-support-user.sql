-- Script de diagnóstico para verificar usuário de suporte
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se o usuário existe na autenticação
SELECT 
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users 
WHERE email = 'suporte@gmail.com';

-- 2. Verificar se o perfil existe e qual é o role
SELECT 
  p.id,
  p.user_id,
  p.username,
  p.full_name,
  p.role,
  p.is_banned,
  u.email,
  u.email_confirmed_at
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

-- 3. Se o usuário não existir, você precisa criá-lo primeiro:
--    - Vá em Authentication > Users > Add User
--    - Email: suporte@gmail.com
--    - Password: suporte123
--    - Auto Confirm User: true

-- 4. Se o perfil não tiver role 'support', execute:
UPDATE profiles 
SET 
  role = 'support',
  username = COALESCE(username, 'suporte'),
  full_name = COALESCE(full_name, 'Equipe de Suporte')
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');

-- 5. Verificar novamente após atualização
SELECT 
  p.username,
  p.role,
  u.email,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN 'Email confirmado ✓'
    ELSE 'Email NÃO confirmado ✗'
  END as email_status
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

