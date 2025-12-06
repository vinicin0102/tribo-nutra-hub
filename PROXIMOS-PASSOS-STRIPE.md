# 🚀 Próximos Passos - Integração Stripe

## ✅ O que você já fez:
- [x] Adicionou `STRIPE_SECRET_KEY` no Supabase
- [x] Adicionou `STRIPE_PUBLISHABLE_KEY` no Supabase

---

## 📋 O que fazer agora:

### 1️⃣ Criar Produto no Stripe

1. Acesse: https://dashboard.stripe.com/products
2. Clique em **"Add product"**
3. Preencha:
   - **Name:** `Plano Diamond - Nutra Elite`
   - **Description:** `Acesso total à plataforma premium`
   - **Pricing model:** `Standard pricing`
   - **Price:** `R$ 197,00` (ou `19700` centavos)
   - **Billing period:** `Monthly` (recorrente)
4. Clique em **"Save product"**
5. **Copie o Price ID** (ex: `price_1AbC2dEfGhIjKlMnOpQrStUv`)

---

### 2️⃣ Adicionar Price ID no Supabase

1. Supabase Dashboard → **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   ```
   STRIPE_PRICE_ID=price_xxxxx
   ```
   (Substitua `price_xxxxx` pelo Price ID real que você copiou)

---

### 3️⃣ Adicionar APP_URL no Supabase

1. Supabase Dashboard → **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   ```
   APP_URL=https://seuapp.vercel.app
   ```
   (Substitua pela URL real do seu app no Vercel)

---

### 4️⃣ Fazer Deploy das Edge Functions

#### Opção A: Via Dashboard (Mais Fácil)

1. **Supabase Dashboard** → **Edge Functions**
2. **Create a new function**
3. **Nome:** `create-stripe-checkout`
4. **Cole o código** de `supabase/functions/create-stripe-checkout/index.ts`
5. Clique em **Deploy**
6. Repita para `stripe-webhook`:
   - **Create a new function**
   - **Nome:** `stripe-webhook`
   - **Cole o código** de `supabase/functions/stripe-webhook/index.ts`
   - Clique em **Deploy**

#### Opção B: Via CLI

```bash
# Instalar Supabase CLI (se não tiver)
npm install -g supabase

# Login
supabase login

# Link ao projeto
supabase link --project-ref [seu-project-id]

# Deploy
supabase functions deploy create-stripe-checkout
supabase functions deploy stripe-webhook
```

---

### 5️⃣ Configurar Webhook no Stripe

**IMPORTANTE:** Faça isso DEPOIS de fazer deploy das Edge Functions!

1. **Stripe Dashboard** → **Developers** → **Webhooks**
2. Clique em **"Add endpoint"**
3. **Endpoint URL:**
   ```
   https://[seu-project-id].supabase.co/functions/v1/stripe-webhook
   ```
   (Substitua `[seu-project-id]` pelo ID do seu projeto Supabase)
4. **Selecione eventos:**
   - [x] `checkout.session.completed`
   - [x] `customer.subscription.created`
   - [x] `customer.subscription.updated`
   - [x] `customer.subscription.deleted`
   - [x] `invoice.payment_succeeded`
   - [x] `invoice.payment_failed`
5. Clique em **"Add endpoint"**
6. **Copie o "Signing secret"** (começa com `whsec_...`)
7. **Adicione no Supabase Secrets:**
   ```
   STRIPE_WEBHOOK_SECRET=whsec_xxxxx
   ```

---

### 6️⃣ Executar SQL das Tabelas

1. **Supabase Dashboard** → **SQL Editor**
2. Abra o arquivo `create-stripe-payments-tables-safe.sql`
3. **Copie todo o conteúdo**
4. **Cole no SQL Editor**
5. Clique em **Run**
6. Verifique a mensagem de sucesso

---

## ✅ Checklist Final

- [x] STRIPE_SECRET_KEY
- [x] STRIPE_PUBLISHABLE_KEY
- [ ] STRIPE_PRICE_ID (criar produto no Stripe)
- [ ] APP_URL
- [ ] Deploy Edge Functions
- [ ] Configurar Webhook
- [ ] STRIPE_WEBHOOK_SECRET
- [ ] Executar SQL das tabelas

---

## 🧪 Testar Pagamento

Depois de completar tudo:

1. Acesse `/upgrade` no seu app
2. Clique em "Assinar Plano Diamond"
3. Use cartão de teste: `4242 4242 4242 4242`
4. CVV: qualquer 3 dígitos
5. Validade: qualquer data futura
6. Confirme pagamento
7. Verifique redirecionamento para `/payment/success`

---

## 🆘 Precisa de Ajuda?

Me avise em qual passo você está e eu te ajudo! 🚀

