-- Criar tabela de módulos
CREATE TABLE public.modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Criar tabela de aulas
CREATE TABLE public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  vturb_code TEXT,
  external_links JSONB DEFAULT '[]'::jsonb,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT false,
  duration_minutes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

-- Políticas para módulos - usuários autenticados podem ver módulos publicados
CREATE POLICY "Authenticated users can view published modules"
ON public.modules FOR SELECT
TO authenticated
USING (is_published = true);

-- Políticas para aulas - usuários autenticados podem ver aulas publicadas
CREATE POLICY "Authenticated users can view published lessons"
ON public.lessons FOR SELECT
TO authenticated
USING (is_published = true AND EXISTS (
  SELECT 1 FROM public.modules WHERE id = lessons.module_id AND is_published = true
));

-- Função para verificar se é admin (usando a função existente ou role)
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

  RETURN v_caller_email IN ('admin@gmail.com', 'vv9250400@gmail.com') 
     OR v_caller_role = 'admin';
END;
$$;

-- Políticas para admin ver todos os módulos
CREATE POLICY "Admins can view all modules"
ON public.modules FOR SELECT
TO authenticated
USING (public.is_admin());

-- Políticas para admin gerenciar módulos
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

-- Políticas para admin ver todas as aulas
CREATE POLICY "Admins can view all lessons"
ON public.lessons FOR SELECT
TO authenticated
USING (public.is_admin());

-- Políticas para admin gerenciar aulas
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

-- Índices para performance
CREATE INDEX idx_modules_order ON public.modules(order_index);
CREATE INDEX idx_lessons_module ON public.lessons(module_id);
CREATE INDEX idx_lessons_order ON public.lessons(order_index);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_modules_updated_at
BEFORE UPDATE ON public.modules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at
BEFORE UPDATE ON public.lessons
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();