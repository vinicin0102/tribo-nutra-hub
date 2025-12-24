-- =====================================================
-- ATUALIZAR FUNÇÕES RPC: Trocar admin@gmail.com por auxiliodp1@gmail.com
-- =====================================================

-- 1. Atualizar função is_admin()
CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  RETURN v_caller_email IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') 
     OR v_caller_role = 'admin';
END;
$function$;

-- 2. Atualizar função change_user_plan_admin()
CREATE OR REPLACE FUNCTION public.change_user_plan_admin(p_user_id uuid, p_plan text, p_expires_at timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  IF v_caller_email NOT IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role != 'admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem alterar planos.'
    );
  END IF;

  IF p_plan NOT IN ('free', 'diamond') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Plano inválido. Use "free" ou "diamond".'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  UPDATE profiles
  SET 
    subscription_plan = p_plan,
    subscription_expires_at = p_expires_at,
    updated_at = NOW()
  WHERE user_id = p_user_id;

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
$function$;

-- 3. Atualizar função unban_user_admin()
CREATE OR REPLACE FUNCTION public.unban_user_admin(p_user_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  IF v_caller_email NOT IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role NOT IN ('admin', 'support')) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem desbanir usuários.'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

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
$function$;

-- 4. Atualizar função unlock_mentoria_for_user()
CREATE OR REPLACE FUNCTION public.unlock_mentoria_for_user(p_user_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_admin_id UUID;
  v_admin_email TEXT;
  v_locked_modules UUID[];
  v_modules_unlocked INTEGER := 0;
  v_module_id UUID;
BEGIN
  SELECT id, email INTO v_admin_id, v_admin_email
  FROM auth.users
  WHERE id = auth.uid();
  
  IF v_admin_email NOT IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = v_admin_id 
      AND role IN ('admin', 'support')
    ) THEN
      RAISE EXCEPTION 'Apenas administradores podem liberar mentoria';
    END IF;
  END IF;
  
  SELECT ARRAY_AGG(id) INTO v_locked_modules
  FROM public.modules
  WHERE is_locked = true;
  
  IF v_locked_modules IS NULL OR array_length(v_locked_modules, 1) IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Nenhum módulo bloqueado encontrado'
    );
  END IF;
  
  FOREACH v_module_id IN ARRAY v_locked_modules
  LOOP
    BEGIN
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (p_user_id, v_module_id);
      v_modules_unlocked := v_modules_unlocked + 1;
    EXCEPTION
      WHEN unique_violation THEN
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
$function$;

-- 5. Atualizar função unmute_user_admin()
CREATE OR REPLACE FUNCTION public.unmute_user_admin(p_user_id uuid)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  IF v_caller_email NOT IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role NOT IN ('admin', 'support')) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem desmutar usuários.'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

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
$function$;

-- 6. Atualizar função update_user_points_admin()
CREATE OR REPLACE FUNCTION public.update_user_points_admin(p_user_id uuid, p_points integer)
 RETURNS json
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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

  IF v_caller_email NOT IN ('auxiliodp1@gmail.com', 'vv9250400@gmail.com') 
     AND (v_caller_role IS NULL OR v_caller_role != 'admin') THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Sem permissão. Apenas admins podem alterar pontos.'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM profiles WHERE user_id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Usuário não encontrado.'
    );
  END IF;

  IF p_points < 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Pontos não podem ser negativos.'
    );
  END IF;

  UPDATE profiles
  SET 
    points = p_points,
    updated_at = NOW()
  WHERE user_id = p_user_id;

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
$function$;

-- 7. Garantir que auxiliodp1@gmail.com tenha role = 'admin' no perfil
UPDATE profiles 
SET role = 'admin', updated_at = NOW() 
WHERE email = 'auxiliodp1@gmail.com';

-- 8. Remover role admin de admin@gmail.com (se existir)
UPDATE profiles 
SET role = 'user', updated_at = NOW() 
WHERE email = 'admin@gmail.com' AND role = 'admin';