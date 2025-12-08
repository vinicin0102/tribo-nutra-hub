# 🔐 Como Pegar o Webhook Secret do Stripe

## ⚠️ IMPORTANTE: Ordem Correta

Você precisa fazer o deploy das Edge Functions **ANTES** de criar o webhook!

---

## 📋 Passo a Passo Completo

### 1️⃣ Verificar se as Edge Functions foram deployadas

**Você já fez o deploy?**
- [ ] `create-stripe-checkout` 
- [ ] `stripe-webhook`

**Se NÃO fez, faça primeiro:**
```bash
# No terminal, na pasta do projeto:
supabase functions deploy create-stripe-checkout
supabase functions deploy stripe-webhook
```

---

### 2️⃣ Pegar o Project ID do Supabase

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **General**
4. Copie o **Reference ID** (ex: `oglakfbpuosrhhtbyprw`)

**OU** veja no arquivo `supabase/config.toml`:
```toml
project_id = "oglakfbpuosrhhtbyprw"
```

---

### 3️⃣ Criar o Webhook no Stripe Dashboard

1. **Acesse:** https://dashboard.stripe.com/webhooks
2. Clique em **"Add endpoint"** ou **"Create endpoint"**

3. **Endpoint URL:**
   ```
   https://[seu-project-id].supabase.co/functions/v1/stripe-webhook
   ```
   
   **Exemplo (substitua pelo seu Project ID):**
   ```
   https://oglakfbpuosrhhtbyprw.supabase.co/functions/v1/stripe-webhook
   ```

4. **Selecione os eventos:**
   - [x] `checkout.session.completed`
   - [x] `customer.subscription.created`
   - [x] `customer.subscription.updated`
   - [x] `customer.subscription.deleted`
   - [x] `invoice.payment_succeeded`
   - [x] `invoice.payment_failed`

5. Clique em **"Add endpoint"** ou **"Create endpoint"**

---

### 4️⃣ Copiar o Signing Secret (Webhook Secret)

**Após criar o webhook:**

1. Na lista de webhooks, clique no webhook que você acabou de criar
2. Na seção **"Signing secret"**, clique em **"Reveal"** ou **"Click to reveal"**
3. **Copie o secret** (começa com `whsec_...`)
   - Exemplo: `whsec_1AbC2dEfGhIjKlMnOpQrStUvWxYz`

⚠️ **IMPORTANTE:** Copie e guarde esse secret! Você só vê ele uma vez.

---

### 5️⃣ Adicionar o Secret no Supabase

1. **Supabase Dashboard** → Seu Projeto
2. Vá em **Project Settings** → **Edge Functions** → **Secrets**
3. Clique em **"Add new secret"**
4. Preencha:
   - **Name:** `STRIPE_WEBHOOK_SECRET`
   - **Value:** Cole o secret que você copiou (ex: `whsec_...`)
5. Clique em **Save**

---

## ✅ Checklist Final

- [ ] Edge Functions deployadas
- [ ] Project ID do Supabase copiado
- [ ] Webhook criado no Stripe com a URL correta
- [ ] Eventos selecionados no webhook
- [ ] Signing Secret copiado
- [ ] `STRIPE_WEBHOOK_SECRET` adicionado no Supabase

---

## 🆘 Problemas Comuns

### "Não consigo ver o Signing Secret"
- Certifique-se de que o webhook foi criado com sucesso
- Clique no webhook na lista para ver os detalhes
- Procure por "Signing secret" ou "Webhook signing secret"

### "A URL do webhook não funciona"
- Verifique se as Edge Functions foram deployadas
- Confirme que o Project ID está correto
- Teste a URL no navegador (deve retornar um erro, mas não 404)

### "Já criei o webhook antes"
- Não tem problema! Você pode:
  - Editar o webhook existente e atualizar a URL
  - Ou criar um novo webhook
  - O importante é ter a URL correta e copiar o secret

---

## 🎯 Próximos Passos

Depois de configurar o webhook:
1. Teste fazendo um pagamento de teste
2. Verifique os logs da Edge Function no Supabase
3. Confirme que os eventos estão sendo recebidos

---

**💡 Dica:** Se você já tem o Price ID do produto, você está quase lá! Só falta configurar o webhook para receber as notificações de pagamento.

