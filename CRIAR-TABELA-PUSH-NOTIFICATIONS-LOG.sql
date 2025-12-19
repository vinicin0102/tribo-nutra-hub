-- CRIAR TABELA push_notifications_log
-- Execute este script no Supabase SQL Editor

-- Criar tabela push_notifications_log para histórico de notificações enviadas
CREATE TABLE IF NOT EXISTS public.push_notifications_log (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  url TEXT,
  sent_by UUID,
  sent_to_all BOOLEAN DEFAULT true,
  recipients_count INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  failed_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.push_notifications_log ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver (para permitir re-execução)
DROP POLICY IF EXISTS "Admins can view notifications log" ON public.push_notifications_log;
DROP POLICY IF EXISTS "Admins can insert notifications log" ON public.push_notifications_log;
DROP POLICY IF EXISTS "Service role can insert notifications log" ON public.push_notifications_log;

-- Políticas para push_notifications_log
CREATE POLICY "Admins can view notifications log"
ON public.push_notifications_log FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.user_id = auth.uid() 
    AND profiles.role IN ('admin', 'support')
  )
);

CREATE POLICY "Admins can insert notifications log"
ON public.push_notifications_log FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE profiles.user_id = auth.uid() 
    AND profiles.role IN ('admin', 'support')
  )
);

-- Política para service_role poder inserir logs (necessário para Edge Function)
CREATE POLICY "Service role can insert notifications log"
ON public.push_notifications_log FOR INSERT
TO service_role
WITH CHECK (true);

-- Verificar se a tabela foi criada
SELECT 
  'Tabela push_notifications_log criada!' as status,
  EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'push_notifications_log'
  ) as tabela_existe;


