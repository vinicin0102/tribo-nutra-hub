-- =====================================================
-- RECRIAR TABELA APP_POPUPS DO ZERO
-- =====================================================
-- Execute este script COMPLETO no Supabase SQL Editor
-- =====================================================

-- 1. Dropar tabelas existentes (se existirem)
DROP TABLE IF EXISTS public.popup_views CASCADE;
DROP TABLE IF EXISTS public.app_popups CASCADE;

-- 2. Criar tabela app_popups
CREATE TABLE public.app_popups (
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
  created_by UUID
);

-- 3. Criar tabela popup_views
CREATE TABLE public.popup_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  popup_id UUID REFERENCES public.app_popups(id) ON DELETE CASCADE,
  user_id UUID,
  viewed_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(popup_id, user_id)
);

-- 4. Conceder permissões GRANT para API REST
GRANT ALL ON public.app_popups TO anon;
GRANT ALL ON public.app_popups TO authenticated;
GRANT ALL ON public.app_popups TO service_role;

GRANT ALL ON public.popup_views TO anon;
GRANT ALL ON public.popup_views TO authenticated;
GRANT ALL ON public.popup_views TO service_role;

-- 5. Desabilitar RLS para garantir acesso
ALTER TABLE public.app_popups DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.popup_views DISABLE ROW LEVEL SECURITY;

-- 6. Notificar PostgREST para recarregar schema (importante!)
NOTIFY pgrst, 'reload schema';

-- 7. Verificar se tudo está correto
SELECT 
  'Tabelas criadas com sucesso!' as status,
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'app_popups') as app_popups_exists,
  (SELECT count(*) FROM information_schema.tables WHERE table_name = 'popup_views') as popup_views_exists;
