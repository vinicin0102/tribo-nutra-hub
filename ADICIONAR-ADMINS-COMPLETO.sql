-- =====================================================
-- SCRIPT PARA ADICIONAR ADMINS NO SUPABASE
-- Emails: auxiliodp1@gmail.com E admin02@gmail.com
-- =====================================================
-- EXECUTE TODO ESTE SCRIPT NO SQL EDITOR DO SUPABASE
-- =====================================================

-- 1. ATUALIZAR ROLE DOS USUÁRIOS PARA ADMIN
UPDATE profiles SET role = 'admin' WHERE email = 'auxiliodp1@gmail.com';
UPDATE profiles SET role = 'admin' WHERE email = 'admin02@gmail.com';

-- 2. FUNÇÃO: change_user_plan_admin
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT);

CREATE OR REPLACE FUNCTION change_user_plan_admin(p_user_id UUID, p_plan TEXT, p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão. Apenas admins podem alterar planos.');
  END IF;
  IF p_plan NOT IN ('free','diamond') THEN RETURN json_build_object('success',false,'error','Plano inválido'); END IF;
  UPDATE profiles SET subscription_plan=p_plan, subscription_expires_at=p_expires_at, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Plano alterado com sucesso');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID,TEXT,TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID,TEXT,TIMESTAMP WITH TIME ZONE) TO anon;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID,TEXT,TIMESTAMP WITH TIME ZONE) TO service_role;

-- 3. FUNÇÃO: ban_user_temporary
DROP FUNCTION IF EXISTS ban_user_temporary(UUID, INTEGER);

CREATE OR REPLACE FUNCTION ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão');
  END IF;
  UPDATE profiles SET is_banned=true, banned_until=NOW()+(p_days||' days')::INTERVAL, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Usuário banido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION ban_user_temporary(UUID,INTEGER) TO authenticated;

-- 4. FUNÇÃO: unban_user
DROP FUNCTION IF EXISTS unban_user(UUID);

CREATE OR REPLACE FUNCTION unban_user(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão');
  END IF;
  UPDATE profiles SET is_banned=false, banned_until=NULL, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Usuário desbanido');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION unban_user(UUID) TO authenticated;

-- 5. FUNÇÃO: mute_user
DROP FUNCTION IF EXISTS mute_user(UUID, INTEGER);

CREATE OR REPLACE FUNCTION mute_user(p_user_id UUID, p_hours INTEGER DEFAULT NULL)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT; v_mute_until TIMESTAMP WITH TIME ZONE;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão');
  END IF;
  IF p_hours IS NOT NULL THEN v_mute_until := NOW()+(p_hours||' hours')::INTERVAL; ELSE v_mute_until := NULL; END IF;
  UPDATE profiles SET is_muted=true, mute_until=v_mute_until, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Usuário mutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION mute_user(UUID,INTEGER) TO authenticated;

-- 6. FUNÇÃO: unmute_user_admin
DROP FUNCTION IF EXISTS unmute_user_admin(UUID);

CREATE OR REPLACE FUNCTION unmute_user_admin(p_user_id UUID)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão');
  END IF;
  UPDATE profiles SET is_muted=false, mute_until=NULL, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Usuário desmutado');
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION unmute_user_admin(UUID) TO authenticated;

-- 7. FUNÇÃO: update_user_points_admin
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);

CREATE OR REPLACE FUNCTION update_user_points_admin(p_user_id UUID, p_points INTEGER)
RETURNS JSON LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_email TEXT; v_role TEXT;
BEGIN
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  SELECT role INTO v_role FROM profiles WHERE user_id = auth.uid();
  IF v_email NOT IN ('admin@gmail.com','admin02@gmail.com','auxiliodp1@gmail.com','vv9250400@gmail.com') AND COALESCE(v_role,'') NOT IN ('admin','support') THEN
    RETURN json_build_object('success',false,'error','Sem permissão');
  END IF;
  UPDATE profiles SET points=p_points, updated_at=NOW() WHERE user_id=p_user_id;
  RETURN json_build_object('success',true,'message','Pontos atualizados','points',p_points);
EXCEPTION WHEN OTHERS THEN RETURN json_build_object('success',false,'error',SQLERRM);
END;$$;

GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID,INTEGER) TO authenticated;

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
SELECT 'ADMINS CONFIGURADOS:' as status;
SELECT email, role FROM profiles WHERE email IN ('auxiliodp1@gmail.com', 'admin02@gmail.com');

-- =====================================================
-- PRONTO! 🎉
-- auxiliodp1@gmail.com e admin02@gmail.com agora são ADMINS!
-- =====================================================
