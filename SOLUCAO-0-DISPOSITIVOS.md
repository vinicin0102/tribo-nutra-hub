# 🔴 Problema: "Enviada para 0 dispositivo(s)" mas há 3 usuários ativos

## 📋 Diagnóstico

O painel mostra **3 usuários com push ativo**, mas a mensagem de confirmação diz **"Enviada para 0 dispositivo(s)"**.

**Causa:** A Edge Function não está conseguindo ler as subscriptions do banco porque o **RLS (Row Level Security) está bloqueando** a `service_role`.

---

## ✅ Solução Passo a Passo

### Passo 1: Executar SQL para Corrigir RLS

1. Acesse o **Supabase Dashboard** → **SQL Editor**
2. Execute o arquivo: **`CORRIGIR-RLS-PUSH-URGENTE.sql`**
3. Isso criará a política RLS necessária para a `service_role` ler as subscriptions

### Passo 2: Verificar se Funcionou

Após executar o SQL, você deve ver:
- ✅ "Política criada!" com `service_role` na lista de roles
- ✅ "Total de subscriptions no banco: 3" (ou o número correto)

### Passo 3: Testar Novamente

1. Volte ao painel admin → **Push**
2. Envie uma notificação de teste
3. Agora deve mostrar **"Enviada para 3 dispositivo(s)"** (ou o número correto)

---

## 🔍 Se Ainda Não Funcionar

### Verificar Logs da Edge Function

1. Acesse: **Supabase Dashboard** → **Edge Functions** → **send-push-notification**
2. Clique na aba **"Logs"**
3. Envie uma notificação de teste
4. Veja os logs e procure por:
   - `📊 Subscriptions encontradas: X`
   - `❌ Erro ao buscar subscriptions`
   - `⚠️ NENHUMA SUBSCRIPTION ENCONTRADA!`

### Possíveis Problemas

1. **RLS ainda bloqueando:**
   - Execute novamente `CORRIGIR-RLS-PUSH-URGENTE.sql`
   - Verifique se a política aparece na lista

2. **Service Role Key incorreta:**
   - Verifique se `SUPABASE_SERVICE_ROLE_KEY` está configurada nos secrets da Edge Function
   - Acesse: **Settings** → **Edge Functions** → **Secrets**

3. **Tabela vazia:**
   - Execute `VERIFICAR-TUDO-PUSH-NOTIFICATIONS.sql` para verificar quantas subscriptions existem

---

## 📊 Verificação Rápida

Execute este SQL para verificar tudo de uma vez:

```sql
-- Verificar política RLS
SELECT 
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'push_subscriptions'
AND 'service_role' = ANY(roles);

-- Contar subscriptions
SELECT COUNT(*) as total FROM public.push_subscriptions;
```

**Resultado esperado:**
- ✅ Política com `service_role` existe
- ✅ Total de subscriptions > 0

---

## 🎯 Próximos Passos

1. ✅ Execute `CORRIGIR-RLS-PUSH-URGENTE.sql`
2. ✅ Teste enviar uma notificação
3. ✅ Verifique os logs se ainda não funcionar
4. ✅ Me envie os resultados

