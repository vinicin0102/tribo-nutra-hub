-- =====================================================
-- FUNÇÕES RPC PARA PAINEL ADMIN
-- =====================================================

-- 1. Dropar funções antigas se existirem
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT);
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);

-- 2. Criar função para alterar plano do usuário
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
  IF v_caller_email NOT IN ('admin@gmail.com', 'vv9250400@gmail.com') 
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

-- 3. Criar função para atualizar pontos do usuário
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
  IF v_caller_email NOT IN ('admin@gmail.com', 'vv9250400@gmail.com') 
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

-- 4. Conceder permissões
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID, INTEGER) TO authenticated;