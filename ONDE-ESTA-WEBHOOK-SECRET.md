# 🔍 Onde Encontrar o STRIPE_WEBHOOK_SECRET

## ⚠️ IMPORTANTE

O `STRIPE_WEBHOOK_SECRET` **NÃO existe ainda**! Você precisa **CRIAR o webhook primeiro** no Stripe Dashboard.

---

## 📋 Passo a Passo Completo

### 1️⃣ Criar o Webhook no Stripe

1. **Acesse:** https://dashboard.stripe.com/webhooks
2. Clique em **"Add endpoint"** ou **"Create endpoint"**
3. **Endpoint URL:**
   ```
   https://oglakfbpuosrhhtbyprw.supabase.co/functions/v1/stripe-webhook
   ```
4. **Selecione os eventos:**
   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`
5. Clique em **"Add endpoint"** ou **"Create endpoint"**

---

### 2️⃣ ONDE Encontrar o Secret (DEPOIS de criar o webhook)

**Após criar o webhook:**

1. Na lista de webhooks, você verá o webhook que acabou de criar
2. **Clique no webhook** (clique no nome/ID do webhook)
3. Na página de detalhes do webhook, procure por:
   - **"Signing secret"** ou
   - **"Webhook signing secret"** ou
   - **"Secret"**
4. Clique em **"Reveal"** ou **"Click to reveal"** para mostrar o secret
5. **Copie o secret** (começa com `whsec_...`)
   - Exemplo: `whsec_1AbC2dEfGhIjKlMnOpQrStUvWxYz`

---

## 📍 Localização Visual

```
Stripe Dashboard
  └─ Developers (menu lateral)
      └─ Webhooks
          └─ [Lista de webhooks]
              └─ [Clique no seu webhook]
                  └─ Seção "Signing secret"
                      └─ [Clique em "Reveal"]
                          └─ Copie o secret (whsec_...)
```

---

## ⚠️ IMPORTANTE

- O secret **só aparece DEPOIS** de criar o webhook
- Você só vê o secret **uma vez** quando cria o webhook
- Se você já criou o webhook antes, o secret ainda está lá, só precisa revelar

---

## 🆘 Se não conseguir ver o Secret

### Opção 1: Verificar se o webhook foi criado
- Volte para a lista de webhooks
- Certifique-se de que o webhook está lá
- Clique nele para ver os detalhes

### Opção 2: Criar um novo webhook
- Se você não conseguir encontrar o secret do webhook antigo
- Crie um novo webhook
- O secret aparecerá após criar

### Opção 3: Verificar na seção "Signing secret"
- Na página de detalhes do webhook
- Procure por uma seção chamada "Signing secret"
- Pode estar no topo da página ou em uma aba

---

## ✅ Depois de Copiar o Secret

1. Vá para: **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**
2. Clique em **"Add new secret"**
3. **Name:** `STRIPE_WEBHOOK_SECRET`
4. **Value:** Cole o secret que você copiou (`whsec_...`)
5. Clique em **Save**

---

## 💡 Dica

Se você já criou o webhook antes mas não copiou o secret:
- Não tem problema! Você pode ver o secret novamente
- Basta clicar no webhook e procurar por "Signing secret"
- Ou criar um novo webhook se preferir

