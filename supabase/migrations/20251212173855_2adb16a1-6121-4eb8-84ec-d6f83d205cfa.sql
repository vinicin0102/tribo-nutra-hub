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

-- Habilitar RLS
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ver cursos publicados
CREATE POLICY "Published courses are viewable by everyone" 
ON public.courses 
FOR SELECT 
USING (is_published = true);

-- Política: Admins podem ver todos os cursos
CREATE POLICY "Admins can view all courses" 
ON public.courses 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem inserir cursos
CREATE POLICY "Admins can insert courses" 
ON public.courses 
FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem atualizar cursos
CREATE POLICY "Admins can update courses" 
ON public.courses 
FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem deletar cursos
CREATE POLICY "Admins can delete courses" 
ON public.courses 
FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Adicionar coluna course_id à tabela modules se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'modules' AND column_name = 'course_id'
  ) THEN
    ALTER TABLE public.modules ADD COLUMN course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_courses_order ON public.courses(order_index);
CREATE INDEX IF NOT EXISTS idx_courses_published ON public.courses(is_published);
CREATE INDEX IF NOT EXISTS idx_modules_course ON public.modules(course_id);