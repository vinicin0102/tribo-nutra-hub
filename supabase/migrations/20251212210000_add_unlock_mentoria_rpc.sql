-- Função RPC para admin liberar mentoria para qualquer usuário
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
  
  -- Verificar se é admin (email admin@gmail.com ou role admin/support)
  IF v_admin_email != 'admin@gmail.com' THEN
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
  
  -- Desbloquear todos os módulos bloqueados
  FOREACH v_module_id IN ARRAY v_locked_modules
  LOOP
    INSERT INTO public.unlocked_modules (user_id, module_id)
    VALUES (p_user_id, v_module_id)
    ON CONFLICT (user_id, module_id) DO NOTHING;
    
    IF FOUND THEN
      v_modules_unlocked := v_modules_unlocked + 1;
    END IF;
  END LOOP;
  
  RETURN json_build_object(
    'success', true,
    'modules_unlocked', array_length(v_locked_modules, 1),
    'user_id', p_user_id
  );
END;
$$;

COMMENT ON FUNCTION public.unlock_mentoria_for_user(UUID) IS 
'Permite que admins liberem a mentoria (todos os módulos bloqueados) para qualquer usuário';

