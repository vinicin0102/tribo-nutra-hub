# 🔍 Diagnóstico: Erro Edge Function Stripe

## ❌ Erro Atual:
**"Edge Function returned a non-2xx status code"**

Isso significa que a Edge Function `create-stripe-checkout` está retornando um erro (status 4xx ou 5xx).

---

## 🔧 Passo 1: Verificar Logs da Edge Function

1. **Acesse o Supabase Dashboard:**
   - Vá em **Edge Functions** → **create-stripe-checkout**
   - Clique na aba **"Logs"**

2. **Procure por erros recentes:**
   - Veja os logs das últimas tentativas
   - Procure por mensagens de erro como:
     - "Variáveis de ambiente faltando"
     - "Erro Stripe: ..."
     - "Erro de autenticação"
     - "Configuração do servidor incompleta"

---

## 🔧 Passo 2: Verificar Secrets

Os secrets estão configurados, mas vamos verificar se estão corretos:

### Secrets Necessários:
- ✅ `STRIPE_SECRET_KEY` - Chave secreta do Stripe (sk_live_... ou sk_test_...)
- ✅ `STRIPE_PRICE_ID` - ID do preço (price_...)
- ✅ `APP_URL` - URL do app (https://sociedadenutra.com)
- ✅ `SUPABASE_URL` - URL do Supabase (automático)
- ✅ `SUPABASE_SERVICE_ROLE_KEY` - Chave de serviço (automático)

### ⚠️ Verificar se `STRIPE_SECRET_KEY` está correto:
- Deve começar com `sk_live_` (produção) ou `sk_test_` (teste)
- Não deve ter espaços ou quebras de linha
- Deve ser a chave completa

---

## 🔧 Passo 3: Verificar se a Edge Function está Deployada

1. **No Supabase Dashboard:**
   - Vá em **Edge Functions**
   - Verifique se `create-stripe-checkout` aparece na lista
   - Deve mostrar "Deployed" ou data de deploy

2. **Se não estiver deployada:**
   - Use o CLI do Supabase para fazer deploy:
   ```bash
   supabase functions deploy create-stripe-checkout
   ```

---

## 🔧 Passo 4: Testar a Edge Function Manualmente

### Opção 1: Via Supabase Dashboard
1. Vá em **Edge Functions** → **create-stripe-checkout**
2. Clique em **"Invoke"** ou **"Test"**
3. Envie o body:
   ```json
   {
     "planType": "diamond"
   }
   ```
4. Veja a resposta e os logs

### Opção 2: Via cURL (no terminal)
```bash
curl -X POST \
  'https://SEU_PROJECT_ID.supabase.co/functions/v1/create-stripe-checkout' \
  -H 'Authorization: Bearer SEU_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"planType": "diamond"}'
```

---

## 🔧 Passo 5: Verificar Código da Edge Function

A Edge Function precisa:
1. ✅ Verificar variáveis de ambiente (STRIPE_SECRET_KEY, STRIPE_PRICE_ID, APP_URL)
2. ✅ Autenticar o usuário
3. ✅ Criar sessão de checkout no Stripe
4. ✅ Retornar URL de checkout

---

## 🐛 Erros Comuns e Soluções:

### 1. "Variáveis de ambiente faltando"
**Causa:** Secret não configurado ou nome incorreto
**Solução:** 
- Verifique se os secrets estão com os nomes exatos:
  - `STRIPE_SECRET_KEY` (não `STRIPE_SECRET` ou `STRIPE_KEY`)
  - `STRIPE_PRICE_ID` (não `STRIPE_PRICE` ou `PRICE_ID`)
  - `APP_URL` (não `APP_URL_PROD` ou `URL`)

### 2. "Erro Stripe: ..."
**Causa:** Problema com a API do Stripe
**Solução:**
- Verifique se `STRIPE_SECRET_KEY` está correto
- Verifique se `STRIPE_PRICE_ID` existe no Stripe
- Verifique se a chave está no modo correto (teste vs produção)

### 3. "Usuário não autenticado"
**Causa:** Token de autenticação inválido ou ausente
**Solução:**
- Faça logout e login novamente
- Verifique se o usuário está autenticado

### 4. "Configuração do servidor incompleta"
**Causa:** `SUPABASE_URL` ou `SUPABASE_SERVICE_ROLE_KEY` não configurados
**Solução:**
- Esses são automáticos, mas verifique se o projeto está configurado corretamente

---

## ✅ Próximos Passos:

1. **Verifique os logs** da Edge Function no Supabase Dashboard
2. **Copie a mensagem de erro exata** dos logs
3. **Compare com os erros comuns** acima
4. **Aplique a solução** correspondente

---

## 📋 Checklist Rápido:

- [ ] Edge Function está deployada?
- [ ] Secrets estão configurados corretamente?
- [ ] `STRIPE_SECRET_KEY` está correto e completo?
- [ ] `STRIPE_PRICE_ID` existe no Stripe?
- [ ] `APP_URL` está correto (https://sociedadenutra.com)?
- [ ] Logs mostram algum erro específico?

---

**🔍 Depois de verificar os logs, me envie a mensagem de erro exata para eu ajudar a resolver!**

