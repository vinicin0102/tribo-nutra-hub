-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ALTERAR PLANO (ADMIN) - VERSÃO CORRIGIDA
-- =====================================================
-- Esta função executa com privilégios elevados (SECURITY DEFINER)
-- e ignora as RLS policies, permitindo que admins alterem planos
-- =====================================================

-- Dropar função se já existir (com todas as variações possíveis)
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT);
DROP FUNCTION IF EXISTS public.change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS public.change_user_plan_admin(UUID, TEXT);

-- Criar função com SECURITY DEFINER
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
  v_current_user_email TEXT;
  v_current_user_role TEXT;
BEGIN
  -- Verificar se o usuário atual é admin
  SELECT email INTO v_current_user_email
  FROM auth.users
  WHERE id = auth.uid();

  -- Verificar role do perfil
  SELECT role INTO v_current_user_role
  FROM profiles
  WHERE user_id = auth.uid();

  -- Verificar se é admin
  IF (v_current_user_email IS NULL OR 
      (v_current_user_email != 'admin@gmail.com' 
       AND v_current_user_email != 'vv9250400@gmail.com'
       AND (v_current_user_role IS NULL OR v_current_user_role != 'admin'))) THEN
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

  -- Atualizar plano na tabela profiles
  UPDATE profiles
  SET 
    subscription_plan = p_plan,
    subscription_expires_at = p_expires_at,
    updated_at = NOW()
  WHERE user_id = p_user_id;

  -- Se for diamond e tiver data de expiração, atualizar tabela subscriptions (se existir)
  IF p_plan = 'diamond' AND p_expires_at IS NOT NULL THEN
    -- Verificar se a tabela subscriptions existe antes de tentar inserir
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
      INSERT INTO subscriptions (user_id, plan, expires_at, created_at, updated_at)
      VALUES (p_user_id, 'diamond', p_expires_at, NOW(), NOW())
      ON CONFLICT (user_id) 
      DO UPDATE SET
        plan = 'diamond',
        expires_at = p_expires_at,
        updated_at = NOW();
    END IF;
  ELSIF p_plan = 'free' THEN
    -- Remover da tabela subscriptions se existir
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'subscriptions') THEN
      DELETE FROM subscriptions WHERE user_id = p_user_id;
    END IF;
  END IF;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'Plano alterado com sucesso',
    'user_id', p_user_id::TEXT,
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
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO anon;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO service_role;

-- Verificar se a função foi criada
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments,
  prorettype::regtype as return_type
FROM pg_proc
WHERE proname = 'change_user_plan_admin';

-- Testar a função (comentado - descomente para testar)
-- SELECT change_user_plan_admin(
--   'USER_ID_AQUI'::UUID,
--   'diamond',
--   NULL
-- );

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora você pode usar esta função RPC para alterar planos
-- Ela ignora as RLS policies porque executa com SECURITY DEFINER
-- =====================================================

