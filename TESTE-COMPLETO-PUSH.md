# 🧪 Teste Completo - Push Notifications

## 📋 Passo a Passo para Diagnosticar

### 1. Executar Diagnóstico SQL

Execute o script `DIAGNOSTICO-COMPLETO-FINAL.sql` no Supabase SQL Editor.

**Me envie os resultados de:**
- Total de subscriptions (deve ser 2)
- Se RLS está ativo
- Se a política para service_role existe

### 2. Verificar Secrets do Supabase

1. Vá em **Project Settings** → **Edge Functions** → **Secrets**
2. Verifique se existem **EXATAMENTE** estes 3 secrets:
   - `VAPID_PUBLIC_KEY` ✅
   - `VAPID_PRIVATE_KEY` ✅
   - `VAPID_SUBJECT` ✅

**Se não existirem ou estiverem com nomes diferentes, adicione/renomeie.**

### 3. Verificar Logs da Edge Function

1. Vá em **Edge Functions** → **send-push-notification** → **Logs**
2. Envie uma notificação de teste
3. **Copie TODOS os logs** que aparecem

**Procure por:**
- `🔑 VAPID configurado?` - Deve mostrar todos `true`
- `🧪 Teste de conexão:` - Deve mostrar `success: true`
- `📊 Subscriptions encontradas:` - Deve mostrar `2`
- Qualquer erro que comece com `❌`

### 4. Testar Edge Function Manualmente

1. Vá em **Edge Functions** → **send-push-notification**
2. Clique em **"Invoke"** ou **"Test"**
3. Cole este JSON:
   ```json
   {
     "title": "Teste Manual",
     "body": "Teste de notificação manual",
     "url": "/"
   }
   ```
4. Clique em **"Invoke"**
5. Veja a resposta e os logs

### 5. Verificar se Subscriptions Estão Válidas

Execute no SQL Editor:

```sql
-- Verificar subscriptions com dados completos
SELECT 
  id,
  user_id,
  CASE 
    WHEN endpoint IS NULL OR LENGTH(endpoint) = 0 THEN '❌ Endpoint vazio'
    WHEN p256dh IS NULL OR LENGTH(p256dh) = 0 THEN '❌ p256dh vazio'
    WHEN auth IS NULL OR LENGTH(auth) = 0 THEN '❌ auth vazio'
    ELSE '✅ Válida'
  END as status,
  LENGTH(endpoint) as endpoint_len,
  LENGTH(p256dh) as p256dh_len,
  LENGTH(auth) as auth_len
FROM public.push_subscriptions;
```

## 🔍 Possíveis Problemas

### Problema 1: Secrets não configurados

**Sintoma:** Logs mostram `publicKey: false` ou `privateKey: false`

**Solução:** Adicionar secrets no Supabase

### Problema 2: RLS bloqueando

**Sintoma:** Teste de conexão falha ou retorna 0 subscriptions

**Solução:** Executar SQL para criar política para service_role

### Problema 3: Subscriptions inválidas

**Sintoma:** Subscriptions existem mas têm dados vazios

**Solução:** Pedir aos usuários para reativar notificações

### Problema 4: Chaves VAPID não correspondem

**Sintoma:** Notificações são enviadas mas falham

**Solução:** Garantir que chave pública e privada são um par

## 📋 Me Envie

Para diagnosticar completamente, me envie:

1. **Resultado do diagnóstico SQL** (todas as queries)
2. **Secrets configurados** (apenas confirme se os 3 existem)
3. **Logs completos da Edge Function** (quando envia notificação)
4. **Resultado do teste manual** (se funcionou)
5. **Status das subscriptions** (se são válidas)

Com essas informações, vou identificar exatamente onde está o problema!

