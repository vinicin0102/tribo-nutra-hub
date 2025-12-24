-- =====================================================
-- REMOVER admin@gmail.com COMPLETAMENTE
-- E DEIXAR APENAS auxiliodp1@gmail.com COMO ADMIN
-- =====================================================
-- EXECUTE ESTE SCRIPT NO SQL EDITOR DO SUPABASE
-- =====================================================

-- 1. REMOVER admin@gmail.com DA TABELA admin_users
DELETE FROM admin_users WHERE email = 'admin@gmail.com';

-- 2. ATUALIZAR ROLE DE admin@gmail.com PARA 'user'
UPDATE profiles SET role = 'user', updated_at = NOW() WHERE email = 'admin@gmail.com';

-- 3. GARANTIR QUE auxiliodp1@gmail.com É ADMIN SUPREMO
INSERT INTO admin_users (email, role, name) 
VALUES ('auxiliodp1@gmail.com', 'admin', 'Admin Supremo')
ON CONFLICT (email) DO UPDATE SET role = 'admin', name = 'Admin Supremo', updated_at = NOW();

UPDATE profiles SET role = 'admin', updated_at = NOW() WHERE email = 'auxiliodp1@gmail.com';

-- 4. SUBSTITUIR A FUNÇÃO is_admin_user (SEM admin@gmail.com)
DROP FUNCTION IF EXISTS is_admin_user();
CREATE OR REPLACE FUNCTION is_admin_user()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  
  -- Admin Supremo - SEMPRE tem acesso
  IF v_email = 'auxiliodp1@gmail.com' THEN
    RETURN TRUE;
  END IF;
  
  -- Outros admins autorizados (SEM admin@gmail.com)
  IF v_email IN ('admin02@gmail.com', 'vv9250400@gmail.com') THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar tabela admin_users
  IF EXISTS(SELECT 1 FROM admin_users WHERE email = v_email) THEN
    RETURN TRUE;
  END IF;
  
  -- Verificar profile
  IF EXISTS(SELECT 1 FROM profiles WHERE user_id = auth.uid() AND role IN ('admin', 'support')) THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$;

-- 5. ATUALIZAR change_user_plan_admin (SEM admin@gmail.com)
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
CREATE OR REPLACE FUNCTION change_user_plan_admin(p_user_id UUID, p_plan TEXT, p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  
  -- Admin Supremo = bypass total
  IF v_email = 'auxiliodp1@gmail.com' THEN
    UPDATE profiles SET subscription_plan = p_plan, subscription_expires_at = p_expires_at, updated_at = NOW() WHERE user_id = p_user_id;
    RETURN json_build_object('success', true, 'message', 'Plano alterado pelo Admin Supremo');
  END IF;
  
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão. Apenas admins podem alterar planos.');
  END IF;
  
  UPDATE profiles SET subscription_plan = p_plan, subscription_expires_at = p_expires_at, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Plano alterado com sucesso');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;

-- 6. ATUALIZAR OUTRAS FUNÇÕES RPC
DROP FUNCTION IF EXISTS ban_user_temporary(UUID, INTEGER);
CREATE OR REPLACE FUNCTION ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  IF v_email != 'auxiliodp1@gmail.com' AND NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  UPDATE profiles SET is_banned = true, banned_until = NOW() + (p_days || ' days')::INTERVAL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário banido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION ban_user_temporary(UUID, INTEGER) TO authenticated;

DROP FUNCTION IF EXISTS unban_user(UUID);
CREATE OR REPLACE FUNCTION unban_user(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  IF v_email != 'auxiliodp1@gmail.com' AND NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  UPDATE profiles SET is_banned = false, banned_until = NULL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário desbanido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION unban_user(UUID) TO authenticated;

DROP FUNCTION IF EXISTS mute_user(UUID, INTEGER);
CREATE OR REPLACE FUNCTION mute_user(p_user_id UUID, p_hours INTEGER DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_mute_until TIMESTAMP WITH TIME ZONE;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  IF v_email != 'auxiliodp1@gmail.com' AND NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  IF p_hours IS NOT NULL THEN v_mute_until := NOW() + (p_hours || ' hours')::INTERVAL; END IF;
  UPDATE profiles SET is_muted = true, mute_until = v_mute_until, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário mutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION mute_user(UUID, INTEGER) TO authenticated;

DROP FUNCTION IF EXISTS unmute_user_admin(UUID);
CREATE OR REPLACE FUNCTION unmute_user_admin(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  IF v_email != 'auxiliodp1@gmail.com' AND NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  UPDATE profiles SET is_muted = false, mute_until = NULL, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Usuário desmutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION unmute_user_admin(UUID) TO authenticated;

DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);
CREATE OR REPLACE FUNCTION update_user_points_admin(p_user_id UUID, p_points INTEGER)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  IF v_email != 'auxiliodp1@gmail.com' AND NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  UPDATE profiles SET points = p_points, updated_at = NOW() WHERE user_id = p_user_id;
  RETURN json_build_object('success', true, 'message', 'Pontos atualizados');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success', false, 'error', SQLERRM);
END;$$;
GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID, INTEGER) TO authenticated;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT '🔥 admin@gmail.com REMOVIDO!' as status;
SELECT '✅ auxiliodp1@gmail.com é o ADMIN SUPREMO!' as status;

-- Verificar admins atuais
SELECT email, role, name FROM admin_users ORDER BY email;

-- Verificar profiles com role admin
SELECT email, role FROM profiles WHERE role IN ('admin', 'support') ORDER BY email;
