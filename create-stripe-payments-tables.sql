-- =====================================================
-- TABELAS PARA PAGAMENTOS STRIPE
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- Este script cria/atualiza as tabelas necessárias para Stripe

-- =====================================================
-- 1. CRIAR TABELA DE ASSINATURAS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('free', 'diamond')) DEFAULT 'free',
  status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'past_due', 'expired')) DEFAULT 'active',
  
  -- Campos específicos do Stripe
  payment_provider TEXT CHECK (payment_provider IN ('mercadopago', 'doppus', 'stripe', 'manual', 'peper')) DEFAULT NULL,
  payment_provider_subscription_id TEXT, -- Stripe Subscription ID (sub_xxx)
  payment_provider_customer_id TEXT,     -- Stripe Customer ID (cus_xxx)
  payment_provider_payment_id TEXT,     -- Stripe Payment Intent ID (pi_xxx) ou Checkout Session ID (cs_xxx)
  
  -- Períodos da assinatura
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraint: um usuário só pode ter uma assinatura ativa
  UNIQUE(user_id)
);

-- =====================================================
-- 2. CRIAR TABELA DE PAGAMENTOS/TRANSAÇÕES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  
  -- Valores do pagamento
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'BRL' CHECK (currency IN ('BRL', 'USD', 'EUR')),
  
  -- Status do pagamento
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'refunded')) DEFAULT 'pending',
  
  -- Informações do provedor (Stripe)
  payment_provider TEXT NOT NULL CHECK (payment_provider IN ('mercadopago', 'doppus', 'stripe', 'manual', 'peper')),
  payment_provider_payment_id TEXT,      -- Stripe Payment Intent ID, Invoice ID ou Checkout Session ID
  payment_provider_customer_id TEXT,    -- Stripe Customer ID
  payment_method TEXT,                  -- 'card', 'pix', 'boleto', etc.
  
  -- Metadados adicionais (JSONB para flexibilidade)
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para subscriptions
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_provider_subscription_id ON public.subscriptions(payment_provider_subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_provider_customer_id ON public.subscriptions(payment_provider_customer_id);

-- Índices para payments
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_subscription_id ON public.payments(subscription_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_provider_payment_id ON public.payments(payment_provider_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at DESC);

-- =====================================================
-- 4. HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. POLÍTICAS RLS PARA SUBSCRIPTIONS
-- =====================================================

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "Support can view all subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "System can insert subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "System can update subscriptions" ON public.subscriptions;

-- Usuários podem ver sua própria assinatura
CREATE POLICY "Users can view own subscription"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Suporte/Admin podem ver todas as assinaturas
CREATE POLICY "Support can view all subscriptions"
  ON public.subscriptions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE public.profiles.user_id = auth.uid()
      AND (public.profiles.role IN ('support', 'admin') OR public.profiles.email = 'admin@gmail.com')
    )
  );

-- Sistema pode inserir assinaturas (via webhook)
CREATE POLICY "System can insert subscriptions"
  ON public.subscriptions FOR INSERT
  WITH CHECK (true);

-- Sistema pode atualizar assinaturas (via webhook)
CREATE POLICY "System can update subscriptions"
  ON public.subscriptions FOR UPDATE
  USING (true);

-- =====================================================
-- 6. POLÍTICAS RLS PARA PAYMENTS
-- =====================================================

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Users can view own payments" ON public.payments;
DROP POLICY IF EXISTS "Support can view all payments" ON public.payments;
DROP POLICY IF EXISTS "System can insert payments" ON public.payments;
DROP POLICY IF EXISTS "System can update payments" ON public.payments;

-- Usuários podem ver seus próprios pagamentos
CREATE POLICY "Users can view own payments"
  ON public.payments FOR SELECT
  USING (auth.uid() = user_id);

-- Suporte/Admin podem ver todos os pagamentos
CREATE POLICY "Support can view all payments"
  ON public.payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE public.profiles.user_id = auth.uid()
      AND (public.profiles.role IN ('support', 'admin') OR public.profiles.email = 'admin@gmail.com')
    )
  );

-- Sistema pode inserir pagamentos (via webhook)
CREATE POLICY "System can insert payments"
  ON public.payments FOR INSERT
  WITH CHECK (true);

-- Sistema pode atualizar pagamentos (via webhook)
CREATE POLICY "System can update payments"
  ON public.payments FOR UPDATE
  USING (true);

-- =====================================================
-- 7. FUNÇÃO PARA SINCRONIZAR subscription_plan COM profiles
-- =====================================================

CREATE OR REPLACE FUNCTION public.sync_subscription_plan()
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

-- =====================================================
-- 8. TRIGGER PARA SINCRONIZAÇÃO AUTOMÁTICA
-- =====================================================

DROP TRIGGER IF EXISTS trigger_sync_subscription_plan ON public.subscriptions;
CREATE TRIGGER trigger_sync_subscription_plan
  AFTER INSERT OR UPDATE ON public.subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_subscription_plan();

-- =====================================================
-- 9. FUNÇÃO PARA ATUALIZAR updated_at AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON public.subscriptions;
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_payments_updated_at ON public.payments;
CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON public.payments
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- 10. FUNÇÃO PARA EXPIRAR ASSINATURAS AUTOMATICAMENTE
-- =====================================================

CREATE OR REPLACE FUNCTION public.expire_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE public.subscriptions
  SET 
    status = 'expired',
    updated_at = NOW()
  WHERE 
    status = 'active'
    AND current_period_end < NOW()
    AND cancel_at_period_end = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 11. COMENTÁRIOS PARA DOCUMENTAÇÃO
-- =====================================================

COMMENT ON TABLE public.subscriptions IS 'Armazena assinaturas de usuários (Stripe, Doppus, etc.)';
COMMENT ON TABLE public.payments IS 'Armazena histórico de pagamentos e transações';
COMMENT ON COLUMN public.subscriptions.payment_provider_subscription_id IS 'ID da assinatura no Stripe (sub_xxx)';
COMMENT ON COLUMN public.subscriptions.payment_provider_customer_id IS 'ID do cliente no Stripe (cus_xxx)';
COMMENT ON COLUMN public.payments.payment_provider_payment_id IS 'ID do pagamento no Stripe (pi_xxx, in_xxx, cs_xxx)';
COMMENT ON FUNCTION public.sync_subscription_plan() IS 'Sincroniza subscription_plan na tabela profiles automaticamente';
COMMENT ON FUNCTION public.expire_subscriptions() IS 'Expira assinaturas vencidas (executar via cron job)';

-- =====================================================
-- 12. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 
  'Tabelas criadas com sucesso!' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name = 'subscriptions'
    ) THEN '✓ Tabela subscriptions'
    ELSE '✗ Tabela subscriptions'
  END as check_subscriptions,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name = 'payments'
    ) THEN '✓ Tabela payments'
    ELSE '✗ Tabela payments'
  END as check_payments,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' AND routine_name = 'sync_subscription_plan'
    ) THEN '✓ Função sync_subscription_plan'
    ELSE '✗ Função sync_subscription_plan'
  END as check_function;

-- Contar registros (se houver)
SELECT 'subscriptions' as tabela, COUNT(*) as total FROM public.subscriptions
UNION ALL
SELECT 'payments' as tabela, COUNT(*) as total FROM public.payments;

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================
-- 
-- PRÓXIMOS PASSOS:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Configure os secrets do Stripe (STRIPE_SECRET_KEY, etc.)
-- 3. Deploy das Edge Functions (create-stripe-checkout, stripe-webhook)
-- 4. Configure o webhook no Stripe Dashboard
-- 5. Teste o fluxo completo de pagamento
-- 
-- =====================================================

