-- Criar tabela course_banners
CREATE TABLE IF NOT EXISTS public.course_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url TEXT,
  title TEXT,
  description TEXT,
  link_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.course_banners ENABLE ROW LEVEL SECURITY;

-- Política: Todos podem ler banners ativos
CREATE POLICY "Banners are viewable by everyone" 
ON public.course_banners 
FOR SELECT 
USING (true);

-- Política: Admins podem inserir banners
CREATE POLICY "Admins can insert banners" 
ON public.course_banners 
FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem atualizar banners
CREATE POLICY "Admins can update banners" 
ON public.course_banners 
FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem deletar banners
CREATE POLICY "Admins can delete banners" 
ON public.course_banners 
FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Criar índice para busca rápida de banners ativos
CREATE INDEX IF NOT EXISTS idx_course_banners_active 
ON public.course_banners(is_active) 
WHERE is_active = true;

-- Adicionar políticas para badges (admin CRUD)
DO $$ 
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Admins can insert badges" ON public.badges;
  DROP POLICY IF EXISTS "Admins can update badges" ON public.badges;
  DROP POLICY IF EXISTS "Admins can delete badges" ON public.badges;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Política: Admins podem inserir badges
CREATE POLICY "Admins can insert badges" 
ON public.badges 
FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem atualizar badges
CREATE POLICY "Admins can update badges" 
ON public.badges 
FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem deletar badges
CREATE POLICY "Admins can delete badges" 
ON public.badges 
FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Adicionar políticas para rewards (admin CRUD)
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Admins can insert rewards" ON public.rewards;
  DROP POLICY IF EXISTS "Admins can update rewards" ON public.rewards;
  DROP POLICY IF EXISTS "Admins can delete rewards" ON public.rewards;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- Política: Admins podem inserir rewards
CREATE POLICY "Admins can insert rewards" 
ON public.rewards 
FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem atualizar rewards
CREATE POLICY "Admins can update rewards" 
ON public.rewards 
FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- Política: Admins podem deletar rewards
CREATE POLICY "Admins can delete rewards" 
ON public.rewards 
FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);