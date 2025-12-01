-- ============================================
-- TORNAR USUÁRIO EM SUPORTE
-- ============================================
-- Execute este script APÓS criar o usuário normalmente
-- Substitua 'EMAIL_DO_USUARIO' pelo email do usuário que você criou

-- Opção 1: Se você criou com email suporte@gmail.com
UPDATE profiles 
SET role = 'support'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');

-- Opção 2: Se você criou com outro email, substitua abaixo:
-- UPDATE profiles 
-- SET role = 'support'
-- WHERE user_id = (SELECT id FROM auth.users WHERE email = 'SEU_EMAIL_AQUI@gmail.com');

-- Verificar se foi atualizado
SELECT 
  u.email,
  p.username,
  p.role,
  CASE 
    WHEN p.role = 'support' THEN '✅ Usuário é suporte'
    ELSE '❌ Usuário NÃO é suporte'
  END as status
FROM auth.users u
JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';
-- Se usou outro email, troque 'suporte@gmail.com' pelo email que você usou

