-- Dar 700.000 pontos e acesso Diamond ao usuário vv9250400@gmail.com
-- Execute este script no SQL Editor do Supabase

-- Atualizar perfil do usuário
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

-- Se o perfil não existe, criar
INSERT INTO profiles (user_id, username, subscription_plan, points, tier)
SELECT 
  id,
  split_part(email, '@', 1),
  'diamond',
  700000,
  'diamond'
FROM auth.users 
WHERE email = 'vv9250400@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM profiles WHERE user_id = auth.users.id
)
ON CONFLICT (user_id) DO UPDATE 
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NULL,
  points = 700000,
  tier = 'diamond';

-- Verificar resultado
SELECT 
  u.email,
  p.username,
  p.subscription_plan as plano,
  p.points as pontos,
  p.tier as nivel,
  CASE 
    WHEN p.subscription_plan = 'diamond' AND p.points = 700000 
    THEN '✓ SUCESSO: Acesso Diamond + 700.000 pontos concedidos'
    ELSE '✗ ERRO: Verifique os dados'
  END as status
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

