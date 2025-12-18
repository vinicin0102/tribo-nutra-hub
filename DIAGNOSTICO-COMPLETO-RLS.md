# 🔍 Diagnóstico Completo - RLS e Subscriptions

## 📊 Situação

- ✅ 2 dispositivos aceitaram notificações
- ✅ Política RLS criada para service_role
- ❌ Ainda encontra 0 subscriptions

## 🔍 Verificações Necessárias

### 1. Verificar se a política foi criada

Execute:

```sql
SELECT 
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'push_subscriptions';
```

**Deve aparecer:** `Service role can read all subscriptions` com `roles: {service_role}`

### 2. Verificar se há subscriptions no banco

```sql
-- Contar subscriptions
SELECT COUNT(*) as total FROM public.push_subscriptions;

-- Ver todas as subscriptions
SELECT 
  id,
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  created_at
FROM public.push_subscriptions;
```

**Deve retornar:** 2 subscriptions

### 3. Testar acesso com service_role

```sql
-- Simular acesso como service_role (não funciona diretamente, mas podemos testar)
-- A Edge Function usa service_role automaticamente
```

### 4. Verificar logs da Edge Function

1. Vá em **Edge Functions** → **send-push-notification** → **Logs**
2. Envie uma notificação
3. Veja os logs - deve aparecer:
   - `🧪 Teste de conexão: { success: true/false }`
   - `📊 Subscriptions encontradas: X`

## 🔧 Possíveis Problemas

### Problema 1: Política não foi aplicada corretamente

**Sintoma:** Política existe mas não funciona

**Solução:** Recriar a política:

```sql
-- Remover e recriar
DROP POLICY IF EXISTS "Service role can read all subscriptions" ON public.push_subscriptions;

CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);
```

### Problema 2: Service Role Key incorreta

**Sintoma:** Erro de autenticação nos logs

**Solução:** Verificar se `SUPABASE_SERVICE_ROLE_KEY` está correto nos secrets

### Problema 3: RLS ainda bloqueando

**Sintoma:** Teste de conexão falha

**Solução:** Desabilitar RLS temporariamente para testar:

```sql
-- CUIDADO: Apenas para teste!
ALTER TABLE public.push_subscriptions DISABLE ROW LEVEL SECURITY;

-- Testar se funciona
-- Se funcionar, reabilitar e corrigir políticas
ALTER TABLE public.push_subscriptions ENABLE ROW LEVEL SECURITY;
```

## 📋 Me Envie

1. **Resultado da query de políticas** (se a política aparece)
2. **Resultado da contagem** (quantas subscriptions existem)
3. **Logs da Edge Function** (especialmente o teste de conexão)
4. **Se há algum erro** nos logs

## 🚀 Próximo Passo

Execute as verificações acima e me envie os resultados. Com base nisso, vou corrigir o problema específico.

