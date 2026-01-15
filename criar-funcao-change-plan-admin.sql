-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ALTERAR PLANO (ADMIN)
-- =====================================================
-- Esta função executa com privilégios elevados (SECURITY DEFINER)
-- e ignora as RLS policies, permitindo que admins alterem planos
-- =====================================================

-- Dropar função se já existir
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);

-- Criar função com SECURITY DEFINER
CREATE OR REPLACE FUNCTION change_user_plan_admin(
  p_user_id UUID,
  p_plan TEXT,
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com privilégios do criador da função
SET search_path = public
AS $$
DECLARE
  v_current_user_email TEXT;
  v_current_user_role TEXT;
  v_result JSON;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT email INTO v_current_user_email
  FROM auth.users
  WHERE id = auth.uid();

  SELECT role INTO v_current_user_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin
  IF v_current_user_email != 'admin@gmail.com' 
     AND v_current_user_email != 'vv9250400@gmail.com'
     AND v_current_user_role != 'admin' THEN
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

  -- Verificar se o perfil existe
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

  -- Se for diamond, atualizar também a tabela subscriptions se existir
  IF p_plan = 'diamond' AND p_expires_at IS NOT NULL THEN
    -- Inserir ou atualizar na tabela subscriptions
    INSERT INTO subscriptions (user_id, plan, expires_at, created_at, updated_at)
    VALUES (p_user_id, 'diamond', p_expires_at, NOW(), NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET
      plan = 'diamond',
      expires_at = p_expires_at,
      updated_at = NOW();
  ELSIF p_plan = 'free' THEN
    -- Remover da tabela subscriptions se existir
    DELETE FROM subscriptions WHERE user_id = p_user_id;
  END IF;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'Plano alterado com sucesso',
    'user_id', p_user_id,
    'plan', p_plan,
    'expires_at', p_expires_at
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- Garantir que a função seja executável por usuários autenticados
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;

-- Verificar se a função foi criada
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments
FROM pg_proc
WHERE proname = 'change_user_plan_admin';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora você pode usar esta função RPC para alterar planos
-- Ela ignora as RLS policies porque executa com SECURITY DEFINER
-- =====================================================

