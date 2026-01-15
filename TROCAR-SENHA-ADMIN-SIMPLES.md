# 🔐 Trocar Senha do Admin - Guia Rápido

## 📋 Informações

- **Email:** `admin@gmail.com`
- **Nova Senha:** `@@Rod2004`

---

## ✅ Método Mais Rápido: Via Dashboard

### Passo 1: Acessar Supabase Dashboard

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em: **Authentication** → **Users**

### Passo 2: Encontrar e Editar o Admin

1. Procure por `admin@gmail.com` na lista de usuários
2. Clique no usuário para abrir os detalhes
3. Clique em **"Update User"** ou **"Reset Password"**
4. Defina a nova senha: `@@Rod2004`
5. Salve

### Passo 3: Testar

1. Acesse o app
2. Faça login com:
   - Email: `admin@gmail.com`
   - Senha: `@@Rod2004`

---

## ✅ Método Alternativo: Script Node.js

Se preferir usar o script automatizado:

### Passo 1: Obter SERVICE_ROLE_KEY

1. No Dashboard do Supabase: **Settings** → **API**
2. Copie a **`service_role` key** (⚠️ não a `anon` key!)

### Passo 2: Executar

```bash
SUPABASE_SERVICE_ROLE_KEY=sua_key_aqui node trocar-senha-admin.mjs
```

Ou o script vai pedir a key:

```bash
node trocar-senha-admin.mjs
```

---

## 🆘 Se o Usuário Admin Não Existir

Crie o usuário primeiro:

1. Dashboard → **Authentication** → **Users** → **Add User**
2. Email: `admin@gmail.com`
3. Password: `@@Rod2004`
4. Confirme o email (ou desative confirmação em Settings)

---

## ✅ Pronto!

Agora você pode fazer login com:
- **Email:** `admin@gmail.com`
- **Senha:** `@@Rod2004`

