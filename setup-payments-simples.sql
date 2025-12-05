-- =====================================================
-- VERSÃO SUPER SIMPLES - SEM POLÍTICAS RLS COMPLEXAS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. CRIAR TABELA DE ASSINATURAS
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  plan_type TEXT NOT NULL DEFAULT 'free',
  status TEXT NOT NULL DEFAULT 'active',
  payment_provider TEXT,
  payment_provider_subscription_id TEXT,
  payment_provider_customer_id TEXT,
  payment_provider_payment_id TEXT,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CRIAR TABELA DE PAGAMENTOS
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'BRL',
  status TEXT NOT NULL,
  payment_provider TEXT NOT NULL,
  payment_provider_payment_id TEXT,
  payment_method TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CRIAR ÍNDICES (mais rápido)
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);

-- 4. HABILITAR RLS (segurança básica)
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- 5. POLÍTICAS SIMPLES - Usuários veem só suas coisas
DROP POLICY IF EXISTS "Ver própria assinatura" ON subscriptions;
CREATE POLICY "Ver própria assinatura"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Ver próprios pagamentos" ON payments;
CREATE POLICY "Ver próprios pagamentos"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

-- 6. POLÍTICAS PARA SISTEMA - Permitir INSERT/UPDATE
DROP POLICY IF EXISTS "Sistema criar assinaturas" ON subscriptions;
CREATE POLICY "Sistema criar assinaturas"
  ON subscriptions FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Sistema atualizar assinaturas" ON subscriptions;
CREATE POLICY "Sistema atualizar assinaturas"
  ON subscriptions FOR UPDATE
  USING (true);

DROP POLICY IF EXISTS "Sistema criar pagamentos" ON payments;
CREATE POLICY "Sistema criar pagamentos"
  ON payments FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Sistema atualizar pagamentos" ON payments;
CREATE POLICY "Sistema atualizar pagamentos"
  ON payments FOR UPDATE
  USING (true);

-- 7. FUNÇÃO: Quando assinatura muda, atualizar profile
CREATE OR REPLACE FUNCTION sync_subscription_plan()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'active' THEN
    -- Ativar Diamond
    UPDATE profiles
    SET 
      subscription_plan = NEW.plan_type,
      subscription_expires_at = NEW.current_period_end,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSE
    -- Voltar pra Free
    UPDATE profiles
    SET 
      subscription_plan = 'free',
      subscription_expires_at = NULL,
      updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. TRIGGER: Executar função automaticamente
DROP TRIGGER IF EXISTS trigger_sync_subscription_plan ON subscriptions;
CREATE TRIGGER trigger_sync_subscription_plan
  AFTER INSERT OR UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION sync_subscription_plan();

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

-- Verificar se funcionou:
SELECT 'Tabelas criadas com sucesso!' as resultado;


