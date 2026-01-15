# ✅ Adicionar Price ID no Supabase

## 📋 Informações do Seu Price

- **Price ID:** `price_1SbB912NNbV7W7ZNqvSy8YcW` ✅
- **Product ID:** `prod_TYHipvid7YPG24`
- **Valor:** R$ 67,00 (mensal)
- **Modo:** Livemode (produção)

---

## 🚀 Passo a Passo

### 1. Acesse o Supabase Dashboard
👉 https://supabase.com/dashboard

### 2. Vá em Secrets
- Selecione seu projeto
- **Project Settings** → **Edge Functions** → **Secrets**

### 3. Adicione o Secret
1. Clique em **"Add new secret"**
2. **Name:** `STRIPE_PRICE_ID`
3. **Value:** `price_1SbB912NNbV7W7ZNqvSy8YcW`
4. Clique em **Save**

---

## ✅ Checklist de Secrets

Verifique se você tem todos estes secrets:

- [x] **STRIPE_SECRET_KEY** (já adicionado)
- [x] **STRIPE_PRICE_ID** → `price_1SbB912NNbV7W7ZNqvSy8YcW` (adicionar agora)
- [ ] **APP_URL** → URL do seu app (ex: `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`)
- [ ] **STRIPE_WEBHOOK_SECRET** → Adicionar depois de configurar o webhook

---

## 🎯 Próximos Passos

Depois de adicionar o `STRIPE_PRICE_ID`:

1. ✅ Adicionar `APP_URL` (se ainda não tiver)
2. ⏭️ Fazer deploy das Edge Functions
3. ⏭️ Configurar o webhook no Stripe
4. ⏭️ Adicionar `STRIPE_WEBHOOK_SECRET`

---

## 💡 Importante

- O Price ID está em **livemode** (produção)
- O valor é **R$ 67,00 mensal**
- Certifique-se de que o `APP_URL` está correto

