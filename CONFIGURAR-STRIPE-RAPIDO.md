# ⚡ Configurar Stripe - Guia Rápido

## 🎯 O que você precisa fazer:

---

## 1️⃣ Obter Credenciais do Stripe

### No Dashboard do Stripe:

1. Acesse: https://dashboard.stripe.com/
2. Vá em **"Developers"** → **"API keys"**
3. Copie:
   - ✅ **Publishable key** (começa com `pk_test_...`)
   - ✅ **Secret key** (começa com `sk_test_...`)

⚠️ **Use as chaves de TESTE primeiro!**

---

## 2️⃣ Criar Produto e Preço

1. No Dashboard, vá em **"Products"** → **"Add product"**
2. Preencha:
   - **Name:** Plano Diamond - Nutra Elite
   - **Price:** R$ 197,00
   - **Billing period:** Monthly (recorrente)
3. Salve e **copie o Price ID** (ex: `price_abc123xyz`)

---

## 3️⃣ Configurar Secrets no Supabase

1. Supabase Dashboard → **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:

```env
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
STRIPE_PRICE_ID=price_abc123xyz
APP_URL=https://seuapp.vercel.app
```

---

## 4️⃣ Deploy das Edge Functions

### Opção A: Via CLI (Recomendado)

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

### Opção B: Via Dashboard

1. Supabase Dashboard → **Edge Functions**
2. **Create a new function**
3. Nome: `create-stripe-checkout`
4. Cole o código de `supabase/functions/create-stripe-checkout/index.ts`
5. **Deploy**
6. Repita para `stripe-webhook`

---

## 5️⃣ Configurar Webhook no Stripe

1. Stripe Dashboard → **Developers** → **Webhooks**
2. **Add endpoint**
3. URL:
   ```
   https://[seu-project-id].supabase.co/functions/v1/stripe-webhook
   ```
4. Selecione eventos:
   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`
5. **Add endpoint**
6. **Copie o "Signing secret"** (começa com `whsec_...`)
7. Adicione no Supabase Secrets:
   ```
   STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
   ```

---

## 6️⃣ Testar

1. Acesse `/upgrade` no seu app
2. Clique em "Assinar Plano Diamond"
3. Use cartão de teste: `4242 4242 4242 4242`
4. CVV: qualquer 3 dígitos
5. Validade: qualquer data futura
6. Confirme pagamento
7. Verifique se redirecionou para `/payment/success`

---

## ✅ Checklist

- [ ] Credenciais do Stripe obtidas
- [ ] Produto criado no Stripe
- [ ] Price ID copiado
- [ ] Secrets configurados no Supabase
- [ ] Edge Functions deployadas
- [ ] Webhook configurado no Stripe
- [ ] Webhook Secret adicionado no Supabase
- [ ] Teste realizado com sucesso

---

## 🆘 Problemas Comuns

### ❌ "Function not found"
**Solução:** Verifique se as functions foram deployadas

### ❌ "Invalid API key"
**Solução:** Verifique se o secret está correto no Supabase

### ❌ "Webhook not receiving events"
**Solução:** 
- Verifique se a URL do webhook está correta
- Verifique se os eventos estão selecionados
- Veja os logs: `supabase functions logs stripe-webhook --tail`

---

## 📞 Próximos Passos

1. **Você:** Configure os secrets no Supabase
2. **Você:** Faça deploy das functions
3. **Você:** Configure o webhook no Stripe
4. **Você:** Teste o fluxo completo
5. **Você:** Me avise se funcionou ou se precisa ajustar!

---

**🚀 Pronto para configurar? Siga os passos acima!**

