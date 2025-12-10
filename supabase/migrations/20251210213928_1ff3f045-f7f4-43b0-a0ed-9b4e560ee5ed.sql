-- Criar tabela para armazenar progresso das aulas
CREATE TABLE public.lesson_progress (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);

-- Habilitar RLS
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Users can view own progress"
ON public.lesson_progress
FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can mark lessons complete"
ON public.lesson_progress
FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove progress"
ON public.lesson_progress
FOR DELETE
USING (auth.uid() = user_id);

-- Índices para performance
CREATE INDEX idx_lesson_progress_user_id ON public.lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson_id ON public.lesson_progress(lesson_id);