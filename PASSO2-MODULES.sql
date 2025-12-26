-- =====================================================
-- PASSO 2: CRIAR/ATUALIZAR TABELA MODULES
-- =====================================================
-- Execute DEPOIS do Passo 1
-- =====================================================

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS public.modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Verificar estrutura
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'modules' AND table_schema = 'public'
ORDER BY ordinal_position;
