-- =====================================================
-- PASSO 4: FINALIZAR (RLS e POLÍTICAS SIMPLIFICADAS)
-- =====================================================
-- Execute DEPOIS dos Passos 1, 2 e 3
-- =====================================================

-- Criar tabela unlocked_modules se não existir
CREATE TABLE IF NOT EXISTS public.unlocked_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- Habilitar RLS
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlocked_modules ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS SIMPLES - Permitir leitura para todos autenticados

-- COURSES
DROP POLICY IF EXISTS "view_courses" ON public.courses;
CREATE POLICY "view_courses" ON public.courses FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "insert_courses" ON public.courses;
CREATE POLICY "insert_courses" ON public.courses FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_courses" ON public.courses;
CREATE POLICY "update_courses" ON public.courses FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "delete_courses" ON public.courses;
CREATE POLICY "delete_courses" ON public.courses FOR DELETE TO authenticated USING (true);

-- MODULES
DROP POLICY IF EXISTS "view_modules" ON public.modules;
CREATE POLICY "view_modules" ON public.modules FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "insert_modules" ON public.modules;
CREATE POLICY "insert_modules" ON public.modules FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_modules" ON public.modules;
CREATE POLICY "update_modules" ON public.modules FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "delete_modules" ON public.modules;
CREATE POLICY "delete_modules" ON public.modules FOR DELETE TO authenticated USING (true);

-- LESSONS
DROP POLICY IF EXISTS "view_lessons" ON public.lessons;
CREATE POLICY "view_lessons" ON public.lessons FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "insert_lessons" ON public.lessons;
CREATE POLICY "insert_lessons" ON public.lessons FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_lessons" ON public.lessons;
CREATE POLICY "update_lessons" ON public.lessons FOR UPDATE TO authenticated USING (true);

DROP POLICY IF EXISTS "delete_lessons" ON public.lessons;
CREATE POLICY "delete_lessons" ON public.lessons FOR DELETE TO authenticated USING (true);

-- UNLOCKED_MODULES
DROP POLICY IF EXISTS "view_unlocked" ON public.unlocked_modules;
CREATE POLICY "view_unlocked" ON public.unlocked_modules FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "insert_unlocked" ON public.unlocked_modules;
CREATE POLICY "insert_unlocked" ON public.unlocked_modules FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "delete_unlocked" ON public.unlocked_modules;
CREATE POLICY "delete_unlocked" ON public.unlocked_modules FOR DELETE TO authenticated USING (true);

-- VERIFICAR TUDO
SELECT 'SUCESSO! Tabelas criadas:' as status;
SELECT table_name, count(*) as colunas 
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name IN ('courses', 'modules', 'lessons', 'unlocked_modules')
GROUP BY table_name
ORDER BY table_name;
