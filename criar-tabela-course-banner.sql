-- Criar tabela para armazenar banner do curso
CREATE TABLE IF NOT EXISTS public.course_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url TEXT,
  title TEXT,
  description TEXT,
  link_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  -- Garantir que só existe um banner ativo
  CONSTRAINT single_active_banner CHECK (
    (is_active = true AND (SELECT COUNT(*) FROM public.course_banners WHERE is_active = true) <= 1) OR
    is_active = false
  )
);

-- Habilitar RLS
ALTER TABLE public.course_banners ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ler banners ativos
CREATE POLICY "Banners are viewable by everyone" 
ON public.course_banners 
FOR SELECT 
USING (is_active = true);

-- Política: Apenas admins podem inserir/atualizar/deletar
CREATE POLICY "Only admins can manage banners" 
ON public.course_banners 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND is_admin = true
  )
);

-- Criar índice para busca rápida
CREATE INDEX IF NOT EXISTS idx_course_banners_active 
ON public.course_banners(is_active) 
WHERE is_active = true;

-- Comentários
COMMENT ON TABLE public.course_banners IS 'Banner promocional da área de membros';
COMMENT ON COLUMN public.course_banners.is_active IS 'Apenas um banner pode estar ativo por vez';

