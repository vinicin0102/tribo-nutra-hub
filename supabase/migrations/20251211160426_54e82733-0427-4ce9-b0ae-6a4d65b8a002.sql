-- Criar função RPC para desbanir usuários (SECURITY DEFINER ignora RLS)
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
  IF v_caller_email NOT IN ('admin@gmail.com', 'vv9250400@gmail.com') 
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

-- Conceder permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION public.unban_user_admin TO authenticated;