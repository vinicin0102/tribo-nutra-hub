# 🚀 Próximos Passos - Configuração Stripe

## ✅ O que já está feito:

- [x] STRIPE_SECRET_KEY configurado
- [x] STRIPE_PRICE_ID configurado (`price_1SbB912NNbV7W7ZNqvSy8YcW`)
- [x] Tabelas SQL criadas (provavelmente)

---

## 📋 Próximos Passos (em ordem):

### 1️⃣ Verificar/Adicionar APP_URL

**Verifique se já adicionou:**
- Supabase Dashboard → Project Settings → Edge Functions → Secrets
- Procure por `APP_URL`

**Se não tiver, adicione:**
- **Name:** `APP_URL`
- **Value:** `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`
- Salve

---

### 2️⃣ Fazer Deploy das Edge Functions

**Opção A: Via CLI (Recomendado)**

```bash
# No terminal, na pasta do projeto:
supabase functions deploy create-stripe-checkout
supabase functions deploy stripe-webhook
```

**Opção B: Via Dashboard**

1. Supabase Dashboard → Edge Functions
2. Criar função: `create-stripe-checkout`
3. Copiar código de `supabase/functions/create-stripe-checkout/index.ts`
4. Colar e fazer deploy
5. Repetir para `stripe-webhook`

---

### 3️⃣ Configurar Webhook no Stripe

1. Acesse: https://dashboard.stripe.com/webhooks
2. Clique em **"Add endpoint"**
3. **URL:** `https://oglakfbpuosrhhtbyprw.supabase.co/functions/v1/stripe-webhook`
4. **Selecione eventos:**
   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`
5. Clique em **"Add endpoint"**
6. **Copie o Signing Secret** (começa com `whsec_...`)

---

### 4️⃣ Adicionar STRIPE_WEBHOOK_SECRET

1. Supabase Dashboard → Project Settings → Edge Functions → Secrets
2. Clique em **"Add new secret"**
3. **Name:** `STRIPE_WEBHOOK_SECRET`
4. **Value:** Cole o secret que você copiou (`whsec_...`)
5. Salve

---

## ✅ Checklist Final

- [ ] APP_URL configurado
- [ ] Edge Functions deployadas
- [ ] Webhook criado no Stripe
- [ ] STRIPE_WEBHOOK_SECRET adicionado

---

## 🎯 Comece pelo Passo 1

Verifique se o `APP_URL` está configurado, depois faça o deploy das Edge Functions!

