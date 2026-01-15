-- =====================================================
-- ADICIONAR CONFIGURAÇÕES DE CHAT E MENSAGEM AUTOMÁTICA
-- =====================================================
-- Cria/atualiza a tabela support_settings com configurações
-- para horário do chat e mensagem automática
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

-- 2. Habilitar RLS
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

-- 4. Inserir/atualizar configurações padrão
INSERT INTO public.support_settings (key, value, description)
VALUES 
  ('chat_start_hour', '9', 'Horário de abertura do chat (0-23)'),
  ('chat_end_hour', '21', 'Horário de fechamento do chat (0-23)'),
  ('auto_reply_enabled', 'true', 'Ativar/desativar mensagem automática de suporte'),
  ('auto_reply_message', 'Olá! Recebemos sua mensagem. Nossa equipe de suporte responderá em até 10 minutos. Obrigado pela paciência! 🙏', 'Conteúdo da mensagem automática de suporte')
ON CONFLICT (key) DO UPDATE SET
  value = EXCLUDED.value,
  description = EXCLUDED.description,
  updated_at = now();

-- 5. Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_support_settings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$;

-- 6. Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS update_support_settings_updated_at ON public.support_settings;
CREATE TRIGGER update_support_settings_updated_at
  BEFORE UPDATE ON public.support_settings
  FOR EACH ROW
  EXECUTE FUNCTION public.update_support_settings_updated_at();

-- 7. Comentários
COMMENT ON TABLE public.support_settings IS 'Configurações do sistema de suporte: horário do chat e mensagem automática';
COMMENT ON COLUMN public.support_settings.key IS 'Chave da configuração (ex: chat_start_hour, auto_reply_enabled)';
COMMENT ON COLUMN public.support_settings.value IS 'Valor da configuração';

-- 8. Verificar configurações criadas
SELECT key, value, description FROM public.support_settings ORDER BY key;

