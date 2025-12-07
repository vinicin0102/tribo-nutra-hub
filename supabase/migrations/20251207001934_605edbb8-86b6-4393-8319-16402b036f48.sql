
-- =============================================
-- TABELAS PARA SISTEMA DE ASSINATURAS STRIPE
-- =============================================

-- Tabela de assinaturas
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    plan_type TEXT NOT NULL DEFAULT 'free',
    status TEXT NOT NULL DEFAULT 'inactive',
    payment_provider TEXT,
    payment_provider_payment_id TEXT,
    payment_provider_subscription_id TEXT,
    payment_provider_customer_id TEXT,
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    cancel_at_period_end BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de pagamentos
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'BRL',
    status TEXT NOT NULL DEFAULT 'pending',
    payment_provider TEXT,
    payment_provider_payment_id TEXT,
    payment_method TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- =============================================
-- TABELAS PARA SISTEMA DE RECOMPENSAS
-- =============================================

-- Tabela de recompensas (prêmios disponíveis)
CREATE TABLE IF NOT EXISTS public.rewards (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL DEFAULT 0,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Tabela de resgates
CREATE TABLE IF NOT EXISTS public.redemptions (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    reward_id UUID NOT NULL REFERENCES public.rewards(id),
    points_spent INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- =============================================
-- TABELA DE CHAT DE SUPORTE
-- =============================================

CREATE TABLE IF NOT EXISTS public.support_chat (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    support_user_id UUID,
    message TEXT NOT NULL,
    is_from_support BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- =============================================
-- COLUNAS ADICIONAIS NA TABELA PROFILES
-- =============================================

-- Adicionar colunas se não existirem
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS banned_until TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS subscription_plan TEXT DEFAULT 'free';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'bronze';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- =============================================
-- RLS POLICIES
-- =============================================

-- Habilitar RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_chat ENABLE ROW LEVEL SECURITY;

-- Policies para subscriptions
CREATE POLICY "Users can view own subscription" 
ON public.subscriptions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Service can manage subscriptions" 
ON public.subscriptions FOR ALL 
USING (true)
WITH CHECK (true);

-- Policies para payments
CREATE POLICY "Users can view own payments" 
ON public.payments FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Service can manage payments" 
ON public.payments FOR ALL 
USING (true)
WITH CHECK (true);

-- Policies para rewards
CREATE POLICY "Rewards are viewable by everyone" 
ON public.rewards FOR SELECT 
USING (true);

-- Policies para redemptions
CREATE POLICY "Users can view own redemptions" 
ON public.redemptions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create redemptions" 
ON public.redemptions FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service can manage redemptions" 
ON public.redemptions FOR ALL 
USING (true)
WITH CHECK (true);

-- Policies para support_chat
CREATE POLICY "Users can view own support chat" 
ON public.support_chat FOR SELECT 
USING (auth.uid() = user_id OR support_user_id = auth.uid());

CREATE POLICY "Users can send support messages" 
ON public.support_chat FOR INSERT 
WITH CHECK (auth.uid() = user_id OR auth.uid() = support_user_id);

CREATE POLICY "Service can manage support chat" 
ON public.support_chat FOR ALL 
USING (true)
WITH CHECK (true);

-- =============================================
-- REALTIME
-- =============================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.redemptions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_chat;
