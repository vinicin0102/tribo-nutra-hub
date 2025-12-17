-- Criar tabela para armazenar push subscriptions
CREATE TABLE IF NOT EXISTS public.push_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  endpoint TEXT NOT NULL,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, endpoint)
);

-- Habilitar RLS
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Users can view own subscriptions" ON public.push_subscriptions 
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions" ON public.push_subscriptions 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON public.push_subscriptions 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own subscriptions" ON public.push_subscriptions 
  FOR DELETE USING (auth.uid() = user_id);

-- Admins podem ver todas as subscriptions
CREATE POLICY "Admins can view all subscriptions" ON public.push_subscriptions 
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND role IN ('admin', 'support')
    )
  );

-- Índice para busca rápida
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_user_id ON public.push_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_push_subscriptions_endpoint ON public.push_subscriptions(endpoint);

COMMENT ON TABLE public.push_subscriptions IS 'Armazena as subscriptions de push notifications dos usuários';
COMMENT ON COLUMN public.push_subscriptions.endpoint IS 'URL do endpoint do serviço de push';
COMMENT ON COLUMN public.push_subscriptions.p256dh IS 'Chave pública P256DH para criptografia';
COMMENT ON COLUMN public.push_subscriptions.auth IS 'Chave de autenticação para criptografia';

