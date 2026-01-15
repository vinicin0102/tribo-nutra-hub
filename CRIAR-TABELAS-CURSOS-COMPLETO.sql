-- =====================================================
-- CRIAR TABELAS DE CURSOS, MÓDULOS E AULAS
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- Ele cria todas as tabelas necessárias para o sistema
-- de cursos com liberação programada
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

-- 2. CRIAR TABELA DE MÓDULOS
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

-- 3. CRIAR TABELA DE AULAS
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

-- 4. CRIAR TABELA DE MÓDULOS DESBLOQUEADOS (para desbloqueio manual)
CREATE TABLE IF NOT EXISTS public.unlocked_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- 5. HABILITAR RLS EM TODAS AS TABELAS
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlocked_modules ENABLE ROW LEVEL SECURITY;

-- 6. FUNÇÃO PARA VERIFICAR SE É ADMIN
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  RETURN v_caller_email IN ('admin@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     OR v_caller_role IN ('admin', 'support');
END;
$$;

-- 7. POLÍTICAS PARA CURSOS
-- Usuários autenticados podem ver cursos publicados
CREATE POLICY "Authenticated users can view published courses"
ON public.courses FOR SELECT
TO authenticated
USING (is_published = true OR public.is_admin());

-- Admin pode gerenciar cursos
CREATE POLICY "Admins can insert courses"
ON public.courses FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update courses"
ON public.courses FOR UPDATE
TO authenticated
USING (public.is_admin());

CREATE POLICY "Admins can delete courses"
ON public.courses FOR DELETE
TO authenticated
USING (public.is_admin());

-- 8. POLÍTICAS PARA MÓDULOS
-- Usuários autenticados podem ver módulos publicados
CREATE POLICY "Authenticated users can view published modules"
ON public.modules FOR SELECT
TO authenticated
USING (is_published = true OR public.is_admin());

-- Admin pode gerenciar módulos
CREATE POLICY "Admins can insert modules"
ON public.modules FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update modules"
ON public.modules FOR UPDATE
TO authenticated
USING (public.is_admin());

CREATE POLICY "Admins can delete modules"
ON public.modules FOR DELETE
TO authenticated
USING (public.is_admin());

-- 9. POLÍTICAS PARA AULAS
-- Usuários autenticados podem ver aulas publicadas
CREATE POLICY "Authenticated users can view published lessons"
ON public.lessons FOR SELECT
TO authenticated
USING (is_published = true OR public.is_admin());

-- Admin pode gerenciar aulas
CREATE POLICY "Admins can insert lessons"
ON public.lessons FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update lessons"
ON public.lessons FOR UPDATE
TO authenticated
USING (public.is_admin());

CREATE POLICY "Admins can delete lessons"
ON public.lessons FOR DELETE
TO authenticated
USING (public.is_admin());

-- 10. POLÍTICAS PARA UNLOCKED_MODULES
-- Usuários podem ver seus próprios desbloqueios
CREATE POLICY "Users can view own unlocked modules"
ON public.unlocked_modules FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR public.is_admin());

-- Admin pode gerenciar desbloqueios
CREATE POLICY "Admins can insert unlocked modules"
ON public.unlocked_modules FOR INSERT
TO authenticated
WITH CHECK (public.is_admin() OR user_id = auth.uid());

CREATE POLICY "Admins can delete unlocked modules"
ON public.unlocked_modules FOR DELETE
TO authenticated
USING (public.is_admin());

-- 11. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_courses_order ON public.courses(order_index);
CREATE INDEX IF NOT EXISTS idx_modules_course ON public.modules(course_id);
CREATE INDEX IF NOT EXISTS idx_modules_order ON public.modules(order_index);
CREATE INDEX IF NOT EXISTS idx_lessons_module ON public.lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON public.lessons(order_index);
CREATE INDEX IF NOT EXISTS idx_unlocked_modules_user ON public.unlocked_modules(user_id);

-- 12. TRIGGER PARA UPDATED_AT
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para cada tabela
DROP TRIGGER IF EXISTS update_courses_updated_at ON public.courses;
CREATE TRIGGER update_courses_updated_at
BEFORE UPDATE ON public.courses
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_modules_updated_at ON public.modules;
CREATE TRIGGER update_modules_updated_at
BEFORE UPDATE ON public.modules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_lessons_updated_at ON public.lessons;
CREATE TRIGGER update_lessons_updated_at
BEFORE UPDATE ON public.lessons
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- 13. COMENTÁRIOS PARA DOCUMENTAÇÃO
COMMENT ON TABLE public.courses IS 'Cursos disponíveis na plataforma';
COMMENT ON TABLE public.modules IS 'Módulos dentro de cada curso';
COMMENT ON TABLE public.lessons IS 'Aulas dentro de cada módulo';
COMMENT ON TABLE public.unlocked_modules IS 'Módulos desbloqueados manualmente para usuários';

COMMENT ON COLUMN public.modules.is_locked IS 'Se true, módulo é exclusivo para Diamond e pode ter liberação programada';
COMMENT ON COLUMN public.modules.unlock_after_days IS 'Dias após compra do Diamond para liberar. 0 = imediato';
COMMENT ON COLUMN public.lessons.is_locked IS 'Se true, aula é bloqueada e pode ter liberação programada';
COMMENT ON COLUMN public.lessons.unlock_after_days IS 'Dias após compra do Diamond para liberar. 0 = imediato';

-- 14. VERIFICAR ESTRUTURA CRIADA
SELECT 
  'courses' as tabela, 
  count(*) as total_registros 
FROM public.courses
UNION ALL
SELECT 
  'modules' as tabela, 
  count(*) as total_registros 
FROM public.modules
UNION ALL
SELECT 
  'lessons' as tabela, 
  count(*) as total_registros 
FROM public.lessons;

-- =====================================================
-- RESULTADO ESPERADO:
-- | tabela   | total_registros |
-- |----------|-----------------|
-- | courses  | 0               |
-- | modules  | 0               |
-- | lessons  | 0               |
-- =====================================================
-- 
-- Agora você pode:
-- 1. Ir no painel Admin
-- 2. Criar um curso
-- 3. Criar módulos dentro do curso
-- 4. Marcar módulos como "Bloqueado" e definir dias
-- 5. Criar aulas e marcar como "Bloqueada" com dias
-- =====================================================
