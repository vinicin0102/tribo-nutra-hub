# 🔐 Como Trocar a Senha do Admin

A senha do admin (`admin@gmail.com`) foi configurada para: **`@@Rod2004`**

---

## ✅ Método 1: Usando o Script Node.js (Recomendado)

### Passo 1: Instalar dependências (se ainda não tiver)

```bash
npm install @supabase/supabase-js
```

### Passo 2: Obter a SERVICE_ROLE_KEY

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em: **Settings** → **API**
4. Copie a **`service_role` key** (⚠️ NÃO use a `anon` key!)

### Passo 3: Executar o script

**Opção A: Com variável de ambiente (mais seguro)**

```bash
SUPABASE_SERVICE_ROLE_KEY=sua_service_role_key_aqui node trocar-senha-admin.mjs
```

**Opção B: O script vai pedir a key**

```bash
node trocar-senha-admin.mjs
```

O script vai:
- ✅ Buscar o usuário `admin@gmail.com`
- ✅ Atualizar a senha para `@@Rod2004`
- ✅ Confirmar o sucesso

---

## ✅ Método 2: Via Dashboard do Supabase

### Passo 1: Acessar o Dashboard

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em: **Authentication** → **Users**

### Passo 2: Encontrar o usuário admin

1. Procure por `admin@gmail.com` na lista
2. Clique no usuário para abrir os detalhes

### Passo 3: Resetar a senha

1. Clique no botão **"Reset Password"** ou **"Send Password Reset Email"**
2. Ou use o botão **"Update User"** e defina uma nova senha manualmente

**⚠️ Nota:** Se usar "Send Password Reset Email", o admin receberá um email para resetar. Para definir diretamente, use a API Admin (Método 1).

---

## ✅ Método 3: Via SQL (Não Recomendado)

**⚠️ AVISO:** Senhas no Supabase são criptografadas. Não é possível fazer UPDATE direto na tabela `auth.users`.

Use o Método 1 ou 2 acima.

---

## 🔍 Verificar se Funcionou

1. Acesse o app
2. Vá em **Login**
3. Use:
   - **Email:** `admin@gmail.com`
   - **Senha:** `@@Rod2004`
4. Deve fazer login com sucesso

---

## 🆘 Problemas Comuns

### Erro: "SERVICE_ROLE_KEY é obrigatória"

**Solução:** 
- Certifique-se de copiar a **`service_role` key** (não a `anon` key)
- Ela está em: Dashboard → Settings → API → service_role

### Erro: "Usuário não encontrado"

**Solução:**
- O usuário `admin@gmail.com` precisa existir primeiro
- Crie via Dashboard: Authentication → Users → Add User
- Ou crie via script de signup

### Erro: "Erro ao atualizar senha"

**Solução:**
- Verifique se a SERVICE_ROLE_KEY está correta
- Verifique se a URL do Supabase está correta
- Verifique os logs do script para mais detalhes

---

## 📋 Checklist

- [ ] SERVICE_ROLE_KEY obtida do Dashboard
- [ ] Script executado com sucesso
- [ ] Teste de login realizado
- [ ] Senha funcionando corretamente

---

## 🔒 Segurança

- ⚠️ **NUNCA** commite a SERVICE_ROLE_KEY no git
- ⚠️ **NUNCA** compartilhe a SERVICE_ROLE_KEY publicamente
- ✅ Use variáveis de ambiente para a SERVICE_ROLE_KEY
- ✅ A SERVICE_ROLE_KEY tem acesso total ao banco - trate com cuidado

