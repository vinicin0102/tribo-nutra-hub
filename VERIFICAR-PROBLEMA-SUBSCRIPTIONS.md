# 🔍 Verificar Por Que Subscriptions Não São Encontradas

## 📊 Situação

- ✅ 2 dispositivos aceitaram notificações
- ❌ Edge Function encontra 0 subscriptions ao enviar
- ❌ Notificação enviada para 0 dispositivos

## 🔍 Diagnóstico

### 1. Verificar se a tabela existe e tem dados

Execute no SQL Editor do Supabase:

```sql
-- Verificar se a tabela existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'push_subscriptions'
) as tabela_existe;

-- Contar subscriptions
SELECT COUNT(*) as total FROM push_subscriptions;

-- Ver todas as subscriptions
SELECT * FROM push_subscriptions;
```

### 2. Verificar RLS (Row Level Security)

```sql
-- Verificar se RLS está ativo
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'push_subscriptions';

-- Ver políticas RLS
SELECT * FROM pg_policies 
WHERE tablename = 'push_subscriptions';
```

### 3. Verificar se a Edge Function tem acesso

A Edge Function usa `SUPABASE_SERVICE_ROLE_KEY`, que deve ter acesso total.

**Teste:** Execute na Edge Function (via Invoke):

```json
{
  "title": "Teste",
  "body": "Teste",
  "url": "/"
}
```

E veja os logs - deve aparecer:
- `📊 Subscriptions encontradas: 2` (ou o número correto)

### 4. Verificar se subscriptions estão sendo salvas

Execute:

```sql
-- Ver subscriptions com detalhes
SELECT 
  id,
  user_id,
  LEFT(endpoint, 80) as endpoint_preview,
  LENGTH(p256dh) as p256dh_size,
  LENGTH(auth) as auth_size,
  user_agent,
  created_at,
  updated_at
FROM push_subscriptions
ORDER BY updated_at DESC;
```

## 🔧 Possíveis Problemas e Soluções

### Problema 1: RLS bloqueando acesso

**Sintoma:** Tabela existe, tem dados, mas Edge Function não encontra

**Solução:** Verificar se há política RLS que bloqueia a service role key

```sql
-- Desabilitar RLS temporariamente para testar (CUIDADO!)
ALTER TABLE push_subscriptions DISABLE ROW LEVEL SECURITY;

-- Ou criar política que permite service role
CREATE POLICY "Service role can read all subscriptions"
ON push_subscriptions FOR SELECT
TO service_role
USING (true);
```

### Problema 2: Tabela não existe

**Sintoma:** Erro ao executar SELECT

**Solução:** Executar a migration:

```sql
-- Verificar se migration foi executada
SELECT * FROM supabase_migrations.schema_migrations 
WHERE name LIKE '%push_subscriptions%';

-- Se não existir, executar a migration manualmente
```

### Problema 3: Service Role Key incorreta

**Sintoma:** Edge Function não consegue acessar banco

**Solução:** Verificar se `SUPABASE_SERVICE_ROLE_KEY` está configurado corretamente nos secrets

## 📋 Me Envie

Para diagnosticar, me envie:

1. **Resultado da query de contagem:** `SELECT COUNT(*) FROM push_subscriptions;`
2. **Resultado da verificação de RLS:** Se RLS está ativo e quais políticas existem
3. **Logs da Edge Function:** O que aparece quando tenta enviar (especialmente `📊 Subscriptions encontradas: X`)
4. **Se a tabela existe:** Resultado da primeira query

## 🚀 Próximos Passos

1. Execute as queries SQL acima
2. Verifique os logs da Edge Function
3. Me envie os resultados
4. Vou corrigir o problema baseado nos resultados

