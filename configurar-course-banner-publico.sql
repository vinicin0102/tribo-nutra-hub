-- Garantir que a tabela course_banners existe
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

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Banners are viewable by everyone" ON public.course_banners;
DROP POLICY IF EXISTS "Only admins can manage banners" ON public.course_banners;
DROP POLICY IF EXISTS "Public read access for active banners" ON public.course_banners;
DROP POLICY IF EXISTS "Admins can manage banners" ON public.course_banners;

-- Habilitar RLS
ALTER TABLE public.course_banners ENABLE ROW LEVEL SECURITY;

-- Política: TODOS podem ler banners ativos (público)
CREATE POLICY "Public read access for active banners" 
ON public.course_banners 
FOR SELECT 
USING (is_active = true);

-- Política: Apenas admins podem inserir/atualizar/deletar
-- Verificar se a coluna is_admin existe na tabela profiles
DO $$
BEGIN
  -- Verificar se a coluna is_admin existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'profiles' 
    AND column_name = 'is_admin'
  ) THEN
    -- Criar política usando is_admin
    EXECUTE '
    CREATE POLICY "Admins can manage banners" 
    ON public.course_banners 
    FOR ALL 
    USING (
      EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE user_id = auth.uid() 
        AND is_admin = true
      )
    )';
  ELSE
    -- Se não existe is_admin, permitir para usuários autenticados (temporário)
    EXECUTE '
    CREATE POLICY "Admins can manage banners" 
    ON public.course_banners 
    FOR ALL 
    USING (auth.uid() IS NOT NULL)';
  END IF;
END $$;

-- Criar índice para busca rápida
CREATE INDEX IF NOT EXISTS idx_course_banners_active 
ON public.course_banners(is_active) 
WHERE is_active = true;

-- Verificar se existe algum banner ativo
DO $$
DECLARE
  active_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO active_count 
  FROM public.course_banners 
  WHERE is_active = true;
  
  IF active_count = 0 THEN
    RAISE NOTICE 'Nenhum banner ativo encontrado. Crie um banner no painel admin.';
  ELSE
    RAISE NOTICE 'Encontrado % banner(s) ativo(s).', active_count;
  END IF;
END $$;

