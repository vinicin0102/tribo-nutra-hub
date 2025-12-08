# ✅ Adicionar STRIPE_WEBHOOK_SECRET no Supabase

## 🔐 Seu Webhook Secret

- **Secret:** `whsec_kpAFlvjAs93VGbeUvcb6rZCwvpMxAxgT` ✅

---

## 🚀 Passo a Passo

### 1. Acesse o Supabase Dashboard
👉 https://supabase.com/dashboard

### 2. Vá em Secrets
- Selecione seu projeto
- **Project Settings** → **Edge Functions** → **Secrets**

### 3. Adicione o Secret
1. Clique em **"Add new secret"**
2. **Name:** `STRIPE_WEBHOOK_SECRET`
3. **Value:** `whsec_kpAFlvjAs93VGbeUvcb6rZCwvpMxAxgT`
4. Clique em **Save**

---

## ✅ Checklist Final de Secrets

Verifique se você tem todos estes secrets:

- [x] **STRIPE_SECRET_KEY** ✅
- [x] **STRIPE_PRICE_ID** ✅ (`price_1SbB912NNbV7W7ZNqvSy8YcW`)
- [x] **STRIPE_WEBHOOK_SECRET** → `whsec_kpAFlvjAs93VGbeUvcb6rZCwvpMxAxgT` (adicionar agora)
- [ ] **APP_URL** → Verificar se está configurado

---

## 🎯 Próximos Passos

Depois de adicionar o `STRIPE_WEBHOOK_SECRET`:

1. ✅ Verificar se `APP_URL` está configurado
2. ✅ Fazer deploy das Edge Functions (se ainda não fez)
3. ✅ Testar o pagamento

---

## 💡 Importante

- O webhook secret está correto e começa com `whsec_`
- Após adicionar, o webhook do Stripe poderá se comunicar com sua Edge Function
- Certifique-se de que as Edge Functions foram deployadas

---

**🚀 Adicione o secret no Supabase e me avise quando terminar!**

