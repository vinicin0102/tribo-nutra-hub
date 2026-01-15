-- =====================================================
-- ADMIN SUPREMO - auxiliodp1@gmail.com
-- =====================================================
-- Este script dá TODAS as permissões possíveis para o email
-- =====================================================

-- 1. ATUALIZAR ROLE NA TABELA PROFILES
UPDATE profiles 
SET role = 'admin', updated_at = NOW()
WHERE email = 'auxiliodp1@gmail.com';

-- 2. ADICIONAR NA TABELA ADMIN_USERS (se existir)
INSERT INTO admin_users (email, role, name)
VALUES ('auxiliodp1@gmail.com', 'admin', 'Admin Supremo')
ON CONFLICT (email) DO UPDATE SET role = 'admin', name = 'Admin Supremo', updated_at = NOW();

-- 3. CRIAR FUNÇÃO QUE DÁ BYPASS TOTAL PARA ESTE EMAIL
CREATE OR REPLACE FUNCTION is_supreme_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  
  -- Admin supremo tem acesso total
  IF v_email = 'auxiliodp1@gmail.com' THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 4. ATUALIZAR FUNÇÃO is_admin_user PARA INCLUIR ADMIN SUPREMO
CREATE OR REPLACE FUNCTION is_admin_user()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email TEXT;
  v_is_admin BOOLEAN;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  
  -- Admin Supremo - acesso total
  IF v_email = 'auxiliodp1@gmail.com' THEN
    RETURN TRUE;
  END IF;
  
  -- Lista de admins conhecidos
  IF v_email IN ('admin@gmail.com', 'admin02@gmail.com', 'vv9250400@gmail.com') THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar tabela admin_users
  SELECT EXISTS(SELECT 1 FROM admin_users WHERE email = v_email) INTO v_is_admin;
  IF v_is_admin THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar role no profile
  SELECT EXISTS(
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role IN ('admin', 'support')
  ) INTO v_is_admin;
  
  RETURN v_is_admin;
END;
$$;

-- 5. ATUALIZAR TODAS AS FUNÇÕES RPC PARA DAR BYPASS AO ADMIN SUPREMO

-- change_user_plan_admin
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
CREATE OR REPLACE FUNCTION change_user_plan_admin(p_user_id UUID, p_plan TEXT, p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  IF p_plan NOT IN ('free', 'diamond') THEN 
    RETURN json_build_object('success', false, 'error', 'Plano inválido'); 
  END IF;
  UPDATE profiles SET subscription_plan = p_plan, subscription_expires_at = p_expires_at, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Plano alterado com sucesso');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;

-- ban_user_temporary
DROP FUNCTION IF EXISTS ban_user_temporary(UUID, INTEGER);
CREATE OR REPLACE FUNCTION ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_user() THEN RETURN json_build_object('success', false, 'error', 'Sem permissão'); END IF;
  UPDATE profiles SET is_banned = true, banned_until = NOW() + (p_days || ' days')::INTERVAL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário banido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION ban_user_temporary(UUID, INTEGER) TO authenticated;

-- unban_user
DROP FUNCTION IF EXISTS unban_user(UUID);
CREATE OR REPLACE FUNCTION unban_user(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_user() THEN RETURN json_build_object('success', false, 'error', 'Sem permissão'); END IF;
  UPDATE profiles SET is_banned = false, banned_until = NULL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário desbanido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION unban_user(UUID) TO authenticated;

-- mute_user
DROP FUNCTION IF EXISTS mute_user(UUID, INTEGER);
CREATE OR REPLACE FUNCTION mute_user(p_user_id UUID, p_hours INTEGER DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_mute_until TIMESTAMP WITH TIME ZONE;
BEGIN
  IF NOT is_admin_user() THEN RETURN json_build_object('success', false, 'error', 'Sem permissão'); END IF;
  IF p_hours IS NOT NULL THEN v_mute_until := NOW() + (p_hours || ' hours')::INTERVAL; ELSE v_mute_until := NULL; END IF;
  UPDATE profiles SET is_muted = true, mute_until = v_mute_until, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário mutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION mute_user(UUID, INTEGER) TO authenticated;

-- unmute_user_admin
DROP FUNCTION IF EXISTS unmute_user_admin(UUID);
CREATE OR REPLACE FUNCTION unmute_user_admin(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_user() THEN RETURN json_build_object('success', false, 'error', 'Sem permissão'); END IF;
  UPDATE profiles SET is_muted = false, mute_until = NULL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário desmutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION unmute_user_admin(UUID) TO authenticated;

-- update_user_points_admin
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);
CREATE OR REPLACE FUNCTION update_user_points_admin(p_user_id UUID, p_points INTEGER)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT is_admin_user() THEN RETURN json_build_object('success', false, 'error', 'Sem permissão'); END IF;
  UPDATE profiles SET points = p_points, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Pontos atualizados', 'points', p_points);
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID, INTEGER) TO authenticated;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT '✅ ADMIN SUPREMO CONFIGURADO!' as status;
SELECT email, role FROM profiles WHERE email = 'auxiliodp1@gmail.com';
SELECT * FROM admin_users WHERE email = 'auxiliodp1@gmail.com';

-- =====================================================
-- PRONTO! 🔥
-- auxiliodp1@gmail.com agora é o ADMIN SUPREMO!
-- Tem acesso TOTAL a todas as funções do sistema.
-- =====================================================
