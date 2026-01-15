# ✅ Checklist: Configuração Stripe

## 📋 Status da Configuração

Marque conforme você completa cada etapa:

---

## 1️⃣ Secrets no Supabase ✅

- [x] **STRIPE_SECRET_KEY** adicionado
- [ ] **STRIPE_PUBLISHABLE_KEY** adicionado
- [ ] **STRIPE_PRICE_ID** adicionado (ID do produto/preço criado no Stripe)
- [ ] **APP_URL** adicionado (ex: `https://seuapp.vercel.app`)
- [ ] **STRIPE_WEBHOOK_SECRET** adicionado (será adicionado depois de configurar o webhook)

**Onde adicionar:**
- Supabase Dashboard → **Project Settings** → **Edge Functions** → **Secrets**

---

## 2️⃣ Criar Produto no Stripe

- [ ] Acessar Stripe Dashboard → **Products**
- [ ] Criar produto: "Plano Diamond - Nutra Elite"
- [ ] Preço: R$ 197,00
- [ ] Recorrência: Monthly (mensal)
- [ ] **Copiar o Price ID** (ex: `price_abc123xyz`)

---

## 3️⃣ Deploy das Edge Functions

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

- [ ] Supabase Dashboard → **Edge Functions**
- [ ] Criar função: `create-stripe-checkout`
- [ ] Colar código de `supabase/functions/create-stripe-checkout/index.ts`
- [ ] Deploy
- [ ] Criar função: `stripe-webhook`
- [ ] Colar código de `supabase/functions/stripe-webhook/index.ts`
- [ ] Deploy

---

## 4️⃣ Configurar Webhook no Stripe

- [ ] Stripe Dashboard → **Developers** → **Webhooks**
- [ ] **Add endpoint**
- [ ] URL: `https://[seu-project-id].supabase.co/functions/v1/stripe-webhook`
- [ ] Selecionar eventos:
  - [x] `checkout.session.completed`
  - [x] `customer.subscription.created`
  - [x] `customer.subscription.updated`
  - [x] `customer.subscription.deleted`
  - [x] `invoice.payment_succeeded`
  - [x] `invoice.payment_failed`
- [ ] **Add endpoint**
- [ ] **Copiar o "Signing secret"** (começa com `whsec_...`)
- [ ] Adicionar no Supabase Secrets como `STRIPE_WEBHOOK_SECRET`

---

## 5️⃣ Executar SQL das Tabelas

- [ ] Abrir Supabase Dashboard → **SQL Editor**
- [ ] Abrir arquivo `create-stripe-payments-tables-safe.sql`
- [ ] Copiar todo o conteúdo
- [ ] Colar no SQL Editor
- [ ] Executar
- [ ] Verificar mensagem de sucesso

---

## 6️⃣ Testar Pagamento

- [ ] Acessar `/upgrade` no app
- [ ] Clicar em "Assinar Plano Diamond"
- [ ] Usar cartão de teste: `4242 4242 4242 4242`
- [ ] CVV: qualquer 3 dígitos
- [ ] Validade: qualquer data futura
- [ ] Confirmar pagamento
- [ ] Verificar redirecionamento para `/payment/success`
- [ ] Verificar badge Diamond no perfil

---

## 🎯 Próximos Passos Imediatos

Agora que você adicionou a Edge Function key, faça:

1. **Adicionar os outros secrets** (STRIPE_PRICE_ID, APP_URL, etc.)
2. **Criar o produto no Stripe** e copiar o Price ID
3. **Fazer deploy das Edge Functions**
4. **Configurar o webhook no Stripe**

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

## 📞 Precisa de Ajuda?

Se tiver dúvidas em algum passo, me avise qual etapa você está e eu te ajudo! 🚀

