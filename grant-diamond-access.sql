-- Dar acesso Diamond (total) ao usuário vv9250400@gmail.com
-- Execute este script no SQL Editor do Supabase

-- Atualizar perfil do usuário para ter plano Diamond
UPDATE profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NULL  -- NULL = acesso vitalício
WHERE user_id = (
  SELECT id 
  FROM auth.users 
  WHERE email = 'vv9250400@gmail.com'
);

-- Verificar se foi atualizado
SELECT 
  p.user_id,
  u.email,
  p.subscription_plan,
  p.subscription_expires_at,
  CASE 
    WHEN p.subscription_plan = 'diamond' THEN '✓ Acesso Diamond concedido'
    ELSE '✗ Não encontrado ou não atualizado'
  END as status
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'vv9250400@gmail.com';

