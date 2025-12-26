-- =====================================================
-- PASSO 1: CRIAR/ATUALIZAR TABELA COURSES
-- =====================================================
-- Execute APENAS esta parte primeiro
-- =====================================================

-- Criar tabela se não existir
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Adicionar colunas que podem estar faltando
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Verificar estrutura
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'courses' AND table_schema = 'public'
ORDER BY ordinal_position;
