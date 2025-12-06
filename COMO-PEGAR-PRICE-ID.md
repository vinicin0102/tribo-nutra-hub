# 🔍 Como Pegar o Price ID do Stripe

## ⚠️ Diferença Importante

- **Product ID:** `prod_xxxxx` → Identifica o produto
- **Price ID:** `price_xxxxx` → Identifica o preço/assinatura (é isso que precisamos!)

---

## 📋 Como Encontrar o Price ID

### Opção 1: No Dashboard do Stripe

1. Acesse: https://dashboard.stripe.com/products
2. Clique no produto que você criou (ou o que tem ID `prod_TYHipvid7YPG24`)
3. Na página do produto, você verá a seção **"Pricing"**
4. Procure por **"Price ID"** ou **"API ID"**
5. O Price ID começa com `price_` (ex: `price_1AbC2dEfGhIjKlMnOpQrStUv`)
6. **Copie esse Price ID**

### Opção 2: Se o Produto Não Tem Preço

Se você criou o produto mas não configurou o preço ainda:

1. No produto, clique em **"Add another price"** ou **"Edit pricing"**
2. Configure:
   - **Price:** R$ 197,00 (ou 19700 centavos)
   - **Billing period:** Monthly (recorrente)
3. Salve
4. O Price ID será gerado automaticamente
5. **Copie o Price ID** (começa com `price_`)

### Opção 3: Via API (Avançado)

Se você tem acesso à API, pode listar os preços:

```bash
curl https://api.stripe.com/v1/prices \
  -u sk_live_xxxxx: \
  -d product=prod_TYHipvid7YPG24
```

---

## ✅ Depois de Pegar o Price ID

1. **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   ```
   STRIPE_PRICE_ID=price_xxxxx
   ```
   (Substitua `price_xxxxx` pelo Price ID real)

---

## 🎯 Resumo

| O que você tem | O que precisa |
|----------------|---------------|
| `prod_TYHipvid7YPG24` | `price_xxxxx` |

**Ação:** Acesse o produto no Stripe Dashboard e copie o **Price ID** (não o Product ID)!

---

## 🆘 Se Não Encontrar o Price ID

1. Verifique se o produto tem um preço configurado
2. Se não tiver, adicione um preço ao produto
3. O Price ID será gerado automaticamente
4. Copie o Price ID que começa com `price_`

---

**💡 Dica:** O Price ID é o que identifica a assinatura recorrente. Sem ele, não conseguimos criar checkouts!

