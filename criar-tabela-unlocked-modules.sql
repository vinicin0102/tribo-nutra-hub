-- Criar tabela para módulos desbloqueados manualmente
CREATE TABLE IF NOT EXISTS public.unlocked_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  module_id UUID REFERENCES public.modules(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- Habilitar RLS
ALTER TABLE public.unlocked_modules ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
CREATE POLICY "Users can view own unlocked modules" 
  ON public.unlocked_modules 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all unlocked modules" 
  ON public.unlocked_modules 
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND role = 'admin'
    )
  );

CREATE POLICY "Users can unlock modules for themselves" 
  ON public.unlocked_modules 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can unlock modules for anyone" 
  ON public.unlocked_modules 
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND role = 'admin'
    )
  );

CREATE POLICY "Users can remove own unlocked modules" 
  ON public.unlocked_modules 
  FOR DELETE 
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can remove any unlocked modules" 
  ON public.unlocked_modules 
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND role = 'admin'
    )
  );

-- Comentário na tabela
COMMENT ON TABLE public.unlocked_modules IS 'Módulos desbloqueados manualmente por admins ou usuários';

