-- =====================================================
-- ATUALIZAR ADMIN PRINCIPAL
-- Remover admin@gmail.com e manter auxiliodp1@gmail.com
-- =====================================================

-- 1. Remover admin@gmail.com da tabela admin_users
DELETE FROM admin_users WHERE email = 'admin@gmail.com';

-- 2. Atualizar role de admin@gmail.com para 'user' na profiles
UPDATE profiles SET role = 'user' WHERE email = 'admin@gmail.com';

-- 3. Garantir que auxiliodp1@gmail.com é admin
INSERT INTO admin_users (email, role, name) VALUES ('auxiliodp1@gmail.com', 'admin', 'Admin Supremo')
ON CONFLICT (email) DO UPDATE SET role = 'admin', name = 'Admin Supremo', updated_at = NOW();

UPDATE profiles SET role = 'admin' WHERE email = 'auxiliodp1@gmail.com';

-- 4. Atualizar função is_admin_user
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
  
  -- Outros admins (sem admin@gmail.com)
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

-- Verificação
SELECT '✅ ADMIN ATUALIZADO!' as status;
SELECT * FROM admin_users;
