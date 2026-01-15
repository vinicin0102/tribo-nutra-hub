-- Criar tabela de cursos
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

-- Adicionar course_id na tabela modules (se não existir)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'modules' 
    AND column_name = 'course_id'
  ) THEN
    ALTER TABLE public.modules 
    ADD COLUMN course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE;
    
    -- Criar índice para performance
    CREATE INDEX IF NOT EXISTS idx_modules_course ON public.modules(course_id);
  END IF;
END $$;

-- Habilitar RLS na tabela courses
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Políticas para cursos - usuários autenticados podem ver cursos publicados
CREATE POLICY "Authenticated users can view published courses"
ON public.courses FOR SELECT
TO authenticated
USING (is_published = true);

-- Políticas para admin ver todos os cursos
CREATE POLICY "Admins can view all courses"
ON public.courses FOR SELECT
TO authenticated
USING (public.is_admin());

-- Políticas para admin gerenciar cursos
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

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_courses_order ON public.courses(order_index);

-- Trigger para atualizar updated_at em courses
CREATE TRIGGER update_courses_updated_at
BEFORE UPDATE ON public.courses
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Comentários
COMMENT ON TABLE public.courses IS 'Cursos que contêm módulos e aulas';
COMMENT ON COLUMN public.modules.course_id IS 'ID do curso ao qual o módulo pertence';

