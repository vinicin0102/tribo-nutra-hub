
-- Adicionar colunas faltantes na tabela profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS mute_until TIMESTAMP WITH TIME ZONE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- Adicionar colunas faltantes na tabela posts
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS is_support_post BOOLEAN DEFAULT false;

-- Criar tabela daily_points se não existir
CREATE TABLE IF NOT EXISTS public.daily_points (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    points_earned INTEGER NOT NULL DEFAULT 0,
    login_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE(user_id, login_date)
);

-- Habilitar RLS na tabela daily_points
ALTER TABLE public.daily_points ENABLE ROW LEVEL SECURITY;

-- Policies para daily_points
CREATE POLICY "Users can view own daily points" 
ON public.daily_points FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily points" 
ON public.daily_points FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Função para registrar login diário
CREATE OR REPLACE FUNCTION public.record_daily_login(p_user_id UUID)
RETURNS TABLE(points_earned INTEGER, already_logged BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_points INTEGER := 10;
    v_already_logged BOOLEAN := false;
BEGIN
    -- Verificar se já logou hoje
    IF EXISTS (
        SELECT 1 FROM public.daily_points 
        WHERE user_id = p_user_id 
        AND login_date = CURRENT_DATE
    ) THEN
        v_already_logged := true;
        v_points := 0;
    ELSE
        -- Inserir registro de login
        INSERT INTO public.daily_points (user_id, points_earned, login_date)
        VALUES (p_user_id, v_points, CURRENT_DATE);
        
        -- Adicionar pontos ao perfil
        UPDATE public.profiles 
        SET points = COALESCE(points, 0) + v_points
        WHERE user_id = p_user_id;
    END IF;
    
    RETURN QUERY SELECT v_points, v_already_logged;
END;
$$;

-- Função para resgatar recompensa
CREATE OR REPLACE FUNCTION public.redeem_reward(p_user_id UUID, p_reward_id UUID)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_points_required INTEGER;
    v_user_points INTEGER;
    v_reward_name TEXT;
BEGIN
    -- Buscar pontos necessários
    SELECT points_required, name INTO v_points_required, v_reward_name
    FROM public.rewards WHERE id = p_reward_id AND is_active = true;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Recompensa não encontrada'::TEXT;
        RETURN;
    END IF;
    
    -- Buscar pontos do usuário
    SELECT COALESCE(points, 0) INTO v_user_points
    FROM public.profiles WHERE user_id = p_user_id;
    
    IF v_user_points < v_points_required THEN
        RETURN QUERY SELECT false, 'Pontos insuficientes'::TEXT;
        RETURN;
    END IF;
    
    -- Deduzir pontos
    UPDATE public.profiles 
    SET points = points - v_points_required
    WHERE user_id = p_user_id;
    
    -- Criar resgate
    INSERT INTO public.redemptions (user_id, reward_id, points_spent, status)
    VALUES (p_user_id, p_reward_id, v_points_required, 'pending');
    
    RETURN QUERY SELECT true, ('Resgate de ' || v_reward_name || ' realizado com sucesso!')::TEXT;
END;
$$;

-- Função para banir usuário temporariamente
CREATE OR REPLACE FUNCTION public.ban_user_temporary(p_user_id UUID, p_days INTEGER)
RETURNS TABLE(success BOOLEAN, error TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.profiles 
    SET is_banned = true, 
        banned_until = CURRENT_TIMESTAMP + (p_days || ' days')::INTERVAL
    WHERE user_id = p_user_id;
    
    RETURN QUERY SELECT true, NULL::TEXT;
END;
$$;

-- Função para mutar usuário
CREATE OR REPLACE FUNCTION public.mute_user(p_user_id UUID, p_hours INTEGER)
RETURNS TABLE(success BOOLEAN, error TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.profiles 
    SET is_muted = true, 
        mute_until = CURRENT_TIMESTAMP + (p_hours || ' hours')::INTERVAL
    WHERE user_id = p_user_id;
    
    RETURN QUERY SELECT true, NULL::TEXT;
END;
$$;
