# ✅ Verificação Final - Configuração Stripe

## 🎉 Parabéns! Você configurou:

- [x] **STRIPE_SECRET_KEY** ✅
- [x] **STRIPE_PRICE_ID** ✅ (`price_1SbB912NNbV7W7ZNqvSy8YcW`)
- [x] **STRIPE_WEBHOOK_SECRET** ✅ (`whsec_kpAFlvjAs93VGbeUvcb6rZCwvpMxAxgT`)
- [x] **Webhook criado no Stripe** ✅
- [x] **APP_URL** (verificar se está configurado)

---

## 📋 Verificações Finais

### 1️⃣ Edge Functions Deployadas?

**Verifique:**
- Supabase Dashboard → Edge Functions
- Você deve ver:
  - ✅ `create-stripe-checkout` (Status: Active)
  - ✅ `stripe-webhook` (Status: Active)

**Se NÃO estiverem deployadas:**
- Veja o guia: `DEPLOY-EDGE-FUNCTIONS.md`
- Ou faça via Dashboard:
  1. Edge Functions → Create a new function
  2. Nome: `create-stripe-checkout`
  3. Cole o código de `supabase/functions/create-stripe-checkout/index.ts`
  4. Deploy
  5. Repita para `stripe-webhook`

---

### 2️⃣ Tabelas SQL Executadas?

**Verifique:**
- Supabase Dashboard → SQL Editor
- Execute o arquivo: `create-stripe-payments-tables-safe.sql`
- Verifique se as tabelas foram criadas:
  - `subscriptions`
  - `payments`

---

### 3️⃣ APP_URL Configurado?

**Verifique:**
- Supabase Dashboard → Project Settings → Edge Functions → Secrets
- Procure por `APP_URL`
- Deve ser: `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`

**Se não estiver:**
- Adicione como secret:
  - Name: `APP_URL`
  - Value: `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`

---

## 🧪 Testar o Pagamento

### Como Testar:

1. Acesse: `/upgrade` no seu app
2. Clique em "Assinar Plano Diamond"
3. Use cartão de teste:
   - Número: `4242 4242 4242 4242`
   - CVV: qualquer 3 dígitos (ex: `123`)
   - Validade: qualquer data futura (ex: `12/25`)
   - CEP: qualquer CEP válido
4. Complete o pagamento
5. Verifique:
   - Redirecionamento para `/payment/success`
   - Badge Diamond no perfil
   - Assinatura ativa no banco de dados

---

## ✅ Checklist Completo

- [x] Secrets configurados no Supabase
- [ ] Edge Functions deployadas
- [ ] Tabelas SQL executadas
- [ ] APP_URL configurado
- [ ] Teste de pagamento realizado

---

## 🆘 Se algo não funcionar:

### Erro: "Function not found"
- **Solução:** Fazer deploy das Edge Functions

### Erro: "Invalid API key"
- **Solução:** Verificar se os secrets estão corretos

### Erro: "Webhook not receiving events"
- **Solução:** Verificar se a URL do webhook está correta
- Ver logs: `supabase functions logs stripe-webhook --tail`

### Pagamento não ativa assinatura
- **Solução:** Verificar se o webhook está recebendo eventos
- Verificar logs da Edge Function `stripe-webhook`

---

## 🎯 Próximos Passos

1. Verificar se as Edge Functions foram deployadas
2. Executar o SQL das tabelas (se ainda não fez)
3. Verificar se APP_URL está configurado
4. Testar um pagamento de teste

---

**🚀 Me avise se tudo está funcionando ou se encontrou algum problema!**

