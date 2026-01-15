-- =====================================================
-- CRIAR TABELA DE ADMINS E SUPORTE
-- =====================================================
-- Esta solução cria uma tabela 'admin_users' onde você pode
-- adicionar/remover admins facilmente sem precisar editar código
-- =====================================================

-- 1. CRIAR TABELA DE ADMINS
-- =====================================================
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'support')),
  name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índice para busca rápida por email
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);

-- 2. INSERIR ADMINS INICIAIS
-- =====================================================
INSERT INTO admin_users (email, role, name) VALUES
  ('admin@gmail.com', 'admin', 'Admin Principal'),
  ('admin02@gmail.com', 'admin', 'Admin 02'),
  ('auxiliodp1@gmail.com', 'admin', 'Auxilio DP'),
  ('vv9250400@gmail.com', 'admin', 'VV Admin')
ON CONFLICT (email) DO UPDATE SET role = EXCLUDED.role, updated_at = NOW();

-- 3. CRIAR FUNÇÃO PARA VERIFICAR SE É ADMIN
-- =====================================================
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
  -- Buscar email do usuário atual
  SELECT email INTO v_email FROM auth.users WHERE id = auth.uid();
  
  -- Verificar se está na tabela de admins
  SELECT EXISTS(SELECT 1 FROM admin_users WHERE email = v_email) INTO v_is_admin;
  
  -- Se não está na tabela de admins, verificar role no profile
  IF NOT v_is_admin THEN
    SELECT EXISTS(
      SELECT 1 FROM profiles 
      WHERE user_id = auth.uid() 
      AND role IN ('admin', 'support')
    ) INTO v_is_admin;
  END IF;
  
  RETURN v_is_admin;
END;
$$;

-- 4. ATUALIZAR FUNÇÃO: change_user_plan_admin
-- =====================================================
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT);

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
BEGIN
  -- Verificar se é admin usando a nova função
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão. Apenas admins podem alterar planos.');
  END IF;
  
  IF p_plan NOT IN ('free', 'diamond') THEN 
    RETURN json_build_object('success', false, 'error', 'Plano inválido'); 
  END IF;
  
  UPDATE profiles 
  SET subscription_plan = p_plan, 
      subscription_expires_at = p_expires_at, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Plano alterado com sucesso');
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO anon;
GRANT EXECUTE ON FUNCTION change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE) TO service_role;

-- 5. ATUALIZAR FUNÇÃO: ban_user_temporary
-- =====================================================
DROP FUNCTION IF EXISTS ban_user_temporary(UUID, INTEGER);

CREATE OR REPLACE FUNCTION ban_user_temporary(p_user_id UUID, p_days INTEGER DEFAULT 3)
RETURNS JSON 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public 
AS $$
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  
  UPDATE profiles 
  SET is_banned = true, 
      banned_until = NOW() + (p_days || ' days')::INTERVAL, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Usuário banido');
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION ban_user_temporary(UUID, INTEGER) TO authenticated;

-- 6. ATUALIZAR FUNÇÃO: unban_user
-- =====================================================
DROP FUNCTION IF EXISTS unban_user(UUID);

CREATE OR REPLACE FUNCTION unban_user(p_user_id UUID)
RETURNS JSON 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public 
AS $$
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  
  UPDATE profiles 
  SET is_banned = false, 
      banned_until = NULL, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Usuário desbanido');
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION unban_user(UUID) TO authenticated;

-- 7. ATUALIZAR FUNÇÃO: mute_user
-- =====================================================
DROP FUNCTION IF EXISTS mute_user(UUID, INTEGER);

CREATE OR REPLACE FUNCTION mute_user(p_user_id UUID, p_hours INTEGER DEFAULT NULL)
RETURNS JSON 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public 
AS $$
DECLARE 
  v_mute_until TIMESTAMP WITH TIME ZONE;
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  
  IF p_hours IS NOT NULL THEN 
    v_mute_until := NOW() + (p_hours || ' hours')::INTERVAL; 
  ELSE 
    v_mute_until := NULL; 
  END IF;
  
  UPDATE profiles 
  SET is_muted = true, 
      mute_until = v_mute_until, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Usuário mutado');
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION mute_user(UUID, INTEGER) TO authenticated;

-- 8. ATUALIZAR FUNÇÃO: unmute_user_admin
-- =====================================================
DROP FUNCTION IF EXISTS unmute_user_admin(UUID);

CREATE OR REPLACE FUNCTION unmute_user_admin(p_user_id UUID)
RETURNS JSON 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public 
AS $$
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  
  UPDATE profiles 
  SET is_muted = false, 
      mute_until = NULL, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Usuário desmutado');
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION unmute_user_admin(UUID) TO authenticated;

-- 9. ATUALIZAR FUNÇÃO: update_user_points_admin
-- =====================================================
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);

CREATE OR REPLACE FUNCTION update_user_points_admin(p_user_id UUID, p_points INTEGER)
RETURNS JSON 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path = public 
AS $$
BEGIN
  IF NOT is_admin_user() THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão');
  END IF;
  
  UPDATE profiles 
  SET points = p_points, 
      updated_at = NOW() 
  WHERE user_id = p_user_id;
  
  RETURN json_build_object('success', true, 'message', 'Pontos atualizados', 'points', p_points);
EXCEPTION 
  WHEN OTHERS THEN 
    RETURN json_build_object('success', false, 'error', SQLERRM);
END;
$$;

GRANT EXECUTE ON FUNCTION update_user_points_admin(UUID, INTEGER) TO authenticated;

-- =====================================================
-- 10. RLS PARA TABELA ADMIN_USERS
-- =====================================================
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Apenas admins podem ver a tabela
DROP POLICY IF EXISTS "Admins can view admin_users" ON admin_users;
CREATE POLICY "Admins can view admin_users" ON admin_users
  FOR SELECT USING (is_admin_user());

-- Apenas admins podem inserir
DROP POLICY IF EXISTS "Admins can insert admin_users" ON admin_users;
CREATE POLICY "Admins can insert admin_users" ON admin_users
  FOR INSERT WITH CHECK (is_admin_user());

-- Apenas admins podem atualizar
DROP POLICY IF EXISTS "Admins can update admin_users" ON admin_users;
CREATE POLICY "Admins can update admin_users" ON admin_users
  FOR UPDATE USING (is_admin_user());

-- Apenas admins podem deletar
DROP POLICY IF EXISTS "Admins can delete admin_users" ON admin_users;
CREATE POLICY "Admins can delete admin_users" ON admin_users
  FOR DELETE USING (is_admin_user());

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT '✅ TABELA CRIADA:' as status;
SELECT * FROM admin_users;

SELECT '✅ FUNÇÕES ATUALIZADAS:' as status;
SELECT proname FROM pg_proc WHERE proname IN (
  'is_admin_user',
  'change_user_plan_admin',
  'ban_user_temporary',
  'unban_user',
  'mute_user',
  'unmute_user_admin',
  'update_user_points_admin'
);

-- =====================================================
-- COMO ADICIONAR NOVOS ADMINS (DEPOIS)
-- =====================================================
-- Para adicionar um novo admin, execute:
-- INSERT INTO admin_users (email, role, name) VALUES ('email@exemplo.com', 'admin', 'Nome');
--
-- Para remover um admin, execute:
-- DELETE FROM admin_users WHERE email = 'email@exemplo.com';
--
-- Para alterar role para suporte:
-- UPDATE admin_users SET role = 'support' WHERE email = 'email@exemplo.com';
-- =====================================================
