-- =====================================================
-- CONFIGURAÇÃO DO SISTEMA DE PAGAMENTOS (CORRIGIDO)
-- =====================================================

-- 1. Criar tabela de assinaturas
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('free', 'diamond')),
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'past_due', 'expired')) DEFAULT 'active',
  payment_provider TEXT CHECK (payment_provider IN ('mercadopago', 'doppus', 'stripe', 'manual')),
  payment_provider_subscription_id TEXT,
  payment_provider_customer_id TEXT,
  payment_provider_payment_id TEXT,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 2. Criar tabela de transações/pagamentos
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'refunded')),
  payment_provider TEXT NOT NULL,
  payment_provider_payment_id TEXT,
  payment_method TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_subscription_id ON payments(subscription_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- 4. Habilitar RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- 5. Políticas RLS para subscriptions
DROP POLICY IF EXISTS "Users can view own subscription" ON subscriptions;
CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Support can view all subscriptions" ON subscriptions;
CREATE POLICY "Support can view all subscriptions"
  ON subscriptions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE public.profiles.user_id = auth.uid()
      AND public.profiles.role IN ('support', 'admin')
    )
  );

DROP POLICY IF EXISTS "System can insert subscriptions" ON subscriptions;
CREATE POLICY "System can insert subscriptions"
  ON subscriptions FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "System can update subscriptions" ON subscriptions;
CREATE POLICY "System can update subscriptions"
  ON subscriptions FOR UPDATE
  USING (true);

-- 6. Políticas RLS para payments
DROP POLICY IF EXISTS "Users can view own payments" ON payments;
CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Support can view all payments" ON payments;
CREATE POLICY "Support can view all payments"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE public.profiles.user_id = auth.uid()
      AND public.profiles.role IN ('support', 'admin')
    )
  );

DROP POLICY IF EXISTS "System can insert payments" ON payments;
CREATE POLICY "System can insert payments"
  ON payments FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "System can update payments" ON payments;
CREATE POLICY "System can update payments"
  ON payments FOR UPDATE
  USING (true);

-- 7. Função para sincronizar subscription_plan com tabela subscriptions
CREATE OR REPLACE FUNCTION sync_subscription_plan()
RETURNS TRIGGER AS $$
BEGIN
  -- Quando uma assinatura é criada/atualizada, atualizar o profile
  IF NEW.status = 'active' THEN
    UPDATE public.profiles
    SET 
      subscription_plan = NEW.plan_type,
      subscription_expires_at = NEW.current_period_end,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF NEW.status IN ('cancelled', 'expired', 'past_due') THEN
    UPDATE public.profiles
    SET 
      subscription_plan = 'free',
      subscription_expires_at = NULL,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Trigger para sincronizar
DROP TRIGGER IF EXISTS trigger_sync_subscription_plan ON subscriptions;
CREATE TRIGGER trigger_sync_subscription_plan
  AFTER INSERT OR UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION sync_subscription_plan();

-- 9. Função para expirar assinaturas automaticamente
CREATE OR REPLACE FUNCTION expire_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE subscriptions
  SET 
    status = 'expired',
    updated_at = NOW()
  WHERE 
    status = 'active'
    AND current_period_end < NOW()
    AND cancel_at_period_end = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Comentários para documentação
COMMENT ON TABLE subscriptions IS 'Armazena assinaturas de usuários';
COMMENT ON TABLE payments IS 'Armazena histórico de pagamentos';
COMMENT ON FUNCTION sync_subscription_plan() IS 'Sincroniza subscription_plan na tabela profiles';
COMMENT ON FUNCTION expire_subscriptions() IS 'Expira assinaturas vencidas (executar via cron)';

-- =====================================================
-- VERIFICAÇÃO: Execute para confirmar
-- =====================================================

-- Ver tabelas criadas
SELECT 'subscriptions' as tabela, COUNT(*) as total FROM subscriptions
UNION ALL
SELECT 'payments' as tabela, COUNT(*) as total FROM payments;

-- =====================================================
-- Executar este SQL no Supabase SQL Editor
-- =====================================================

