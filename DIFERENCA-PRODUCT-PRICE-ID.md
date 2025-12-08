# 🔑 Diferença entre Product ID e Price ID no Stripe

## ⚠️ IMPORTANTE

O que você forneceu: `prod_TYHipvid7YPG24` é um **Product ID** (começa com `prod_`)

Para o checkout funcionar, precisamos do **Price ID** (começa com `price_`)

---

## 📋 Como Pegar o Price ID

### Opção 1: No Stripe Dashboard

1. Acesse: https://dashboard.stripe.com/products
2. Clique no produto que você criou
3. Na seção **"Pricing"**, você verá o **Price ID**
   - Exemplo: `price_1AbC2dEfGhIjKlMnOpQrStUvWxYz`
4. **Copie esse Price ID** (começa com `price_`)

### Opção 2: Se você tem o Product ID

1. Acesse: https://dashboard.stripe.com/products
2. Clique no produto com ID `prod_TYHipvid7YPG24`
3. Veja a seção **"Pricing"**
4. O Price ID estará lá

---

## ✅ O que você precisa:

- **Product ID:** `prod_TYHipvid7YPG24` ✅ (você já tem)
- **Price ID:** `price_...` ❌ (precisa pegar)

---

## 🎯 Próximos Passos

1. Pegue o **Price ID** (começa com `price_`)
2. Adicione no Supabase como `STRIPE_PRICE_ID`
3. O Product ID não precisa ser adicionado (só o Price ID)

---

## 💡 Dica

Se você criou o produto recentemente, o Price ID geralmente está na mesma página do produto, na seção de preços.

