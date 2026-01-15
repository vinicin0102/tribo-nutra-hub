# Configuração do Usuário de Suporte

Este guia explica como criar o usuário de suporte com as credenciais:
- **Email:** suporte@gmail.com
- **Senha:** suporte123

## Método 1: Via Supabase Dashboard (Recomendado)

### Passo 1: Criar o usuário de autenticação

1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Selecione seu projeto
3. Vá em **Authentication** > **Users**
4. Clique em **Add User** > **Create new user**
5. Preencha:
   - **Email:** `suporte@gmail.com`
   - **Password:** `suporte123`
   - Marque **Auto Confirm User**
6. Clique em **Create User**

### Passo 2: Atualizar o perfil com role de suporte

1. No Supabase Dashboard, vá em **SQL Editor**
2. Execute o seguinte SQL:

```sql
-- Atualizar perfil para role de suporte
UPDATE profiles 
SET 
  role = 'support',
  username = 'suporte',
  full_name = 'Equipe de Suporte'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');

-- Verificar se foi atualizado corretamente
SELECT 
  p.user_id,
  p.username,
  p.full_name,
  p.role,
  u.email
FROM profiles p
JOIN auth.users u ON p.user_id = u.id
WHERE u.email = 'suporte@gmail.com';
```

3. Você deve ver o resultado com `role = 'support'`

## Método 2: Via Script Node.js (Avançado)

### Pré-requisitos

Você precisa da **SERVICE_ROLE_KEY** do Supabase:
1. No Supabase Dashboard, vá em **Settings** > **API**
2. Copie a **service_role key** (não a anon key!)

### Executar o script

1. Adicione a SERVICE_ROLE_KEY no arquivo `.env`:
   ```
   SUPABASE_SERVICE_ROLE_KEY=sua_service_role_key_aqui
   ```

2. Execute o script:
   ```bash
   node create-support-user.mjs
   ```

   Ou com variável de ambiente:
   ```bash
   SUPABASE_SERVICE_ROLE_KEY=sua_key node create-support-user.mjs
   ```

## Método 3: Via SQL Editor (Mais Rápido)

1. No Supabase Dashboard, vá em **SQL Editor**
2. Execute o arquivo `create-support-user.sql` (copie e cole o conteúdo)

**Nota:** Você ainda precisará criar o usuário manualmente no Authentication antes de executar o SQL.

## Verificação

Após criar o usuário, você pode testar:

1. Acesse: `http://localhost:8080/support/login`
2. Faça login com:
   - Email: `suporte@gmail.com`
   - Senha: `suporte123`
3. Você deve ser redirecionado para `/support/dashboard`

## Troubleshooting

### Erro: "Acesso negado"
- Verifique se o `role` foi atualizado corretamente na tabela `profiles`
- Execute o SQL de verificação para confirmar

### Erro: "Usuário não encontrado"
- Verifique se o usuário foi criado em Authentication > Users
- Confirme que o email está correto: `suporte@gmail.com`

### O perfil não foi criado automaticamente
- O trigger `on_auth_user_created` deve criar o perfil automaticamente
- Se não funcionar, crie manualmente:
  ```sql
  INSERT INTO profiles (user_id, username, role)
  VALUES (
    (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com'),
    'suporte',
    'support'
  );
  ```

## Segurança

⚠️ **IMPORTANTE:** 
- A SERVICE_ROLE_KEY tem acesso total ao banco de dados
- Nunca compartilhe ou commite essa chave no Git
- Use apenas em scripts locais ou em ambientes seguros

