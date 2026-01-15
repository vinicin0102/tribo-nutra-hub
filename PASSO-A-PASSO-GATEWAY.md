# 💳 Passo a Passo: Conectar Gateway de Pagamento

## 🎯 Escolha o Gateway

Você mencionou interesse em **Peper**. Vamos configurar!

---

## 📋 PASSO 1: Criar Conta no Gateway

### Para Peper:
1. Acesse o site da Peper
2. Crie sua conta
3. Complete o cadastro da empresa
4. Aguarde aprovação (se necessário)

### Para Doppus (alternativa):
1. Acesse: https://doppus.com/
2. Clique em "Começar agora"
3. Complete o cadastro

---

## 📋 PASSO 2: Obter Credenciais de API

### No Painel do Gateway:

1. **Acesse Configurações → API**
2. **Copie as seguintes informações:**
   - ✅ **API Key** ou **Token de API**
   - ✅ **API Secret** (se houver)
   - ✅ **Merchant ID** ou **Client ID** (se houver)

### Exemplo de formato:
```
API Key: pk_test_abc123xyz...
API Secret: sk_test_def456...
```

⚠️ **IMPORTANTE:** Use credenciais de **TESTE** primeiro!

---

## 📋 PASSO 3: Criar Produto/Plano no Gateway

### No Painel do Gateway:

1. Vá em **"Produtos"** ou **"Planos"**
2. Clique em **"Novo Produto"** ou **"Criar Plano"**
3. Preencha:
   - **Nome:** Plano Diamond - Nutra Elite
   - **Tipo:** Assinatura Recorrente
   - **Valor:** R$ 197,00
   - **Recorrência:** Mensal
   - **Descrição:** Acesso total à plataforma premium
4. **Salve e copie o ID do produto** (ex: `prod_abc123`)

---

## 📋 PASSO 4: Configurar Secrets no Supabase

### 1. Acesse o Supabase Dashboard
- Vá em: **Project Settings** → **Edge Functions** → **Secrets**

### 2. Adicione as seguintes variáveis:

#### Para Peper:
```env
PEPER_API_KEY=sua_api_key_aqui
PEPER_API_SECRET=sua_api_secret_aqui
APP_URL=https://seuapp.vercel.app
```

#### Para Doppus:
```env
DOPPUS_API_TOKEN=sk_test_xxxxxxxxxxxxx
APP_URL=https://seuapp.vercel.app
```

### 3. Como encontrar a URL do App:
- **Vercel:** Vá em Settings → Domains → Copie a URL
- **Exemplo:** `https://tribo-nutra-hub.vercel.app`

---

## 📋 PASSO 5: Criar Edge Functions no Supabase

### Opção A: Via CLI (Recomendado)

1. **Instalar Supabase CLI:**
```bash
npm install -g supabase
```

2. **Login:**
```bash
supabase login
```

3. **Link ao projeto:**
```bash
supabase link --project-ref [seu-project-id]
```
   - Onde encontrar o project-id: Supabase Dashboard → Settings → General → Reference ID

4. **Criar as functions:**
```bash
# Para Peper
supabase functions new create-peper-checkout
supabase functions new peper-webhook

# Para Doppus
supabase functions new create-doppus-checkout
supabase functions new doppus-webhook
```

5. **Copiar o código:**
   - Veja os arquivos `DOPPUS-SETUP.md` ou `PEPER-SETUP.md`
   - Copie o código para os arquivos criados

6. **Deploy:**
```bash
# Para Peper
supabase functions deploy create-peper-checkout
supabase functions deploy peper-webhook

# Para Doppus
supabase functions deploy create-doppus-checkout
supabase functions deploy doppus-webhook
```

### Opção B: Via Dashboard (Mais Simples)

1. **Acesse:** Supabase Dashboard → Edge Functions
2. **Clique em:** "Create a new function"
3. **Nome:** `create-peper-checkout` (ou `create-doppus-checkout`)
4. **Cole o código** do arquivo de setup correspondente
5. **Salve e faça deploy**

---

## 📋 PASSO 6: Configurar Webhook no Gateway

### No Painel do Gateway:

1. Vá em **"Configurações"** → **"Webhooks"**
2. Clique em **"Adicionar Webhook"** ou **"Novo Webhook"**
3. **Cole a URL:**
   ```
   https://[seu-project-id].supabase.co/functions/v1/peper-webhook
   ```
   ou
   ```
   https://[seu-project-id].supabase.co/functions/v1/doppus-webhook
   ```
4. **Selecione os eventos:**
   - ✅ `checkout.completed`
   - ✅ `subscription.created`
   - ✅ `subscription.cancelled`
   - ✅ `payment.succeeded`
   - ✅ `payment.failed`
5. **Salve o webhook**

### Como encontrar o Project ID:
- Supabase Dashboard → Settings → General → Reference ID
- Exemplo: `abcdefghijklmnop`

---

## 📋 PASSO 7: Testar a Integração

### 1. Teste no App:
1. Acesse `/upgrade` no seu app
2. Clique em "Assinar Plano Diamond"
3. Preencha os dados de teste
4. Use cartão de teste (veja abaixo)
5. Confirme o pagamento

### 2. Cartões de Teste:

| Gateway | Cartão | Número | CVV | Validade | Resultado |
|---------|--------|--------|-----|----------|-----------|
| Doppus | VISA | 4111 1111 1111 1111 | 123 | 12/30 | ✅ Aprovado |
| Doppus | Mastercard | 5555 5555 5555 4444 | 123 | 12/30 | ✅ Aprovado |
| Doppus | VISA | 4000 0000 0000 0002 | 123 | 12/30 | ❌ Recusado |

### 3. Verificar se funcionou:
- ✅ Redirecionamento para `/payment/success`
- ✅ Badge Diamond aparece no perfil
- ✅ Acesso liberado às funcionalidades premium

---

## 📋 PASSO 8: Verificar Logs

### No Supabase:
```bash
# Ver logs do webhook
supabase functions logs peper-webhook --tail

# Ver logs do checkout
supabase functions logs create-peper-checkout --tail
```

### No Dashboard:
- Supabase Dashboard → Edge Functions → [Nome da Function] → Logs

---

## ✅ Checklist Final

- [ ] Conta criada no gateway
- [ ] Credenciais de API obtidas
- [ ] Produto/plano criado
- [ ] Secrets configurados no Supabase
- [ ] Edge Functions criadas e deployadas
- [ ] Webhook configurado no gateway
- [ ] Teste realizado com sucesso
- [ ] Logs verificados

---

## 🆘 Problemas Comuns

### ❌ Erro: "Function not found"
**Solução:** Verifique se as functions foram deployadas corretamente

### ❌ Erro: "Invalid API key"
**Solução:** Verifique se o secret está correto no Supabase

### ❌ Erro: "Webhook not receiving events"
**Solução:** 
- Verifique se a URL do webhook está correta
- Verifique se os eventos estão selecionados
- Veja os logs da function

### ❌ Erro: "User not authenticated"
**Solução:** Verifique se o usuário está logado antes de criar checkout

---

## 📞 Próximos Passos

1. **Você:** Me envie as credenciais de API (use de teste primeiro!)
2. **Eu:** Ajusto o código conforme necessário
3. **Você:** Testa o fluxo completo
4. **Você:** Troca para credenciais de produção quando estiver pronto

---

## 🎯 Resumo Rápido

1. ✅ Criar conta no gateway
2. ✅ Obter API Key/Token
3. ✅ Criar produto/plano
4. ✅ Configurar secrets no Supabase
5. ✅ Criar e deployar Edge Functions
6. ✅ Configurar webhook
7. ✅ Testar!

---

**🚀 Pronto para começar? Me envie as credenciais e eu ajudo a configurar tudo!**

