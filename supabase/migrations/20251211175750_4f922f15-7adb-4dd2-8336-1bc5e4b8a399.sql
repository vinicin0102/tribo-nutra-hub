-- Criar tabela para módulos desbloqueados manualmente
CREATE TABLE IF NOT EXISTS public.unlocked_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  module_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, module_id)
);

-- Habilitar RLS
ALTER TABLE public.unlocked_modules ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS
CREATE POLICY "Users can view own unlocked modules" 
  ON public.unlocked_modules 
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all unlocked modules" 
  ON public.unlocked_modules 
  FOR SELECT 
  USING (is_admin());

CREATE POLICY "Users can unlock modules for themselves" 
  ON public.unlocked_modules 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can unlock modules for anyone" 
  ON public.unlocked_modules 
  FOR INSERT 
  WITH CHECK (is_admin());

CREATE POLICY "Users can remove own unlocked modules" 
  ON public.unlocked_modules 
  FOR DELETE 
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can remove any unlocked modules" 
  ON public.unlocked_modules 
  FOR DELETE 
  USING (is_admin());

-- Adicionar coluna is_locked na tabela modules
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;

-- Remover coluna is_locked da tabela lessons (se existir)
ALTER TABLE public.lessons DROP COLUMN IF EXISTS is_locked;

-- Comentário na tabela
COMMENT ON TABLE public.unlocked_modules IS 'Módulos desbloqueados manualmente por admins ou usuários';