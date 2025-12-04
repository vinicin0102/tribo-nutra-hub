# 🔐 Configuração de Secrets - Guia Rápido

## ⚠️ ATENÇÃO: Adicione APENAS 2 Secrets!

No Supabase Dashboard:
1. Vá em: **Project Settings** → **Edge Functions** → **Secrets**
2. Clique em **"Add another"** se necessário
3. Preencha **EXATAMENTE** como abaixo:

---

## ✅ Secret 1: Token do Mercado Pago

**Name:**
```
MERCADOPAGO_ACCESS_TOKEN
```

**Value:**
```
TEST-1234567890-012345-abcdefghijklmnopqrstuvwxyz-1234567
```

👆 Substitua pelo seu token real do Mercado Pago

### Como obter:
1. Acesse: https://www.mercadopago.com.br/developers/
2. Faça login
3. Vá em: **Suas integrações** → **Credenciais**
4. Copie o **Access Token de TESTE** (começa com `TEST-`)

---

## ✅ Secret 2: URL do App

**Name:**
```
APP_URL
```

**Value:**
```
https://seuapp.vercel.app
```

👆 Substitua pela URL do seu app no Vercel (ou domínio customizado)

### Como obter:
1. Vá no seu projeto no Vercel
2. Copie a URL de produção (ex: `https://tribo-nutra-hub.vercel.app`)
3. **NÃO inclua `/` no final**

---

## ❌ NÃO Adicione Estas Variáveis:

### ~~SUPABASE_URL~~ 
**Motivo:** Já disponível automaticamente como `Deno.env.get('SUPABASE_URL')`

### ~~SUPABASE_SERVICE_ROLE_KEY~~
**Motivo:** Já disponível automaticamente como `Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')`

### ~~SUPABASE_ANON_KEY~~
**Motivo:** Já disponível automaticamente como `Deno.env.get('SUPABASE_ANON_KEY')`

---

## 📸 Exemplo Visual:

```
┌─────────────────────────────────────────────────────────────┐
│ ADD OR REPLACE SECRETS                                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ Name: MERCADOPAGO_ACCESS_TOKEN                    [👁] [-]  │
│ Value: TEST-1234567890-012345-abc...              [👁] [-]  │
│                                                              │
│ Name: APP_URL                                     [👁] [-]  │
│ Value: https://seuapp.vercel.app                  [👁] [-]  │
│                                                              │
│ [+ Add another]                                              │
│                                                              │
│                                      [Bulk save 💾]          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Passos Finais:

1. ✅ Preencha **MERCADOPAGO_ACCESS_TOKEN**
2. ✅ Preencha **APP_URL**
3. ✅ Remova `SUPABASE_URL` (se adicionou)
4. ✅ Remova `SUPABASE_SERVICE_ROLE_KEY` (se adicionou)
5. ✅ Clique em **"Bulk save"** (botão verde)
6. ✅ Aguarde confirmação de sucesso ✅

---

## 🧪 Teste Rápido:

Após salvar os secrets, teste se funcionou:

```bash
# Deploy da função novamente
supabase functions deploy create-payment

# Verificar se não tem erros
supabase functions logs create-payment --tail
```

---

## 🐛 Erros Comuns:

### "Name must not start with the SUPABASE_ prefix"
**Solução:** Remova essa variável, ela já existe automaticamente!

### "Invalid access token"
**Solução:** Copie novamente o token do Mercado Pago, certifique-se de copiar completo

### "Malformed URL"
**Solução:** URL deve começar com `https://` e não ter `/` no final

---

## ✅ Confirmação:

Após salvar, você deve ver na lista:

```
NAME                          DIGEST      UPDATED AT
────────────────────────────────────────────────────
MERCADOPAGO_ACCESS_TOKEN      SHA256      há 1 minuto
APP_URL                       SHA256      há 1 minuto
```

Pronto! Secrets configurados corretamente! 🎉

