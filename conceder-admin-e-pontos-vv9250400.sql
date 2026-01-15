-- Conceder 70.000 pontos e acesso admin/suporte para vv9250400@gmail.com
-- Este script atualiza o perfil do usuário com pontos e role admin

DO $$
DECLARE
  v_user_id UUID;
  v_profile_exists BOOLEAN;
BEGIN
  -- Buscar user_id pelo email na tabela auth.users
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'vv9250400@gmail.com'
  LIMIT 1;

  -- Verificar se o usuário existe
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Usuário com email vv9250400@gmail.com não encontrado na tabela auth.users';
  END IF;

  -- Verificar se o perfil existe
  SELECT EXISTS(
    SELECT 1 FROM profiles WHERE user_id = v_user_id
  ) INTO v_profile_exists;

  -- Se o perfil não existe, criar
  IF NOT v_profile_exists THEN
    INSERT INTO profiles (
      user_id,
      username,
      email,
      points,
      role,
      subscription_plan,
      created_at,
      updated_at
    ) VALUES (
      v_user_id,
      COALESCE(
        (SELECT raw_user_meta_data->>'username' FROM auth.users WHERE id = v_user_id),
        'vv9250400'
      ),
      'vv9250400@gmail.com',
      70000,
      'admin',
      'diamond',
      NOW(),
      NOW()
    );
    
    RAISE NOTICE 'Perfil criado para vv9250400@gmail.com com 70.000 pontos e role admin';
  ELSE
    -- Atualizar perfil existente
    UPDATE profiles
    SET 
      points = 70000,
      role = 'admin',
      subscription_plan = 'diamond',
      email = 'vv9250400@gmail.com',
      updated_at = NOW()
    WHERE user_id = v_user_id;
    
    RAISE NOTICE 'Perfil atualizado para vv9250400@gmail.com: 70.000 pontos e role admin';
  END IF;

  -- Verificar resultado
  RAISE NOTICE '✅ Concluído!';
  RAISE NOTICE 'User ID: %', v_user_id;
  RAISE NOTICE 'Pontos: 70.000';
  RAISE NOTICE 'Role: admin (acesso a admin e suporte)';
  RAISE NOTICE 'Plano: diamond';

END $$;

-- Verificar o resultado
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.points,
  p.role,
  p.subscription_plan,
  u.email as auth_email
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';

