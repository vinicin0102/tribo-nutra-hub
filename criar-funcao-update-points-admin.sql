-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ATUALIZAR PONTOS (ADMIN)
-- =====================================================
-- Esta função executa com privilégios elevados (SECURITY DEFINER)
-- e ignora as RLS policies, permitindo que admins atualizem pontos
-- =====================================================

-- Dropar função se já existir
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);

-- Criar função com SECURITY DEFINER
CREATE OR REPLACE FUNCTION update_user_points_admin(
  p_user_id UUID,
  p_points INTEGER
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
      'error', 'Sem permissão. Apenas admins podem atualizar pontos.'
    );
  END IF;

  -- Verificar se o perfil existe
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado'
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
    'message', 'Pontos atualizados com sucesso',
    'user_id', p_user_id,
    'points', p_points
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
GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID, INTEGER) TO authenticated;

-- Verificar se a função foi criada
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments
FROM pg_proc
WHERE proname = 'update_user_points_admin';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================
-- Agora você pode usar esta função RPC para atualizar pontos
-- Ela ignora as RLS policies porque executa com SECURITY DEFINER
-- =====================================================

