# 🔍 Diagnóstico Completo - Subscriptions Não Aparecem

## 🔴 Problema

O painel admin mostra **"3 Usuários com push ativo"**, mas quando você executa SQL diretamente, retorna **0 subscriptions**.

## 📋 Possíveis Causas

### 1. **RLS Bloqueando a Visualização**
- O SQL Editor pode não estar usando o contexto de admin
- As políticas RLS podem estar bloqueando a visualização
- A `service_role` pode não ter permissão

### 2. **Subscriptions Não Estão Sendo Salvas**
- O frontend pode estar mostrando dados em cache
- As subscriptions podem não estar sendo salvas no banco
- Pode haver erro silencioso ao salvar

### 3. **Problema de Autenticação**
- O painel admin usa autenticação de admin (que tem permissão)
- O SQL Editor pode usar contexto diferente

---

## ✅ Solução Passo a Passo

### Passo 1: Verificar Subscriptions Reais (Bypassando RLS)

Execute o arquivo: **`VERIFICAR-SUBSCRIPTIONS-REAIS.sql`**

Este script:
- ✅ Cria funções `SECURITY DEFINER` para bypassar RLS
- ✅ Mostra o número REAL de subscriptions no banco
- ✅ Lista todas as subscriptions com detalhes
- ✅ Verifica todas as políticas RLS

**Resultado esperado:**
- Se mostrar **3 subscriptions** → O problema é RLS bloqueando a visualização
- Se mostrar **0 subscriptions** → As subscriptions não estão sendo salvas

### Passo 2: Verificar se Subscriptions Estão Sendo Salvas

**No console do navegador (F12):**

1. Abra o app no navegador
2. Vá em **Perfil** → **Notificações Push**
3. Tente ativar as notificações
4. Abra o **Console** (F12 → Console)
5. Procure por logs que começam com `[Push]`
6. Procure por:
   - `✅ Subscription salva no banco com sucesso!`
   - `❌ Erro ao salvar subscription`

### Passo 3: Verificar Políticas RLS

Execute este SQL simples:

```sql
-- Ver todas as políticas
SELECT 
  policyname,
  roles,
  cmd
FROM pg_policies 
WHERE tablename = 'push_subscriptions';
```

**Deve ter:**
- ✅ "Users can view own subscriptions" (para usuários)
- ✅ "Admins can view all subscriptions" (para admins)
- ✅ "Service role can read all subscriptions" (para Edge Function)

---

## 🎯 Próximos Passos Baseado no Resultado

### Se `VERIFICAR-SUBSCRIPTIONS-REAIS.sql` mostrar 3 subscriptions:

**Problema:** RLS está bloqueando a visualização no SQL Editor

**Solução:**
1. Execute `CORRIGIR-RLS-PUSH-URGENTE.sql` novamente
2. Verifique se a política para `service_role` existe
3. A Edge Function deve funcionar (ela usa service_role)

### Se `VERIFICAR-SUBSCRIPTIONS-REAIS.sql` mostrar 0 subscriptions:

**Problema:** As subscriptions não estão sendo salvas

**Solução:**
1. Verifique os logs do console do navegador
2. Verifique se há erros ao salvar
3. Verifique se a tabela `push_subscriptions` existe
4. Verifique se as políticas RLS permitem INSERT

---

## 🔧 Verificação Rápida no Console

Execute no **console do navegador** (F12):

```javascript
// Verificar se há subscriptions salvas
const { data, error } = await supabase
  .from('push_subscriptions')
  .select('*');

console.log('Subscriptions encontradas:', data?.length || 0);
console.log('Erro:', error);
```

Se retornar subscriptions, elas existem. Se retornar erro, pode ser problema de RLS.

---

## 📊 Checklist

- [ ] Execute `VERIFICAR-SUBSCRIPTIONS-REAIS.sql`
- [ ] Verifique quantas subscriptions aparecem
- [ ] Verifique os logs do console ao ativar notificações
- [ ] Verifique as políticas RLS
- [ ] Me envie os resultados

