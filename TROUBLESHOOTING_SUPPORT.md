# Troubleshooting - Login de Suporte

Se você não consegue fazer login com `suporte@gmail.com` / `suporte123`, siga estes passos:

## 1. Verificar se o usuário existe

Execute no SQL Editor do Supabase:

```sql
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email = 'suporte@gmail.com';
```

**Se não retornar nada:**
- O usuário não foi criado
- Vá em Authentication > Users > Add User
- Crie o usuário com email `suporte@gmail.com` e senha `suporte123`
- **IMPORTANTE:** Marque "Auto Confirm User"

## 2. Verificar se o perfil tem role 'support'

Execute no SQL Editor:

```sql
SELECT 
  p.username,
  p.role,
  u.email,
  u.email_confirmed_at
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';
```

**Se o role não for 'support':**

Execute este SQL para corrigir:

```sql
UPDATE profiles 
SET role = 'support'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');
```

## 3. Verificar se o email está confirmado

O email precisa estar confirmado para fazer login. Se não estiver:

1. No Supabase Dashboard, vá em Authentication > Users
2. Encontre o usuário `suporte@gmail.com`
3. Clique nos três pontos (...) > "Send confirmation email"
4. Ou marque "Auto Confirm User" ao criar o usuário

## 4. Verificar console do navegador

Ao tentar fazer login, abra o Console do navegador (F12) e verifique:

- Se há erros de rede
- Se há mensagens de erro do Supabase
- Se o perfil está sendo carregado corretamente

## 5. Criar usuário completo (Script SQL)

Execute este script completo no SQL Editor:

```sql
-- 1. Verificar se usuário existe
DO $$
DECLARE
  user_id_val UUID;
BEGIN
  -- Buscar ou criar usuário (você precisa criar manualmente no Dashboard primeiro)
  SELECT id INTO user_id_val 
  FROM auth.users 
  WHERE email = 'suporte@gmail.com';
  
  IF user_id_val IS NULL THEN
    RAISE NOTICE 'Usuário não encontrado. Crie manualmente em Authentication > Users';
    RETURN;
  END IF;
  
  -- Atualizar perfil
  UPDATE profiles 
  SET 
    role = 'support',
    username = COALESCE(username, 'suporte'),
    full_name = COALESCE(full_name, 'Equipe de Suporte')
  WHERE user_id = user_id_val;
  
  -- Confirmar email (se não estiver confirmado)
  UPDATE auth.users
  SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
  WHERE id = user_id_val;
  
  RAISE NOTICE 'Perfil atualizado com sucesso!';
END $$;

-- Verificar resultado
SELECT 
  p.username,
  p.role,
  u.email,
  CASE 
    WHEN u.email_confirmed_at IS NOT NULL THEN '✓ Confirmado'
    ELSE '✗ Não confirmado'
  END as status
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';
```

## 6. Problemas comuns

### Erro: "Email ou senha incorretos"
- Verifique se o email está correto: `suporte@gmail.com`
- Verifique se a senha está correta: `suporte123`
- Verifique se o usuário existe em Authentication > Users

### Erro: "Acesso negado"
- O role não está configurado como 'support'
- Execute o SQL de atualização de role (passo 2)

### Erro: "Email not confirmed"
- O email precisa estar confirmado
- No Dashboard, confirme o email do usuário

### Erro: "Perfil não encontrado"
- O trigger pode não ter criado o perfil automaticamente
- Crie manualmente:
  ```sql
  INSERT INTO profiles (user_id, username, role)
  VALUES (
    (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com'),
    'suporte',
    'support'
  );
  ```

## 7. Teste rápido

Após configurar tudo, teste:

1. Acesse: `http://localhost:8080/support/login`
2. Email: `suporte@gmail.com`
3. Senha: `suporte123`
4. Deve redirecionar para `/support/dashboard`

Se ainda não funcionar, verifique o console do navegador para mensagens de erro específicas.

