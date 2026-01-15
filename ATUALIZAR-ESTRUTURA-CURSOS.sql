-- =====================================================
-- ATUALIZAR ESTRUTURA DAS TABELAS DE CURSOS
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- Ele adiciona colunas faltantes às tabelas existentes
-- =====================================================

-- 1. ADICIONAR COLUNAS FALTANTES NA TABELA COURSES
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 2. ADICIONAR COLUNAS FALTANTES NA TABELA MODULES
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 3. ADICIONAR COLUNAS FALTANTES NA TABELA LESSONS
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS pdf_url TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS vturb_code TEXT;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS external_links JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS duration_minutes INTEGER DEFAULT 0;
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 4. COMENTÁRIOS PARA DOCUMENTAÇÃO
COMMENT ON COLUMN public.modules.is_locked IS 'Se true, módulo requer Diamond e pode ter liberação programada';
COMMENT ON COLUMN public.modules.unlock_after_days IS 'Dias após compra do Diamond para liberar. 0 = imediato';
COMMENT ON COLUMN public.lessons.is_locked IS 'Se true, aula é bloqueada e pode ter liberação programada';
COMMENT ON COLUMN public.lessons.unlock_after_days IS 'Dias após compra do Diamond para liberar. 0 = imediato';

-- 5. VERIFICAR ESTRUTURA
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('courses', 'modules', 'lessons')
  AND column_name IN ('is_published', 'is_locked', 'unlock_after_days')
ORDER BY table_name, column_name;

-- =====================================================
-- RESULTADO ESPERADO:
-- | table_name | column_name       | data_type |
-- |------------|-------------------|-----------|
-- | courses    | is_published      | boolean   |
-- | lessons    | is_locked         | boolean   |
-- | lessons    | is_published      | boolean   |
-- | lessons    | unlock_after_days | integer   |
-- | modules    | is_locked         | boolean   |
-- | modules    | is_published      | boolean   |
-- | modules    | unlock_after_days | integer   |
-- =====================================================
