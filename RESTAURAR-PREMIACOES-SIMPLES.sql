-- ============================================
-- RESTAURAR PREMIAÇÕES - VERSÃO SIMPLES
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- ============================================

-- Garantir que a tabela rewards existe
CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  points_cost INTEGER NOT NULL,
  stock INTEGER DEFAULT -1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Criar constraint UNIQUE na coluna name
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'rewards_name_key' 
      AND conrelid = 'public.rewards'::regclass
  ) THEN
    ALTER TABLE public.rewards ADD CONSTRAINT rewards_name_key UNIQUE (name);
  END IF;
END $$;

-- Deletar prêmios existentes (para recriar)
DELETE FROM public.rewards WHERE name IN ('Pix Misterioso', 'Um Dia de Anúncios', 'Viagem Tudo Pago', 'iPhone Novo');

-- Inserir prêmios
INSERT INTO public.rewards (name, description, points_cost, stock, is_active, image_url, created_at)
VALUES
  (
    'Pix Misterioso',
    'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!',
    2500,
    999,
    true,
    NULL,
    NOW()
  ),
  (
    'Um Dia de Anúncios',
    'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!',
    5000,
    50,
    true,
    NULL,
    NOW()
  ),
  (
    'Viagem Tudo Pago',
    'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.',
    75000,
    5,
    true,
    NULL,
    NOW()
  ),
  (
    'iPhone Novo',
    'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.',
    50000,
    3,
    true,
    NULL,
    NOW()
  );

-- Garantir que a tabela redemptions existe
CREATE TABLE IF NOT EXISTS public.redemptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE NOT NULL,
  points_spent INTEGER NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'delivered', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Habilitar RLS
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.redemptions ENABLE ROW LEVEL SECURITY;

-- Políticas para rewards
DROP POLICY IF EXISTS "Everyone can view active rewards" ON public.rewards;
CREATE POLICY "Everyone can view active rewards"
ON public.rewards FOR SELECT
TO public
USING (is_active = true);

-- Políticas para redemptions
DROP POLICY IF EXISTS "Users can view own redemptions" ON public.redemptions;
CREATE POLICY "Users can view own redemptions"
ON public.redemptions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create redemptions" ON public.redemptions;
CREATE POLICY "Users can create redemptions"
ON public.redemptions FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Verificar prêmios criados
SELECT 
  '✅ Prêmios restaurados!' as status,
  id,
  name,
  points_cost,
  stock,
  is_active
FROM public.rewards 
ORDER BY points_cost ASC;

