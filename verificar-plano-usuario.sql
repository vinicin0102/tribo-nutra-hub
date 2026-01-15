-- =====================================================
-- VERIFICAR PLANO DO USUÁRIO APÓS PAGAMENTO
-- =====================================================
-- Execute este SQL para verificar o plano do usuário
-- =====================================================

-- Substitua 'SEU_EMAIL_AQUI' pelo email do usuário que fez o pagamento
SELECT 
  u.email,
  u.id as user_id,
  p.subscription_plan,
  p.subscription_expires_at,
  p.updated_at,
  s.status as subscription_status,
  s.plan_type,
  s.current_period_end
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'SEU_EMAIL_AQUI';

-- =====================================================
-- ATUALIZAR PLANO MANUALMENTE (se necessário)
-- =====================================================
-- Execute apenas se o plano não foi atualizado automaticamente
-- Substitua 'SEU_EMAIL_AQUI' pelo email do usuário

/*
UPDATE profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NOW() + INTERVAL '30 days',
  updated_at = NOW()
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'SEU_EMAIL_AQUI'
);
*/

-- =====================================================
-- VERIFICAR PAGAMENTOS RECENTES
-- =====================================================
SELECT 
  p.user_id,
  u.email,
  p.amount,
  p.currency,
  p.status,
  p.created_at,
  p.payment_provider_payment_id
FROM payments p
JOIN auth.users u ON u.id = p.user_id
ORDER BY p.created_at DESC
LIMIT 10;

-- =====================================================
-- VERIFICAR ASSINATURAS RECENTES
-- =====================================================
SELECT 
  s.user_id,
  u.email,
  s.plan_type,
  s.status,
  s.current_period_start,
  s.current_period_end,
  s.created_at,
  s.updated_at
FROM subscriptions s
JOIN auth.users u ON u.id = s.user_id
ORDER BY s.created_at DESC
LIMIT 10;

