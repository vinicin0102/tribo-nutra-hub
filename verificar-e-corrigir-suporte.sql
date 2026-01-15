-- Verificar se usuário existe
SELECT id, email, email_confirmed_at FROM auth.users WHERE email = 'suporte@gmail.com';

-- Verificar perfil
SELECT p.user_id, p.username, p.role, u.email 
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

-- Atualizar perfil para suporte
UPDATE profiles 
SET role = 'support', username = 'suporte', full_name = 'Equipe de Suporte'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');

-- Confirmar email
UPDATE auth.usersh
SET email_confirmed_at = NOW()
WHERE email = 'suporte@gmail.com' AND email_confirmed_at IS NULL;

-- Verificar resultado
SELECT 
  u.email,
  CASE WHEN u.email_confirmed_at IS NOT NULL THEN 'SIM' ELSE 'NÃO' END as email_confirmado,
  p.role,
  CASE WHEN p.role = 'support' THEN 'SIM' ELSE 'NÃO' END as eh_suporte
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

