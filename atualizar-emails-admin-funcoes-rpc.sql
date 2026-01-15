-- =====================================================
-- ATUALIZAR EMAILS ADMIN EM TODAS AS FUNÇÕES RPC
-- =====================================================
-- Este script adiciona 'admin02@gmail.com' e 'auxiliodp1@gmail.com'
-- à lista de emails admin em todas as funções RPC
-- =====================================================

-- 1. Atualizar função change_user_plan_admin
CREATE OR REPLACE FUNCTION change_user_plan_admin(
  p_user_id UUID,
  p_plan TEXT,
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar role do usuário atual
  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin (por email conhecido ou role)
  IF v_caller_email NOT IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role != 'admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem alterar planos.'
    );
  END IF;

  -- Validar plano
  IF p_plan NOT IN ('free', 'diamond') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Plano inválido. Use "free" ou "diamond".'
    );
  END IF;

  -- Verificar se usuário existe
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  -- Atualizar plano
  UPDATE profiles
  SET 
    subscription_plan = p_plan,
    subscription_expires_at = p_expires_at,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'Plano alterado com sucesso para ' || p_plan
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 2. Atualizar função update_user_points_admin
CREATE OR REPLACE FUNCTION update_user_points_admin(
  p_user_id UUID,
  p_points INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar role do usuário atual
  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin
  IF v_caller_email NOT IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role != 'admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem alterar pontos.'
    );
  END IF;

  -- Verificar se usuário existe
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  -- Validar pontos (não pode ser negativo)
  IF p_points < 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Pontos não podem ser negativos.'
    );
  END IF;

  -- Atualizar pontos
  UPDATE profiles
  SET 
    points = p_points,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'Pontos atualizados para ' || p_points
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 3. Atualizar função unlock_mentoria_for_user
CREATE OR REPLACE FUNCTION public.unlock_mentoria_for_user(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_admin_id UUID;
  v_admin_email TEXT;
  v_locked_modules UUID[];
  v_modules_unlocked INTEGER := 0;
  v_module_id UUID;
BEGIN
  -- Verificar se o usuário é admin
  SELECT id, email INTO v_admin_id, v_admin_email
  FROM auth.users
  WHERE id = auth.uid();
  
  -- Verificar se é admin (email admin ou role admin/support)
  IF v_admin_email NOT IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = v_admin_id 
      AND role IN ('admin', 'support')
    ) THEN
      RAISE EXCEPTION 'Apenas administradores podem liberar mentoria';
    END IF;
  END IF;
  
  -- Buscar todos os módulos bloqueados
  SELECT ARRAY_AGG(id) INTO v_locked_modules
  FROM public.modules
  WHERE is_locked = true;
  
  IF v_locked_modules IS NULL OR array_length(v_locked_modules, 1) IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Nenhum módulo bloqueado encontrado'
    );
  END IF;
  
  -- Desbloquear todos os módulos bloqueados para o usuário
  FOREACH v_module_id IN ARRAY v_locked_modules
  LOOP
    BEGIN
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (p_user_id, v_module_id);
      v_modules_unlocked := v_modules_unlocked + 1;
    EXCEPTION
      WHEN unique_violation THEN
        -- Módulo já estava desbloqueado, ignorar
        NULL;
    END;
  END LOOP;
  
  RETURN json_build_object(
    'success', true,
    'modules_unlocked', v_modules_unlocked,
    'total_modules', array_length(v_locked_modules, 1),
    'user_id', p_user_id
  );
END;
$$;

-- 4. Atualizar função unban_user_admin
CREATE OR REPLACE FUNCTION public.unban_user_admin(p_user_id uuid)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar role do usuário atual
  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin ou support
  IF v_caller_email NOT IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role NOT IN ('admin', 'support')) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem desbanir usuários.'
    );
  END IF;

  -- Verificar se usuário existe
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  -- Desbanir usuário
  UPDATE profiles
  SET 
    is_banned = false,
    banned_until = null,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Usuário desbanido com sucesso.'
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 5. Atualizar função unmute_user_admin
CREATE OR REPLACE FUNCTION public.unmute_user_admin(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar role do usuário atual
  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin
  IF v_caller_email NOT IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role NOT IN ('admin', 'support')) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem desmutar usuários.'
    );
  END IF;

  -- Verificar se usuário existe
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  -- Desmutar usuário
  UPDATE profiles
  SET 
    is_muted = false,
    mute_until = null,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Usuário desmutado com sucesso.'
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- 6. Atualizar função is_admin() (usada em políticas RLS)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_email TEXT;
  v_caller_role TEXT;
BEGIN
  SELECT email INTO v_caller_email
  FROM auth.users
  WHERE id = auth.uid();

  SELECT role INTO v_caller_role
  FROM profiles
  WHERE user_id = auth.uid();

  RETURN v_caller_email IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com') 
     OR v_caller_role = 'admin';
END;
$$;

-- 7. Atualizar políticas RLS que verificam email diretamente
DROP POLICY IF EXISTS "Support can delete support chat messages" ON public.support_chat;

CREATE POLICY "Support can delete support chat messages" ON public.support_chat FOR DELETE 
  USING (
    auth.uid() IN (SELECT user_id FROM public.profiles WHERE role IN ('support', 'admin'))
    OR EXISTS (SELECT 1 FROM auth.users WHERE id = auth.uid() AND email IN ('admin02@gmail.com', 'vv9250400@gmail.com', 'auxiliodp1@gmail.com'))
  );

-- =====================================================
-- RESUMO
-- =====================================================
-- Emails admin atualizados para incluir:
-- - admin02@gmail.com
-- - vv9250400@gmail.com
-- - auxiliodp1@gmail.com
-- =====================================================

SELECT 
  '✅ Funções atualizadas!' as status,
  proname as nome_funcao
FROM pg_proc
WHERE proname IN ('change_user_plan_admin', 'update_user_points_admin', 'unlock_mentoria_for_user', 'unban_user_admin', 'unmute_user_admin', 'is_admin')
ORDER BY proname;

