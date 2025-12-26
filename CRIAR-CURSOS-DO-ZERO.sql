-- =====================================================
-- CRIAR TABELAS DE CURSOS DO ZERO
-- =====================================================
-- Execute este script COMPLETO no Supabase SQL Editor
-- =====================================================

-- 1. CRIAR TABELA DE CURSOS
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  cover_url TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. CRIAR TABELA DE MÓDULOS (depende de courses)
CREATE TABLE IF NOT EXISTS public.modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  cover_url TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  unlock_after_days INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. CRIAR TABELA DE AULAS (depende de modules)
CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  vturb_code TEXT,
  pdf_url TEXT,
  cover_url TEXT,
  external_links JSONB DEFAULT '[]'::jsonb,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  is_locked BOOLEAN DEFAULT false,
  unlock_after_days INTEGER DEFAULT 0,
  duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. CRIAR TABELA DE MÓDULOS DESBLOQUEADOS
CREATE TABLE IF NOT EXISTS public.unlocked_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- 5. HABILITAR RLS
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlocked_modules ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR ÍNDICES
CREATE INDEX IF NOT EXISTS idx_courses_order ON public.courses(order_index);
CREATE INDEX IF NOT EXISTS idx_modules_course ON public.modules(course_id);
CREATE INDEX IF NOT EXISTS idx_modules_order ON public.modules(order_index);
CREATE INDEX IF NOT EXISTS idx_lessons_module ON public.lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON public.lessons(order_index);
CREATE INDEX IF NOT EXISTS idx_unlocked_modules_user ON public.unlocked_modules(user_id);

-- 7. POLÍTICAS SIMPLES - COURSES
DROP POLICY IF EXISTS "Anyone can view courses" ON public.courses;
CREATE POLICY "Anyone can view courses" ON public.courses FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage courses" ON public.courses;
CREATE POLICY "Admins can manage courses" ON public.courses FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support'))
);

-- 8. POLÍTICAS SIMPLES - MODULES
DROP POLICY IF EXISTS "Anyone can view modules" ON public.modules;
CREATE POLICY "Anyone can view modules" ON public.modules FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage modules" ON public.modules;
CREATE POLICY "Admins can manage modules" ON public.modules FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support'))
);

-- 9. POLÍTICAS SIMPLES - LESSONS
DROP POLICY IF EXISTS "Anyone can view lessons" ON public.lessons;
CREATE POLICY "Anyone can view lessons" ON public.lessons FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage lessons" ON public.lessons;
CREATE POLICY "Admins can manage lessons" ON public.lessons FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support'))
);

-- 10. POLÍTICAS SIMPLES - UNLOCKED_MODULES
DROP POLICY IF EXISTS "Users can view own unlocks" ON public.unlocked_modules;
CREATE POLICY "Users can view own unlocks" ON public.unlocked_modules FOR SELECT USING (
  user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support'))
);

DROP POLICY IF EXISTS "Admins can manage unlocks" ON public.unlocked_modules;
CREATE POLICY "Admins can manage unlocks" ON public.unlocked_modules FOR ALL USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support'))
);

-- 11. VERIFICAR QUE TUDO FOI CRIADO
SELECT 'courses' as tabela, count(*) as colunas FROM information_schema.columns WHERE table_name = 'courses' AND table_schema = 'public'
UNION ALL
SELECT 'modules' as tabela, count(*) as colunas FROM information_schema.columns WHERE table_name = 'modules' AND table_schema = 'public'
UNION ALL
SELECT 'lessons' as tabela, count(*) as colunas FROM information_schema.columns WHERE table_name = 'lessons' AND table_schema = 'public'
UNION ALL
SELECT 'unlocked_modules' as tabela, count(*) as colunas FROM information_schema.columns WHERE table_name = 'unlocked_modules' AND table_schema = 'public';

-- =====================================================
-- RESULTADO ESPERADO:
-- | tabela           | colunas |
-- |------------------|---------|
-- | courses          | 7       |
-- | modules          | 11      |
-- | lessons          | 14      |
-- | unlocked_modules | 4       |
-- =====================================================
