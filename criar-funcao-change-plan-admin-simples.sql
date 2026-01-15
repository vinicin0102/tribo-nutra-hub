-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ALTERAR PLANO (ADMIN) - VERSÃO SIMPLES
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- Remover função antiga se existir
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT);

-- Criar função
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
  v_email TEXT;
  v_role TEXT;
BEGIN
  -- Pegar email do usuário atual
  SELECT email INTO v_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Pegar role do usuário atual
  SELECT role INTO v_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin
  IF (v_email IS DISTINCT FROM 'admin@gmail.com' 
      AND v_email IS DISTINCT FROM 'vv9250400@gmail.com'
      AND (v_role IS NULL OR v_role IS DISTINCT FROM 'admin')) THEN
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
      'error', 'Usuário não encontrado'
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
    'message', 'Plano alterado com sucesso',
    'user_id', p_user_id::TEXT,
    'plan', p_plan
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- Dar permissão para executar
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;

-- Verificar se foi criada
SELECT 
  'Função criada com sucesso!' as status,
  proname as function_name,
  prosecdef as security_definer
FROM pg_proc
WHERE proname = 'change_user_plan_admin';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

