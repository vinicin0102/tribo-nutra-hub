-- ============================================
-- ATUALIZAR SISTEMA DE PONTUAÇÃO
-- ============================================
-- Execute este script no SQL Editor do Supabase

-- 1. Atualizar função de pontos para posts (5 pontos por post)
CREATE OR REPLACE FUNCTION public.add_points_for_post()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  post_count INTEGER;
BEGIN
  -- Verificar se é a primeira postagem (concede Bronze)
  SELECT COUNT(*) INTO post_count
  FROM public.posts
  WHERE user_id = NEW.user_id;
  
  -- Se for a primeira postagem, definir tier como bronze e adicionar 5 pontos
  IF post_count = 1 THEN
    UPDATE public.profiles 
    SET tier = 'bronze', points = COALESCE(points, 0) + 5
    WHERE user_id = NEW.user_id;
  ELSE
    -- Adicionar 5 pontos para postagens seguintes
    UPDATE public.profiles 
    SET points = COALESCE(points, 0) + 5
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- 2. Adicionar coluna para controle de login diário
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'last_daily_login'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN last_daily_login DATE;
    RAISE NOTICE 'Coluna last_daily_login adicionada';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'daily_login_streak'
  ) THEN
    ALTER TABLE public.profiles 
    ADD COLUMN daily_login_streak INTEGER DEFAULT 0;
    RAISE NOTICE 'Coluna daily_login_streak adicionada';
  END IF;
END $$;

-- 3. Criar função para registrar login diário (100 pontos)
CREATE OR REPLACE FUNCTION public.check_daily_login(user_uuid UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  last_login DATE;
  current_streak INTEGER;
BEGIN
  -- Buscar último login
  SELECT last_daily_login, daily_login_streak 
  INTO last_login, current_streak
  FROM public.profiles
  WHERE user_id = user_uuid;
  
  -- Se nunca logou ou já logou hoje, não dar pontos
  IF last_login = CURRENT_DATE THEN
    RETURN FALSE;
  END IF;
  
  -- Verificar se manteve a sequência (logou ontem)
  IF last_login = CURRENT_DATE - INTERVAL '1 day' THEN
    current_streak := COALESCE(current_streak, 0) + 1;
  ELSE
    current_streak := 1; -- Reiniciar sequência
  END IF;
  
  -- Atualizar perfil com pontos e streak
  UPDATE public.profiles
  SET 
    points = COALESCE(points, 0) + 100,
    last_daily_login = CURRENT_DATE,
    daily_login_streak = current_streak
  WHERE user_id = user_uuid;
  
  RETURN TRUE;
END;
$$;

-- 4. Atualizar valores dos prêmios (acima de 5000 pontos)
UPDATE rewards SET points_cost = 5000 WHERE name = 'Pix Misterioso';
UPDATE rewards SET points_cost = 7500 WHERE name = 'Um Dia de Anúncios';
UPDATE rewards SET points_cost = 10000 WHERE name = 'Dia com a Equipe';
UPDATE rewards SET points_cost = 15000 WHERE name = 'Viagem Tudo Pago';
UPDATE rewards SET points_cost = 25000 WHERE name = 'iPhone Novo';

-- 5. Verificar atualizações
SELECT 'Sistema de pontos atualizado!' as status;

SELECT name, points_cost 
FROM rewards 
ORDER BY points_cost ASC;

SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'profiles' AND column_name = 'last_daily_login'
    ) THEN '✓ Sistema de login diário criado'
    ELSE '✗ Sistema de login diário não criado'
  END as check_daily_login;

