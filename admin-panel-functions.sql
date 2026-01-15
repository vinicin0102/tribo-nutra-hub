-- =====================================================
-- FUNÇÕES DO PAINEL ADMINISTRATIVO
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. ADICIONAR COLUNAS NECESSÁRIAS NA TABELA PROFILES
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS banned_until TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS mute_until TIMESTAMP WITH TIME ZONE;

-- 2. FUNÇÃO: BANIR USUÁRIO POR 3 DIAS
CREATE OR REPLACE FUNCTION public.ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_banned = true,
    banned_until = NOW() + (p_days || ' days')::INTERVAL
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'ban',
    'Conta Suspensa',
    'Sua conta foi suspensa por ' || p_days || ' dias. Você poderá acessar novamente após ' || 
    (NOW() + (p_days || ' days')::INTERVAL)::DATE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. FUNÇÃO: DESBANIR USUÁRIO
CREATE OR REPLACE FUNCTION public.unban_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_banned = false,
    banned_until = NULL
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'unban',
    'Conta Restaurada',
    'Sua conta foi restaurada. Você pode acessar a plataforma novamente.'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. FUNÇÃO: MUTAR USUÁRIO NA COMUNIDADE
CREATE OR REPLACE FUNCTION public.mute_user(p_user_id UUID, p_days INTEGER DEFAULT NULL)
RETURNS void AS $$
DECLARE
  v_mute_until TIMESTAMP WITH TIME ZONE;
BEGIN
  IF p_days IS NULL THEN
    -- Mutar permanentemente
    v_mute_until := NULL;
  ELSE
    -- Mutar temporariamente
    v_mute_until := NOW() + (p_days || ' days')::INTERVAL;
  END IF;
  
  UPDATE public.profiles
  SET 
    is_muted = true,
    mute_until = v_mute_until
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'mute',
    'Conta Mutada',
    CASE 
      WHEN p_days IS NULL THEN 'Você foi mutado permanentemente na comunidade.'
      ELSE 'Você foi mutado por ' || p_days || ' dias. Você não poderá postar ou comentar até ' || 
           v_mute_until::DATE
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. FUNÇÃO: DESMUTAR USUÁRIO
CREATE OR REPLACE FUNCTION public.unmute_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_muted = false,
    mute_until = NULL
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'unmute',
    'Conta Desmutada',
    'Você pode postar e comentar novamente na comunidade.'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. FUNÇÃO: EXCLUIR USUÁRIO
CREATE OR REPLACE FUNCTION public.delete_user_account(p_user_id UUID)
RETURNS void AS $$
BEGIN
  -- Deletar da tabela auth.users (isso vai cascatear para profiles e outras tabelas)
  DELETE FROM auth.users WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. FUNÇÃO: MUDAR PLANO DO USUÁRIO
CREATE OR REPLACE FUNCTION public.change_user_plan(
  p_user_id UUID,
  p_plan TEXT,
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    subscription_plan = p_plan,
    subscription_expires_at = p_expires_at,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  -- Se mudou para diamond, atualizar também a tabela subscriptions (se existir)
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
    INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_end, created_at, updated_at)
    VALUES (p_user_id, p_plan, 'active', p_expires_at, NOW(), NOW())
    ON CONFLICT (user_id) DO UPDATE
    SET 
      plan_type = p_plan,
      status = 'active',
      current_period_end = p_expires_at,
      updated_at = NOW();
  END IF;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'subscription',
    'Plano Alterado',
    'Seu plano foi alterado para ' || UPPER(p_plan) || 
    CASE WHEN p_expires_at IS NULL THEN ' (vitalício)' ELSE ' até ' || p_expires_at::DATE END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. FUNÇÃO: ALTERAR PONTUAÇÃO
CREATE OR REPLACE FUNCTION public.update_user_points(
  p_user_id UUID,
  p_points INTEGER,
  p_reason TEXT DEFAULT NULL
)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    points = GREATEST(0, p_points),
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  -- Criar notificação
  INSERT INTO public.notifications (user_id, type, title, message)
  VALUES (
    p_user_id,
    'points',
    'Pontuação Alterada',
    'Sua pontuação foi alterada para ' || p_points || ' pontos.' ||
    CASE WHEN p_reason IS NOT NULL THEN ' Motivo: ' || p_reason ELSE '' END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. FUNÇÃO: VERIFICAR E REMOVER BANS/MUTES EXPIRADOS
CREATE OR REPLACE FUNCTION public.check_expired_bans_mutes()
RETURNS void AS $$
BEGIN
  -- Remover bans expirados
  UPDATE public.profiles
  SET 
    is_banned = false,
    banned_until = NULL
  WHERE is_banned = true 
    AND banned_until IS NOT NULL 
    AND banned_until < NOW();
  
  -- Remover mutes expirados
  UPDATE public.profiles
  SET 
    is_muted = false,
    mute_until = NULL
  WHERE is_muted = true 
    AND mute_until IS NOT NULL 
    AND mute_until < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. CRIAR TRIGGER PARA VERIFICAR BANS/MUTES EXPIRADOS (opcional - pode ser chamado via cron)
-- Você pode criar um cron job no Supabase para executar check_expired_bans_mutes() periodicamente

-- 11. VERIFICAR RESULTADO
SELECT 
  'Funções do painel administrativo criadas com sucesso!' as status,
  'Banir 3 dias: ban_user_temporary(user_id, 3)' as ban_function,
  'Mutar: mute_user(user_id, days)' as mute_function,
  'Mudar plano: change_user_plan(user_id, plan, expires_at)' as plan_function,
  'Alterar pontos: update_user_points(user_id, points, reason)' as points_function;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

