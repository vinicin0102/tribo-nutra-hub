-- =====================================================
-- CORRIGIR LOGIN DIÁRIO: APENAS 8 PONTOS, UMA VEZ POR DIA
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. FUNÇÃO: ADICIONAR PONTOS PARA LOGIN DIÁRIO (CORRIGIDA)
CREATE OR REPLACE FUNCTION public.add_points_for_daily_login(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_already_earned_today BOOLEAN;
BEGIN
  -- Verificar se já ganhou pontos de login hoje
  SELECT EXISTS (
    SELECT 1 
    FROM public.daily_points 
    WHERE user_id = p_user_id 
    AND points_date = CURRENT_DATE
    AND points_earned > 0
  ) INTO v_already_earned_today;
  
  -- Se já ganhou pontos hoje, não adicionar novamente
  IF v_already_earned_today THEN
    RETURN jsonb_build_object(
      'success', false,
      'points_added', 0,
      'message', 'Você já ganhou seus pontos de login hoje!',
      'already_earned', true
    );
  END IF;
  
  -- Adicionar 8 pontos por login diário (apenas se ainda não ganhou hoje)
  v_result := public.add_points_with_limit(
    p_user_id,
    8,
    'login diário',
    '+8 pontos por login diário!'
  );
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. FUNÇÃO: REGISTRAR LOGIN DIÁRIO (CORRIGIDA)
CREATE OR REPLACE FUNCTION public.record_daily_login(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_consecutive_days INTEGER := 0;
  v_current_date DATE := CURRENT_DATE;
  v_check_date DATE := CURRENT_DATE;
  v_points_result JSONB;
  v_already_logged_today BOOLEAN;
  v_col_exists BOOLEAN;
BEGIN
  -- Verificar se a tabela user_daily_logins existe, se não, criar
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public'
    AND table_name = 'user_daily_logins'
  ) THEN
    CREATE TABLE IF NOT EXISTS public.user_daily_logins (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
      login_date DATE NOT NULL DEFAULT CURRENT_DATE,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
      UNIQUE(user_id, login_date)
    );
  END IF;
  
  -- Verificar se já fez login hoje
  SELECT EXISTS (
    SELECT 1 FROM public.user_daily_logins 
    WHERE user_id = p_user_id 
    AND login_date = v_current_date
  ) INTO v_already_logged_today;
  
  -- Se já fez login hoje, não adicionar pontos novamente
  IF v_already_logged_today THEN
    -- Apenas atualizar dias consecutivos, sem adicionar pontos
    LOOP
      IF EXISTS (
        SELECT 1 FROM public.user_daily_logins 
        WHERE user_id = p_user_id 
        AND login_date = v_check_date
      ) THEN
        v_consecutive_days := v_consecutive_days + 1;
        v_check_date := v_check_date - INTERVAL '1 day';
      ELSE
        EXIT;
      END IF;
    END LOOP;
    
    -- Atualizar consecutive_days (se a coluna existir)
    SELECT EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public'
      AND table_name = 'profiles' 
      AND column_name = 'consecutive_days'
    ) INTO v_col_exists;
    
    IF v_col_exists THEN
      UPDATE public.profiles
      SET consecutive_days = v_consecutive_days
      WHERE user_id = p_user_id;
    END IF;
    
    RETURN jsonb_build_object(
      'success', false,
      'message', 'Login já registrado hoje. Você já ganhou seus 8 pontos!',
      'already_logged', true,
      'consecutive_days', v_consecutive_days
    );
  END IF;
  
  -- Inserir login de hoje (primeira vez hoje)
  INSERT INTO public.user_daily_logins (user_id, login_date)
  VALUES (p_user_id, v_current_date)
  ON CONFLICT (user_id, login_date) DO NOTHING;
  
  -- Adicionar 8 pontos por login diário (apenas na primeira vez hoje)
  v_points_result := public.add_points_for_daily_login(p_user_id);
  
  -- Verificar quantos dias consecutivos o usuário fez login
  LOOP
    IF EXISTS (
      SELECT 1 FROM public.user_daily_logins 
      WHERE user_id = p_user_id 
      AND login_date = v_check_date
    ) THEN
      v_consecutive_days := v_consecutive_days + 1;
      v_check_date := v_check_date - INTERVAL '1 day';
    ELSE
      EXIT;
    END IF;
  END LOOP;
  
  -- Atualizar o perfil
  -- Verificar se consecutive_days existe
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name = 'profiles' 
    AND column_name = 'consecutive_days'
  ) INTO v_col_exists;
  
  IF v_col_exists THEN
    UPDATE public.profiles
    SET consecutive_days = v_consecutive_days
    WHERE user_id = p_user_id;
  END IF;
  
  -- Verificar se last_login_date existe e atualizar
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public'
    AND table_name = 'profiles' 
    AND column_name = 'last_login_date'
  ) INTO v_col_exists;
  
  IF v_col_exists THEN
    UPDATE public.profiles
    SET last_login_date = v_current_date
    WHERE user_id = p_user_id;
  END IF;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_result', v_points_result,
    'consecutive_days', v_consecutive_days,
    'message', 'Login registrado! +8 pontos!'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. REMOVER FUNÇÕES ANTIGAS QUE DÃO 100 PONTOS (se existirem)
DROP FUNCTION IF EXISTS public.check_daily_login(UUID);
DROP FUNCTION IF EXISTS public.check_daily_login(UUID, TEXT);

-- 4. VERIFICAR RESULTADO
SELECT 
  'Função de login diário corrigida!' as status,
  'Agora dá apenas 8 pontos, uma vez por dia' as info;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

