-- =====================================================
-- CORRIGIR FUNÇÕES DO PAINEL ADMINISTRATIVO - VERSÃO FINAL
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- Este script corrige TODOS os problemas possíveis
-- =====================================================

-- 1. ADICIONAR TODAS AS COLUNAS NECESSÁRIAS (se não existirem)
DO $$ 
BEGIN
  -- is_banned
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'is_banned'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN is_banned BOOLEAN DEFAULT false;
    RAISE NOTICE 'Coluna is_banned adicionada';
  END IF;
  
  -- banned_until
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'banned_until'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN banned_until TIMESTAMP WITH TIME ZONE;
    RAISE NOTICE 'Coluna banned_until adicionada';
  END IF;
  
  -- is_muted
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'is_muted'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN is_muted BOOLEAN DEFAULT false;
    RAISE NOTICE 'Coluna is_muted adicionada';
  END IF;
  
  -- mute_until
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'mute_until'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN mute_until TIMESTAMP WITH TIME ZONE;
    RAISE NOTICE 'Coluna mute_until adicionada';
  END IF;
END $$;

-- 2. DROP E RECRIAR FUNÇÃO: BANIR USUÁRIO POR 3 DIAS
DROP FUNCTION IF EXISTS public.ban_user_temporary(UUID, INTEGER);
DROP FUNCTION IF EXISTS public.ban_user_temporary(UUID);

CREATE OR REPLACE FUNCTION public.ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS JSON AS $$
DECLARE
  v_updated_rows INTEGER;
BEGIN
  -- Atualizar perfil
  UPDATE public.profiles
  SET 
    is_banned = true,
    banned_until = NOW() + (p_days || ' days')::INTERVAL,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  GET DIAGNOSTICS v_updated_rows = ROW_COUNT;
  
  -- Verificar se atualizou algum registro
  IF v_updated_rows = 0 THEN
    RETURN json_build_object(
      'success', false, 
      'error', 'Usuário não encontrado: ' || p_user_id::TEXT
    );
  END IF;
  
  -- Criar notificação (se a tabela existir)
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      p_user_id,
      'ban',
      'Conta Suspensa',
      'Sua conta foi suspensa por ' || p_days || ' dias. Você poderá acessar novamente após ' || 
      (NOW() + (p_days || ' days')::INTERVAL)::DATE
    );
  EXCEPTION WHEN OTHERS THEN
    -- Ignorar erro se tabela não existir
    NULL;
  END;
  
  RETURN json_build_object(
    'success', true, 
    'message', 'Usuário banido com sucesso',
    'banned_until', (NOW() + (p_days || ' days')::INTERVAL)::TEXT
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. DROP E RECRIAR FUNÇÃO: DESBANIR USUÁRIO
DROP FUNCTION IF EXISTS public.unban_user(UUID);

CREATE OR REPLACE FUNCTION public.unban_user(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_updated_rows INTEGER;
BEGIN
  UPDATE public.profiles
  SET 
    is_banned = false,
    banned_until = NULL,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  GET DIAGNOSTICS v_updated_rows = ROW_COUNT;
  
  IF v_updated_rows = 0 THEN
    RETURN json_build_object(
      'success', false, 
      'error', 'Usuário não encontrado: ' || p_user_id::TEXT
    );
  END IF;
  
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      p_user_id,
      'unban',
      'Conta Restaurada',
      'Sua conta foi restaurada. Você pode acessar a plataforma novamente.'
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
  
  RETURN json_build_object('success', true, 'message', 'Usuário desbanido com sucesso');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. DROP E RECRIAR FUNÇÃO: MUTAR USUÁRIO NA COMUNIDADE
DROP FUNCTION IF EXISTS public.mute_user(UUID, INTEGER);
DROP FUNCTION IF EXISTS public.mute_user(UUID);

CREATE OR REPLACE FUNCTION public.mute_user(p_user_id UUID, p_days INTEGER DEFAULT NULL)
RETURNS JSON AS $$
DECLARE
  v_mute_until TIMESTAMP WITH TIME ZONE;
  v_message TEXT;
  v_updated_rows INTEGER;
BEGIN
  IF p_days IS NULL THEN
    v_mute_until := NULL;
    v_message := 'Você foi mutado permanentemente na comunidade.';
  ELSE
    v_mute_until := NOW() + (p_days || ' days')::INTERVAL;
    v_message := 'Você foi mutado por ' || p_days || ' dias. Você não poderá postar ou comentar até ' || 
                 v_mute_until::DATE;
  END IF;
  
  UPDATE public.profiles
  SET 
    is_muted = true,
    mute_until = v_mute_until,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  GET DIAGNOSTICS v_updated_rows = ROW_COUNT;
  
  IF v_updated_rows = 0 THEN
    RETURN json_build_object(
      'success', false, 
      'error', 'Usuário não encontrado: ' || p_user_id::TEXT
    );
  END IF;
  
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      p_user_id,
      'mute',
      'Conta Mutada',
      v_message
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
  
  RETURN json_build_object(
    'success', true, 
    'message', 'Usuário mutado com sucesso',
    'mute_until', COALESCE(v_mute_until::TEXT, 'permanente')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. DROP E RECRIAR FUNÇÃO: DESMUTAR USUÁRIO
DROP FUNCTION IF EXISTS public.unmute_user(UUID);

CREATE OR REPLACE FUNCTION public.unmute_user(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_updated_rows INTEGER;
BEGIN
  UPDATE public.profiles
  SET 
    is_muted = false,
    mute_until = NULL,
    updated_at = NOW()
  WHERE user_id = p_user_id;
  
  GET DIAGNOSTICS v_updated_rows = ROW_COUNT;
  
  IF v_updated_rows = 0 THEN
    RETURN json_build_object(
      'success', false, 
      'error', 'Usuário não encontrado: ' || p_user_id::TEXT
    );
  END IF;
  
  BEGIN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      p_user_id,
      'unmute',
      'Conta Desmutada',
      'Você pode postar e comentar novamente na comunidade.'
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
  
  RETURN json_build_object('success', true, 'message', 'Usuário desmutado com sucesso');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. GRANT PERMISSÕES PARA AS FUNÇÕES
GRANT EXECUTE ON FUNCTION public.ban_user_temporary(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unban_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mute_user(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.unmute_user(UUID) TO authenticated;

-- 7. VERIFICAR RESULTADO
SELECT 
  '✅ Funções do painel administrativo criadas/atualizadas com sucesso!' as status,
  'Banir 3 dias: ban_user_temporary(user_id, 3)' as ban_function,
  'Mutar 7 dias: mute_user(user_id, 7)' as mute_7_days,
  'Mutar permanente: mute_user(user_id, NULL)' as mute_permanent,
  'Desbanir: unban_user(user_id)' as unban_function,
  'Desmutar: unmute_user(user_id)' as unmute_function;

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

