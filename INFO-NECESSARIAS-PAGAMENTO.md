# 📋 Informações Necessárias para Integração de Pagamento

## 🎯 Gateway Escolhido: Doppus

---

## 1️⃣ INFORMAÇÕES DA DOPPUS (Você precisa obter)

### A. Credenciais de API
Você precisa de:
- ✅ **API Token** (chave de API)
  - Formato: `sk_test_xxxxxxxxxxxxx` (teste) ou `sk_live_xxxxxxxxxxxxx` (produção)
  - Onde encontrar: Doppus Dashboard → Configurações → API → API Token
  - **IMPORTANTE:** Use `sk_test_` para testes primeiro!

### B. ID do Produto/Assinatura
Você precisa de:
- ✅ **Product ID** (ID do produto criado na Doppus)
  - Formato: `prod_abc123xyz` ou similar
  - Onde encontrar: Doppus Dashboard → Produtos → [Seu Produto] → Copiar ID
  - **Valor do plano:** R$ 197,00/mês

### C. Webhook Secret (Opcional, mas recomendado)
- ✅ **Webhook Secret** (para validar webhooks)
  - Onde encontrar: Doppus Dashboard → Configurações → Webhooks → Secret
  - Usado para segurança dos webhooks

---

## 2️⃣ INFORMAÇÕES DO SEU APP (Você já tem ou precisa configurar)

### A. URL do seu App
- ✅ **URL de Produção**
  - Exemplo: `https://seuapp.vercel.app` ou `https://seudominio.com.br`
  - Onde encontrar: Vercel Dashboard → Settings → Domains

### B. Supabase Project
- ✅ **Supabase Project ID**
  - Formato: `xxxxxxxxxxxxxxxxxxxx`
  - Onde encontrar: Supabase Dashboard → Settings → General → Reference ID
  - Usado para: URL das Edge Functions

- ✅ **Supabase URL**
  - Formato: `https://xxxxxxxxxxxxx.supabase.co`
  - Onde encontrar: Supabase Dashboard → Settings → API → Project URL

- ✅ **Supabase Service Role Key** (já existe, não precisa copiar)
  - Usado internamente pelas Edge Functions

---

## 3️⃣ CHECKLIST DE CONFIGURAÇÃO

### ✅ Passo 1: Criar Conta na Doppus
- [ ] Acessar https://doppus.com/
- [ ] Criar conta
- [ ] Confirmar e-mail
- [ ] Completar cadastro da empresa

### ✅ Passo 2: Criar Produto/Assinatura na Doppus
- [ ] Ir em "Produtos" → "Novo Produto"
- [ ] Preencher:
  - Nome: "Plano Diamond - Nutra Elite"
  - Tipo: Assinatura
  - Valor: R$ 197,00
  - Recorrência: Mensal
- [ ] Salvar e **COPIAR O ID DO PRODUTO** (ex: `prod_abc123`)

### ✅ Passo 3: Obter API Token
- [ ] Ir em "Configurações" → "API"
- [ ] **COPIAR O API TOKEN** (ex: `sk_test_xxxxxxxxxxxxx`)
- [ ] Guardar em local seguro

### ✅ Passo 4: Configurar Secrets no Supabase
- [ ] Acessar Supabase Dashboard
- [ ] Ir em: **Project Settings → Edge Functions → Secrets**
- [ ] Adicionar as seguintes variáveis:

```env
DOPPUS_API_TOKEN=sk_test_xxxxxxxxxxxxx
APP_URL=https://seuapp.vercel.app
```

**IMPORTANTE:**
- Substitua `sk_test_xxxxxxxxxxxxx` pelo seu token real
- Substitua `https://seuapp.vercel.app` pela URL real do seu app
- Use `sk_test_` para testes, `sk_live_` para produção

### ✅ Passo 5: Criar Edge Functions
- [ ] Criar função `create-doppus-checkout`
- [ ] Criar função `doppus-webhook`
- [ ] Fazer deploy das funções

### ✅ Passo 6: Configurar Webhook na Doppus
- [ ] Ir em "Configurações" → "Webhooks"
- [ ] Clicar em "Adicionar Webhook"
- [ ] URL do webhook:
  ```
  https://[seu-project-id].supabase.co/functions/v1/doppus-webhook
  ```
- [ ] Selecionar eventos:
  - ✅ `checkout.completed`
  - ✅ `subscription.created`
  - ✅ `subscription.cancelled`
  - ✅ `payment.succeeded`
  - ✅ `payment.failed`
- [ ] Salvar webhook

---

## 4️⃣ RESUMO: O QUE VOCÊ PRECISA ME ENVIAR

Para eu configurar tudo, preciso que você me forneça:

1. **API Token da Doppus**
   - Exemplo: `sk_test_abc123xyz...`
   - ⚠️ Use token de TESTE primeiro!

2. **URL do seu App**
   - Exemplo: `https://tribo-nutra-hub.vercel.app`
   - Ou seu domínio personalizado

3. **Product ID da Doppus** (opcional, posso ajudar a criar)
   - Exemplo: `prod_abc123xyz`

4. **Supabase Project ID** (opcional, posso encontrar)
   - Exemplo: `abcdefghijklmnop`

---

## 5️⃣ ESTRUTURA DE ARQUIVOS NECESSÁRIOS

Após você me fornecer as informações, vou criar:

```
supabase/
  functions/
    create-doppus-checkout/
      index.ts          ← Criar checkout na Doppus
    doppus-webhook/
      index.ts          ← Receber eventos da Doppus
```

---

## 6️⃣ TESTES

Após configurar, você pode testar com:

### Cartões de Teste:
- **VISA Aprovado:** `4111 1111 1111 1111` | CVV: `123` | Validade: `12/30`
- **Mastercard Aprovado:** `5555 5555 5555 4444` | CVV: `123` | Validade: `12/30`
- **VISA Recusado:** `4000 0000 0000 0002` | CVV: `123` | Validade: `12/30`

### Pix de Teste:
- No ambiente de teste, qualquer código Pix será aprovado automaticamente

---

## 7️⃣ PRÓXIMOS PASSOS

1. **Você:** Criar conta na Doppus e obter as informações acima
2. **Você:** Me enviar as informações (API Token, URL do App)
3. **Eu:** Configurar tudo e fazer o deploy
4. **Você:** Testar o fluxo completo
5. **Você:** Trocar para token de produção quando estiver pronto

---

## ❓ DÚVIDAS?

Se tiver dúvidas sobre:
- Como criar conta na Doppus
- Como obter o API Token
- Como criar o produto
- Como configurar o webhook

Me avise que eu te ajudo passo a passo!

---

**🎯 RESUMO RÁPIDO:**

Você precisa me enviar:
1. ✅ API Token da Doppus (`sk_test_...`)
2. ✅ URL do seu App (`https://...`)
3. ✅ (Opcional) Product ID da Doppus

Com essas informações, eu configuro tudo! 🚀

