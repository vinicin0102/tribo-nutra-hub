-- =====================================================
-- CORRIGIR FUNÇÕES DO PAINEL ADMINISTRATIVO
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. ADICIONAR TODAS AS COLUNAS NECESSÁRIAS NA TABELA PROFILES
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_banned BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS banned_until TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_muted BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS mute_until TIMESTAMP WITH TIME ZONE;

-- 2. DROP E RECRIAR FUNÇÃO: BANIR USUÁRIO POR 3 DIAS
DROP FUNCTION IF EXISTS public.ban_user_temporary(UUID, INTEGER);
CREATE OR REPLACE FUNCTION public.ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_banned = true,
    banned_until = NOW() + (p_days || ' days')::INTERVAL
  WHERE user_id = p_user_id;
  
  -- Verificar se atualizou algum registro
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', p_user_id;
  END IF;
  
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

-- 3. DROP E RECRIAR FUNÇÃO: DESBANIR USUÁRIO
DROP FUNCTION IF EXISTS public.unban_user(UUID);
CREATE OR REPLACE FUNCTION public.unban_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_banned = false,
    banned_until = NULL
  WHERE user_id = p_user_id;
  
  -- Verificar se atualizou algum registro
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', p_user_id;
  END IF;
  
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

-- 4. DROP E RECRIAR FUNÇÃO: MUTAR USUÁRIO NA COMUNIDADE
DROP FUNCTION IF EXISTS public.mute_user(UUID, INTEGER);
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
  
  -- Verificar se atualizou algum registro
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', p_user_id;
  END IF;
  
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

-- 5. DROP E RECRIAR FUNÇÃO: DESMUTAR USUÁRIO
DROP FUNCTION IF EXISTS public.unmute_user(UUID);
CREATE OR REPLACE FUNCTION public.unmute_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.profiles
  SET 
    is_muted = false,
    mute_until = NULL
  WHERE user_id = p_user_id;
  
  -- Verificar se atualizou algum registro
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Usuário não encontrado: %', p_user_id;
  END IF;
  
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

-- 6. GRANT PERMISSÕES PARA AS FUNÇÕES (garantir que admin pode executar)
GRANT EXECUTE ON FUNCTION public.ban_user_temporary(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unban_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mute_user(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unmute_user(UUID) TO authenticated;

-- 7. VERIFICAR RESULTADO
SELECT 
  'Funções do painel administrativo corrigidas com sucesso!' as status,
  'Banir 3 dias: ban_user_temporary(user_id, 3)' as ban_function,
  'Mutar 7 dias: mute_user(user_id, 7)' as mute_7_days,
  'Mutar permanente: mute_user(user_id, NULL)' as mute_permanent,
  'Desbanir: unban_user(user_id)' as unban_function,
  'Desmutar: unmute_user(user_id)' as unmute_function;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

