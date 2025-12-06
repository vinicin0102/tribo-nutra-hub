# 🔗 Configurar Webhook no Stripe - Passo a Passo

## ⚠️ IMPORTANTE

Você **NÃO precisa ter o webhook agora**! Você vai **CRIAR** o webhook no Stripe Dashboard **DEPOIS** de fazer o deploy das Edge Functions.

---

## 📋 Ordem Correta:

1. ✅ Fazer deploy das Edge Functions (você está aqui)
2. ⏭️ **CRIAR** o webhook no Stripe Dashboard
3. ⏭️ Copiar o Signing Secret
4. ⏭️ Adicionar no Supabase como `STRIPE_WEBHOOK_SECRET`

---

## 🚀 Passo a Passo (DEPOIS do Deploy)

### 1. Fazer Deploy das Edge Functions Primeiro

**IMPORTANTE:** Você precisa fazer o deploy das Edge Functions ANTES de configurar o webhook!

- [ ] Deploy `create-stripe-checkout`
- [ ] Deploy `stripe-webhook`

### 2. Pegar o Project ID do Supabase

1. **Supabase Dashboard** → **Project Settings** → **General**
2. Copie o **Project ID** (ex: `abcdefghijklmnop`)

### 3. Criar o Webhook no Stripe

1. Acesse: https://dashboard.stripe.com/webhooks
2. Clique em **"Add endpoint"** ou **"Create endpoint"**
3. **Endpoint URL:**
   ```
   https://[seu-project-id].supabase.co/functions/v1/stripe-webhook
   ```
   (Substitua `[seu-project-id]` pelo Project ID que você copiou)
   
   **Exemplo:**
   ```
   https://abcdefghijklmnop.supabase.co/functions/v1/stripe-webhook
   ```

4. **Selecione eventos para escutar:**
   - [x] `checkout.session.completed`
   - [x] `customer.subscription.created`
   - [x] `customer.subscription.updated`
   - [x] `customer.subscription.deleted`
   - [x] `invoice.payment_succeeded`
   - [x] `invoice.payment_failed`

5. Clique em **"Add endpoint"** ou **"Create endpoint"**

6. **Copie o "Signing secret"** (começa com `whsec_...`)
   - Você verá algo como: `whsec_1AbC2dEfGhIjKlMnOpQrStUvWxYz`

### 4. Adicionar Signing Secret no Supabase

1. **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**
2. Clique em **"Add new secret"**
3. **Name:** `STRIPE_WEBHOOK_SECRET`
4. **Value:** Cole o Signing secret que você copiou (ex: `whsec_...`)
5. Clique em **Save**

---

## ✅ Checklist Completo

- [ ] Fazer deploy das Edge Functions
- [ ] Pegar Project ID do Supabase
- [ ] Criar webhook no Stripe Dashboard
- [ ] Copiar Signing Secret
- [ ] Adicionar `STRIPE_WEBHOOK_SECRET` no Supabase

---

## 🎯 O que fazer AGORA:

1. **Fazer deploy das Edge Functions** primeiro
2. **Depois** configurar o webhook no Stripe
3. **Depois** adicionar o `STRIPE_WEBHOOK_SECRET`

---

## 💡 Por que precisa fazer nessa ordem?

- O webhook precisa da URL da Edge Function `stripe-webhook`
- A URL só existe DEPOIS de fazer o deploy
- Por isso você cria o webhook DEPOIS do deploy

---

## 🆘 Se você já tentou criar o webhook antes:

- Não tem problema! Você pode criar um novo
- Ou editar o existente e atualizar a URL
- O importante é ter a URL correta da Edge Function

---

**🚀 Primeiro faça o deploy das Edge Functions, depois me avise e eu te ajudo a configurar o webhook!**

