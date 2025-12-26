-- =====================================================
-- PASSO 3: CRIAR/ATUALIZAR TABELA LESSONS
-- =====================================================
-- Execute DEPOIS do Passo 2
-- =====================================================

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS vturb_code TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS pdf_url TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS external_links JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Verificar estrutura
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'lessons' AND table_schema = 'public'
ORDER BY ordinal_position;
