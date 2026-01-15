-- Dar acesso Diamond e 700.000 pontos ao usuário vv9250400@gmail.com
-- Execute este script no SQL Editor do Supabase

-- Atualizar perfil do usuário com Diamond e 700k pontos
UPDATE profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NULL,
  points = 700000,
  tier = 'diamond',
  updated_at = NOW()
WHERE user_id = (
  SELECT id 
  FROM auth.users 
  WHERE email = 'vv9250400@gmail.com'
);

-- Verificar resultado
SELECT 
  p.user_id,
  u.email,
  p.username,
  p.subscription_plan,
  p.points,
  p.tier,
  CASE 
    WHEN p.subscription_plan = 'diamond' AND p.points = 700000 
    THEN '✓ ACESSO DIAMOND E 700.000 PONTOS CONCEDIDOS'
    ELSE '✗ Erro ao atualizar'
  END as status
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'vv9250400@gmail.com';

