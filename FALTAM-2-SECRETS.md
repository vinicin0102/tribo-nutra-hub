# ✅ Secrets Configuradas + O que Falta

## ✅ O que você JÁ tem:

- [x] `STRIPE_SECRET_KEY`
- [x] `STRIPE_PUBLISHABLE_KEY`
- [x] `STRIPE_PRICE_ID`

---

## 📋 O que ainda falta:

### 1️⃣ APP_URL (Precisa adicionar AGORA)

**O que é:** URL do seu app no Vercel (ou onde está hospedado)

**Como pegar:**
- Se já está no Vercel: https://[seu-projeto].vercel.app
- Se não está, me diga qual é a URL do seu app

**Adicionar no Supabase:**
```
APP_URL=https://seuapp.vercel.app
```

**Exemplo:**
```
APP_URL=https://tribo-nutra-hub.vercel.app
```

---

### 2️⃣ STRIPE_WEBHOOK_SECRET (Adicionar DEPOIS)

**O que é:** Secret do webhook do Stripe

**Quando adicionar:** DEPOIS de fazer deploy das Edge Functions e configurar o webhook no Stripe

**Por enquanto:** Pode deixar para depois! ✅

---

## 🚀 Próximos Passos (Nesta Ordem):

### Passo 1: Adicionar APP_URL

1. Me diga qual é a URL do seu app, OU
2. Se não souber, me diga o nome do projeto no Vercel

### Passo 2: Fazer Deploy das Edge Functions

**Via Dashboard (Mais Fácil):**

1. **Supabase Dashboard** → **Edge Functions**
2. **Create a new function**
3. **Nome:** `create-stripe-checkout`
4. Abra o arquivo `supabase/functions/create-stripe-checkout/index.ts`
5. **Copie TODO o código**
6. **Cole no editor** da Edge Function
7. Clique em **Deploy**
8. Repita para `stripe-webhook`:
   - **Create a new function**
   - **Nome:** `stripe-webhook`
   - Abra `supabase/functions/stripe-webhook/index.ts`
   - **Copie TODO o código**
   - **Cole no editor**
   - Clique em **Deploy**

### Passo 3: Configurar Webhook no Stripe

1. **Stripe Dashboard** → **Developers** → **Webhooks**
2. **Add endpoint**
3. **URL:** `https://[seu-project-id].supabase.co/functions/v1/stripe-webhook`
   - (Substitua `[seu-project-id]` pelo ID do seu projeto Supabase)
4. **Selecione eventos:**
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. **Add endpoint**
6. **Copie o Signing secret** (`whsec_...`)
7. **Adicione no Supabase** como `STRIPE_WEBHOOK_SECRET`

### Passo 4: Executar SQL das Tabelas

1. **Supabase Dashboard** → **SQL Editor**
2. Abra `create-stripe-payments-tables-safe.sql`
3. **Copie TODO o conteúdo**
4. **Cole no SQL Editor**
5. Clique em **Run**

---

## ✅ Checklist Atualizado

- [x] STRIPE_SECRET_KEY
- [x] STRIPE_PUBLISHABLE_KEY
- [x] STRIPE_PRICE_ID
- [ ] **APP_URL** ← Adicionar agora!
- [ ] Deploy Edge Functions
- [ ] Configurar Webhook
- [ ] STRIPE_WEBHOOK_SECRET ← Depois do webhook
- [ ] Executar SQL das tabelas

---

## 🎯 O que fazer AGORA:

**Me diga qual é a URL do seu app** (ou o nome do projeto no Vercel) para eu te ajudar a adicionar o APP_URL! 🚀

