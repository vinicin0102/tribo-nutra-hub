# ⚡ Como Pegar o Webhook Secret - Guia Rápido

## 🎯 Você já tem o Price ID? Ótimo! Agora só falta o webhook.

---

## 📝 Passo a Passo (5 minutos)

### 1. Acesse o Stripe Dashboard
👉 https://dashboard.stripe.com/webhooks

### 2. Clique em "Add endpoint" ou "Create endpoint"

### 3. Cole esta URL (substitua pelo seu Project ID):
```
https://oglakfbpuosrhhtbyprw.supabase.co/functions/v1/stripe-webhook
```

**⚠️ IMPORTANTE:** Se seu Project ID for diferente, pegue em:
- Supabase Dashboard → Settings → General → Reference ID
- Ou veja no arquivo `supabase/config.toml`

### 4. Selecione estes eventos:
- ✅ `checkout.session.completed`
- ✅ `customer.subscription.created`
- ✅ `customer.subscription.updated`
- ✅ `customer.subscription.deleted`
- ✅ `invoice.payment_succeeded`
- ✅ `invoice.payment_failed`

### 5. Clique em "Add endpoint"

### 6. Copie o Signing Secret
- Após criar, clique no webhook
- Procure por "Signing secret"
- Clique em "Reveal" ou "Click to reveal"
- **Copie o secret** (começa com `whsec_...`)

### 7. Adicione no Supabase
- Supabase Dashboard → Project Settings → Edge Functions → Secrets
- Clique em "Add new secret"
- **Name:** `STRIPE_WEBHOOK_SECRET`
- **Value:** Cole o secret que você copiou
- Salve

---

## ✅ Pronto!

Agora você tem:
- ✅ Price ID do produto
- ✅ Webhook configurado
- ✅ Webhook Secret no Supabase

---

## 🆘 Se não conseguir ver o Signing Secret:

1. Certifique-se de que o webhook foi criado
2. Clique no webhook na lista
3. Procure na seção "Signing secret"
4. Se não aparecer, tente criar um novo webhook

---

## 💡 Dica

Se você já fez o deploy das Edge Functions, o webhook deve funcionar imediatamente após configurar!

