-- =====================================================
-- ATUALIZAR CONFIGURAÇÕES DE HORÁRIO DO PLANO FREE
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- para adicionar/atualizar as configurações de horário
-- específicas do plano Free
-- =====================================================

-- 1. Garantir que a tabela support_settings existe
CREATE TABLE IF NOT EXISTS public.support_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_by UUID REFERENCES auth.users(id)
);

-- 2. Habilitar RLS (caso não esteja)
ALTER TABLE public.support_settings ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas RLS se não existirem
DO $$
BEGIN
  -- Política de SELECT
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'support_settings' 
    AND policyname = 'Anyone can view support settings'
  ) THEN
    CREATE POLICY "Anyone can view support settings" ON public.support_settings FOR SELECT USING (true);
  END IF;
  
  -- Política de UPDATE
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'support_settings' 
    AND policyname = 'Only admins can update support settings'
  ) THEN
    CREATE POLICY "Only admins can update support settings" ON public.support_settings FOR UPDATE 
      USING (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      );
  END IF;
  
  -- Política de INSERT
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'support_settings' 
    AND policyname = 'Only admins can insert support settings'
  ) THEN
    CREATE POLICY "Only admins can insert support settings" ON public.support_settings FOR INSERT 
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      );
  END IF;
END $$;

-- 4. INSERIR/ATUALIZAR TODAS AS CONFIGURAÇÕES (incluindo horário do plano Free)
INSERT INTO public.support_settings (key, value, description)
VALUES 
  ('chat_start_hour', '9', 'Horário de abertura do chat geral (0-23)'),
  ('chat_end_hour', '21', 'Horário de fechamento do chat geral (0-23)'),
  ('free_start_hour', '10', 'Horário de abertura do chat para plano FREE (0-23)'),
  ('free_end_hour', '15', 'Horário de fechamento do chat para plano FREE (0-23)'),
  ('auto_reply_enabled', 'true', 'Ativar/desativar mensagem automática de suporte'),
  ('auto_reply_message', 'Olá! Recebemos sua mensagem. Nossa equipe de suporte responderá em até 10 minutos. Obrigado pela paciência! 🙏', 'Conteúdo da mensagem automática de suporte')
ON CONFLICT (key) DO NOTHING;  -- Não sobrescrever valores existentes, apenas inserir se não existir

-- 5. Verificar configurações criadas
SELECT key, value, description FROM public.support_settings ORDER BY key;

-- =====================================================
-- APÓS EXECUTAR, AS CONFIGURAÇÕES DE HORÁRIO DO FREE
-- ESTARÃO DISPONÍVEIS NO PAINEL ADMIN → ABA "Config"
-- =====================================================

-- RESULTADO ESPERADO:
-- | key               | value | description                                        |
-- |-------------------|-------|--------------------------------------------------|
-- | auto_reply_enabled | true  | Ativar/desativar mensagem automática de suporte  |
-- | auto_reply_message | ...   | Conteúdo da mensagem automática de suporte       |
-- | chat_end_hour     | 21    | Horário de fechamento do chat geral (0-23)       |
-- | chat_start_hour   | 9     | Horário de abertura do chat geral (0-23)         |
-- | free_end_hour     | 15    | Horário de fechamento do chat para plano FREE    |
-- | free_start_hour   | 10    | Horário de abertura do chat para plano FREE      |
