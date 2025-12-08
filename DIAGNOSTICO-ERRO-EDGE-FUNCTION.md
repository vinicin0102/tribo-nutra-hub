# 🔍 Diagnóstico: Erro "Edge Function returned a non-2xx status code"

## ⚠️ O que significa esse erro?

A Edge Function `create-stripe-checkout` está retornando um erro (status 400 ou 500). Isso pode ter várias causas.

---

## 🔍 Como Diagnosticar

### 1️⃣ Verificar Logs da Edge Function

**No Supabase Dashboard:**
1. Vá em **Edge Functions**
2. Clique em `create-stripe-checkout`
3. Vá na aba **Logs**
4. Veja os erros mais recentes

**Ou via CLI:**
```bash
supabase functions logs create-stripe-checkout --tail
```

---

### 2️⃣ Verificar Secrets Configurados

**No Supabase Dashboard:**
- **Project Settings** → **Edge Functions** → **Secrets**

**Verifique se TODOS estes secrets existem:**
- [ ] `STRIPE_SECRET_KEY`
- [ ] `STRIPE_PRICE_ID`
- [ ] `APP_URL`
- [ ] `SUPABASE_URL` (geralmente já existe)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` (geralmente já existe)

**Se algum estiver faltando:**
- Adicione o secret faltante
- Faça o redeploy da Edge Function

---

### 3️⃣ Verificar se Edge Function foi Deployada

**No Supabase Dashboard:**
- **Edge Functions** → Verifique se `create-stripe-checkout` aparece
- Status deve ser **"Active"**

**Se não estiver deployada:**
- Veja: `DEPLOY-EDGE-FUNCTIONS.md`
- Faça o deploy da função

---

### 4️⃣ Verificar Valores dos Secrets

**STRIPE_SECRET_KEY:**
- Deve começar com `sk_` (live) ou `sk_test_` (test)
- Verifique se está correto no Stripe Dashboard

**STRIPE_PRICE_ID:**
- Deve ser: `price_1SbB912NNbV7W7ZNqvSy8YcW`
- Verifique se o preço está ativo no Stripe

**APP_URL:**
- Deve ser: `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`
- Verifique se a URL está correta (sem barra no final)

---

## 🛠️ Soluções Comuns

### Erro: "Variáveis de ambiente faltando"
**Solução:**
- Adicione os secrets faltantes no Supabase
- Faça redeploy da Edge Function

### Erro: "Invalid API key"
**Solução:**
- Verifique se `STRIPE_SECRET_KEY` está correto
- Certifique-se de que está usando a chave do modo correto (live/test)

### Erro: "Price not found"
**Solução:**
- Verifique se `STRIPE_PRICE_ID` está correto
- Verifique se o preço está ativo no Stripe Dashboard

### Erro: "User not authenticated"
**Solução:**
- Verifique se o usuário está logado
- Verifique se o token de autenticação está sendo enviado

---

## 📋 Checklist de Verificação

- [ ] Edge Function `create-stripe-checkout` está deployada
- [ ] Todos os secrets estão configurados
- [ ] `STRIPE_SECRET_KEY` está correto
- [ ] `STRIPE_PRICE_ID` está correto
- [ ] `APP_URL` está correto
- [ ] Verificou os logs da Edge Function
- [ ] Usuário está autenticado

---

## 🎯 Próximos Passos

1. **Verifique os logs** da Edge Function (mais importante!)
2. **Confirme todos os secrets** estão configurados
3. **Faça redeploy** da Edge Function se necessário
4. **Teste novamente** o pagamento

---

## 💡 Dica

Os logs da Edge Function mostram exatamente qual é o erro. Sempre comece verificando os logs!

---

**🔍 Verifique os logs primeiro e me diga qual erro aparece lá!**

