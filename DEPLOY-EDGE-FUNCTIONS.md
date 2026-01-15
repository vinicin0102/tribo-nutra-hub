# 🚀 Deploy das Edge Functions - Passo a Passo

## ✅ O que você já tem:
- [x] STRIPE_SECRET_KEY
- [x] STRIPE_PUBLISHABLE_KEY
- [x] STRIPE_PRICE_ID
- [x] APP_URL

---

## 📋 Deploy das Edge Functions

### Opção 1: Via Dashboard (Mais Fácil) ⭐ RECOMENDADO

#### 1. Deploy `create-stripe-checkout`

1. **Supabase Dashboard** → **Edge Functions** (menu lateral)
2. Clique em **"Create a new function"**
3. **Function name:** `create-stripe-checkout`
4. **Deployment region:** Escolha a mais próxima (ex: `us-east-1`)
5. No editor de código, **delete todo o conteúdo padrão**
6. Abra o arquivo `supabase/functions/create-stripe-checkout/index.ts` no seu editor
7. **Copie TODO o conteúdo** do arquivo
8. **Cole no editor** da Edge Function no Supabase
9. Clique em **"Deploy"** (botão verde no canto superior direito)
10. Aguarde o deploy completar (alguns segundos)

#### 2. Deploy `stripe-webhook`

1. Ainda na página de Edge Functions, clique em **"Create a new function"** novamente
2. **Function name:** `stripe-webhook`
3. **Deployment region:** Escolha a mesma região
4. No editor, **delete todo o conteúdo padrão**
5. Abra o arquivo `supabase/functions/stripe-webhook/index.ts` no seu editor
6. **Copie TODO o conteúdo** do arquivo
7. **Cole no editor** da Edge Function no Supabase
8. Clique em **"Deploy"**
9. Aguarde o deploy completar

---

### Opção 2: Via CLI (Avançado)

Se você tem o Supabase CLI instalado:

```bash
# Instalar CLI (se não tiver)
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

## ✅ Verificação

Após o deploy, você deve ver:

1. **Na lista de Edge Functions:**
   - ✅ `create-stripe-checkout` (Status: Active)
   - ✅ `stripe-webhook` (Status: Active)

2. **URLs das functions:**
   - `create-stripe-checkout`: `https://[project-id].supabase.co/functions/v1/create-stripe-checkout`
   - `stripe-webhook`: `https://[project-id].supabase.co/functions/v1/stripe-webhook`

---

## 🎯 Próximos Passos (Depois do Deploy)

1. ✅ Deploy Edge Functions ← **Você está aqui!**
2. ⏭️ Configurar Webhook no Stripe
3. ⏭️ Adicionar STRIPE_WEBHOOK_SECRET
4. ⏭️ Executar SQL das tabelas

---

## 🆘 Problemas Comuns

### ❌ "Function deployment failed"
- Verifique se copiou TODO o código
- Verifique se não há erros de sintaxe
- Tente fazer deploy novamente

### ❌ "Function not found"
- Verifique se o nome está correto: `create-stripe-checkout` e `stripe-webhook`
- Verifique se o deploy foi concluído

---

## 📝 Checklist

- [ ] Deploy `create-stripe-checkout` concluído
- [ ] Deploy `stripe-webhook` concluído
- [ ] Ambas aparecem como "Active" no dashboard

---

**🚀 Depois de fazer o deploy, me avise e seguimos para configurar o webhook no Stripe!**

