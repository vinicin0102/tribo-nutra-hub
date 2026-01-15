# 🔐 Trocar Senha do Admin - Método Dashboard (MAIS FÁCIL)

## ⚡ Método Mais Simples e Rápido

Se o script deu erro de "Invalid API key", use este método que é **muito mais fácil**:

---

## 📋 Passo a Passo

### 1. Acessar o Dashboard do Supabase

1. Acesse: **https://supabase.com/dashboard**
2. Faça login na sua conta
3. Selecione o projeto: **vinicin0102's Project**

### 2. Ir para Authentication → Users

1. No menu lateral esquerdo, clique em **"Authentication"**
2. Clique na aba **"Users"**
3. Você verá uma lista de todos os usuários

### 3. Encontrar o Usuário Admin

1. Na barra de busca, digite: `admin@gmail.com`
2. Ou role a lista até encontrar o usuário com email `admin@gmail.com`
3. Clique no usuário para abrir os detalhes

### 4. Atualizar a Senha

1. Na página de detalhes do usuário, você verá várias opções
2. Procure por um botão **"Update User"** ou **"Reset Password"**
3. Clique nele
4. No campo **"Password"**, digite: `@@Rod2004`
5. Clique em **"Save"** ou **"Update"**

### 5. Confirmar

Você deve ver uma mensagem de sucesso confirmando que a senha foi atualizada.

---

## ✅ Testar o Login

1. Acesse seu app
2. Vá na página de login
3. Use:
   - **Email:** `admin@gmail.com`
   - **Senha:** `@@Rod2004`
4. Deve fazer login com sucesso! ✅

---

## 🆘 Se o Usuário Admin Não Existir

Se você não encontrar `admin@gmail.com` na lista:

### Criar o Usuário Admin

1. No Dashboard: **Authentication** → **Users**
2. Clique no botão **"Add User"** ou **"Create User"**
3. Preencha:
   - **Email:** `admin@gmail.com`
   - **Password:** `@@Rod2004`
   - **Auto Confirm User:** ✅ (marque esta opção para não precisar confirmar email)
4. Clique em **"Create User"**

### Dar Permissões de Admin

Depois de criar, você pode precisar dar permissões de admin:

1. Vá em: **Database** → **SQL Editor**
2. Execute este SQL:

```sql
-- Verificar se o perfil existe
SELECT * FROM public.profiles WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'admin@gmail.com'
);

-- Se não existir, criar perfil
INSERT INTO public.profiles (user_id, username, full_name, role)
SELECT 
  id,
  'admin',
  'Administrador',
  'admin'
FROM auth.users
WHERE email = 'admin@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
```

---

## ✅ Pronto!

Agora você pode fazer login com:
- **Email:** `admin@gmail.com`
- **Senha:** `@@Rod2004`

---

## 💡 Por Que Este Método é Melhor?

- ✅ Não precisa de SERVICE_ROLE_KEY
- ✅ Interface visual, fácil de usar
- ✅ Menos chance de erro
- ✅ Você vê imediatamente se funcionou
- ✅ Pode criar o usuário se não existir

---

## 📸 Screenshots (Referência)

**Onde encontrar:**
- Menu lateral → **Authentication** → **Users**

**O que procurar:**
- Botão **"Update User"** ou **"Reset Password"**
- Campo **"Password"** para definir nova senha

