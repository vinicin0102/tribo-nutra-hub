-- Script para criar usuário de suporte
-- Execute este script no SQL Editor do Supabase

-- 1. Criar usuário de autenticação (você precisará fazer isso manualmente no Supabase Dashboard)
-- Authentication > Users > Add User
-- Email: suporte@gmail.com
-- Password: suporte123
-- Auto Confirm User: true

-- 2. Depois de criar o usuário, execute este SQL para atualizar o perfil:
-- (Substitua 'USER_ID_AQUI' pelo ID do usuário criado)

-- Para encontrar o user_id, execute primeiro:
SELECT id, email FROM auth.users WHERE email = 'suporte@gmail.com';

-- Depois, com o ID encontrado, execute:
UPDATE profiles 
SET 
  role = 'support',
  username = 'suporte',
  full_name = 'Equipe de Suporte'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');

-- Verificar se foi atualizado corretamente:
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.role,
  u.email
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';

