# 🔍 Diagnosticar Falhas de Push Notifications

## 📊 Situação Atual

- ✅ Notificações estão sendo enviadas (processo funciona)
- ❌ Todas falham (0 sucesso, 2 falhas)
- ❌ Não chegam no celular

## 🔍 Como Diagnosticar

### 1. Verificar Logs da Edge Function

1. Acesse o **Supabase Dashboard**
2. Vá em **Edge Functions** → **send-push-notification**
3. Clique na aba **"Logs"** ou **"Invoke"**
4. Procure por erros que começam com `❌`

**Erros comuns:**
- `Chaves VAPID não configuradas` → Secrets não estão configurados
- `Error: Invalid VAPID key` → Chaves VAPID incorretas
- `410 Gone` → Endpoint expirado (subscription inválida)
- `401 Unauthorized` → Chave VAPID privada incorreta
- `Module not found` → Problema com a biblioteca

### 2. Verificar Secrets do Supabase

1. **Project Settings** → **Edge Functions** → **Secrets**
2. Verifique se existem:
   - `VAPID_PUBLIC_KEY` ✅
   - `VAPID_PRIVATE_KEY` ✅
   - `VAPID_SUBJECT` ✅ (formato: `mailto:seu@email.com`)

### 3. Verificar Subscriptions no Banco

Execute no SQL Editor do Supabase:

```sql
SELECT 
  user_id,
  endpoint,
  LENGTH(p256dh) as p256dh_length,
  LENGTH(auth) as auth_length,
  created_at,
  updated_at
FROM push_subscriptions
ORDER BY updated_at DESC;
```

**Verifique:**
- Se há subscriptions (deve ter 2)
- Se `p256dh` e `auth` não estão vazios
- Se as subscriptions são recentes

### 4. Testar Edge Function Manualmente

1. Vá em **Edge Functions** → **send-push-notification**
2. Clique em **"Invoke"** ou **"Test"**
3. Cole este JSON:
   ```json
   {
     "title": "Teste",
     "body": "Teste de notificação",
     "url": "/"
   }
   ```
4. Clique em **"Invoke"**
5. Veja a resposta e os logs

## 🔧 Possíveis Problemas e Soluções

### Problema 1: Biblioteca web-push não funciona

**Sintoma:** Erro "Module not found" ou "Cannot import"

**Solução:** A biblioteca pode não ser compatível. Pode ser necessário implementar manualmente.

### Problema 2: Chaves VAPID incorretas

**Sintoma:** Erro "Invalid VAPID key" ou "401 Unauthorized"

**Solução:**
1. Verifique se as chaves estão corretas nos secrets
2. Certifique-se de que a chave pública no `.env` é a mesma do secret
3. Regenerar chaves se necessário

### Problema 3: Subscriptions inválidas

**Sintoma:** Erro "410 Gone" ou "Invalid subscription"

**Solução:**
1. As subscriptions podem ter expirado
2. Peça aos usuários para reativar as notificações
3. Limpe subscriptions antigas

### Problema 4: VAPID_SUBJECT incorreto

**Sintoma:** Erro relacionado a subject

**Solução:**
- Deve estar no formato: `mailto:seu@email.com`
- Não pode ser apenas um email, precisa do prefixo `mailto:`

## 📋 Me Envie

Para diagnosticar melhor, me envie:

1. **Logs da Edge Function** (copie os erros que aparecem)
2. **Resultado do teste manual** (o que aparece quando invoca a função)
3. **Secrets configurados** (apenas confirme se estão lá, não envie os valores)
4. **Resultado da query SQL** (quantas subscriptions existem)

## 🚀 Próximos Passos

1. **Faça o deploy da nova versão** da Edge Function (com a correção da biblioteca)
2. **Verifique os logs** após o deploy
3. **Teste manualmente** a função
4. **Me envie os resultados** para continuar diagnosticando


