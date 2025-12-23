-- =====================================================
-- CRIAR TABELA DE POPUPS DO APP
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- 1. Criar tabela app_popups
CREATE TABLE IF NOT EXISTS public.app_popups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT,
  image_url TEXT,
  button_text TEXT,
  button_link TEXT,
  is_active BOOLEAN DEFAULT false,
  show_once_per_user BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);

-- 2. Habilitar RLS
ALTER TABLE public.app_popups ENABLE ROW LEVEL SECURITY;

-- 3. Criar políticas RLS
DO $$
BEGIN
  -- Política de SELECT (todos podem ver popups ativos)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'app_popups' 
    AND policyname = 'Anyone can view active popups'
  ) THEN
    CREATE POLICY "Anyone can view active popups" ON public.app_popups 
      FOR SELECT USING (is_active = true OR EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE user_id = auth.uid() 
        AND role IN ('admin', 'support')
      ));
  END IF;
  
  -- Política de INSERT (apenas admins)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'app_popups' 
    AND policyname = 'Only admins can create popups'
  ) THEN
    CREATE POLICY "Only admins can create popups" ON public.app_popups 
      FOR INSERT WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      );
  END IF;
  
  -- Política de UPDATE (apenas admins)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'app_popups' 
    AND policyname = 'Only admins can update popups'
  ) THEN
    CREATE POLICY "Only admins can update popups" ON public.app_popups 
      FOR UPDATE USING (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      );
  END IF;
  
  -- Política de DELETE (apenas admins)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'app_popups' 
    AND policyname = 'Only admins can delete popups'
  ) THEN
    CREATE POLICY "Only admins can delete popups" ON public.app_popups 
      FOR DELETE USING (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('admin', 'support')
        )
      );
  END IF;
END $$;

-- 4. Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_app_popups_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_app_popups_updated_at ON public.app_popups;
CREATE TRIGGER update_app_popups_updated_at
  BEFORE UPDATE ON public.app_popups
  FOR EACH ROW
  EXECUTE FUNCTION public.update_app_popups_updated_at();

-- 5. Tabela para rastrear quais usuários já viram o popup
CREATE TABLE IF NOT EXISTS public.popup_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  popup_id UUID REFERENCES public.app_popups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(popup_id, user_id)
);

ALTER TABLE public.popup_views ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'popup_views' 
    AND policyname = 'Users can manage their own popup views'
  ) THEN
    CREATE POLICY "Users can manage their own popup views" ON public.popup_views 
      FOR ALL USING (auth.uid() = user_id);
  END IF;
END $$;

-- 6. Verificar
SELECT 'Tabelas app_popups e popup_views criadas com sucesso!' as status;
