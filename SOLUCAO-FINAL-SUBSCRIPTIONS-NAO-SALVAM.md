# 🔴 Problema: Subscriptions Não Estão Sendo Salvas

## 📊 Diagnóstico Confirmado

O script `VERIFICAR-SUBSCRIPTIONS-REAIS.sql` confirmou:
- ✅ **0 subscriptions** no banco (mesmo bypassando RLS)
- ✅ **6 políticas RLS** existem
- ✅ **Política para service_role** existe

**Conclusão:** As subscriptions **não estão sendo salvas** quando os usuários ativam as notificações.

---

## 🔍 Possíveis Causas

### 1. **Constraint UNIQUE Não Existe**
- O código usa `upsert` com `onConflict: 'user_id,endpoint'`
- Se a constraint não existir, o `upsert` pode falhar silenciosamente

### 2. **Política RLS Bloqueando INSERT**
- Usuários podem não ter permissão para inserir suas próprias subscriptions
- A política de INSERT pode estar faltando ou incorreta

### 3. **Erro Silencioso no Frontend**
- O código pode estar ignorando erros
- Os logs do console podem mostrar o erro real

---

## ✅ Solução Passo a Passo

### Passo 1: Corrigir a Tabela

Execute o arquivo: **`CORRIGIR-TABELA-PUSH-SUBSCRIPTIONS.sql`**

Este script:
- ✅ Garante que a tabela existe com estrutura correta
- ✅ Cria a constraint UNIQUE `(user_id, endpoint)` necessária para `upsert`
- ✅ Cria políticas RLS para INSERT e UPDATE
- ✅ Garante que `service_role` pode ler e inserir

### Passo 2: Diagnosticar o Problema

Execute o arquivo: **`DIAGNOSTICAR-PORQUE-NAO-SALVA.sql`**

Este script mostra:
- ✅ Estrutura da tabela
- ✅ Constraints existentes
- ✅ Políticas RLS para INSERT
- ✅ Se a constraint UNIQUE existe

### Passo 3: Testar no Console do Navegador

**No console do navegador (F12):**

1. Abra o app
2. Vá em **Perfil** → **Notificações Push**
3. Tente ativar as notificações
4. Abra o **Console** (F12 → Console)
5. Procure por logs que começam com `[Push]`
6. Procure especificamente por:
   - `[Push] ✅ Subscription salva no banco com sucesso!`
   - `[Push] ❌ Erro ao salvar subscription:`
   - `[Push] Código do erro:`
   - `[Push] Mensagem:`

### Passo 4: Verificar Erros Específicos

**Se aparecer erro no console, verifique:**

#### Erro: "permission denied" ou "RLS policy violation"
- **Solução:** Execute `CORRIGIR-TABELA-PUSH-SUBSCRIPTIONS.sql` novamente

#### Erro: "duplicate key value" ou "unique constraint violation"
- **Solução:** A constraint existe, mas pode estar conflitando. Verifique se há subscriptions antigas.

#### Erro: "column does not exist"
- **Solução:** A estrutura da tabela está incorreta. Execute `CORRIGIR-TABELA-PUSH-SUBSCRIPTIONS.sql`

#### Erro: "network" ou "connection"
- **Solução:** Problema de conexão. Verifique a internet.

---

## 🎯 Teste Manual

**No console do navegador, execute:**

```javascript
// Verificar se consegue inserir uma subscription de teste
const { data, error } = await supabase
  .from('push_subscriptions')
  .insert({
    user_id: 'SEU_USER_ID_AQUI', // Substitua pelo seu user_id
    endpoint: 'https://fcm.googleapis.com/fcm/send/test',
    p256dh: 'test_p256dh',
    auth: 'test_auth'
  })
  .select();

console.log('Resultado:', { data, error });
```

**Se der erro:**
- Copie o erro completo
- Me envie o erro para eu corrigir

**Se funcionar:**
- O problema é no código de ativação
- Verifique os logs do console ao ativar

---

## 📋 Checklist

- [ ] Execute `CORRIGIR-TABELA-PUSH-SUBSCRIPTIONS.sql`
- [ ] Execute `DIAGNOSTICAR-PORQUE-NAO-SALVA.sql`
- [ ] Tente ativar notificações no app
- [ ] Verifique os logs do console (F12)
- [ ] Execute o teste manual no console
- [ ] Me envie os resultados

---

## 🔧 Próximos Passos

Depois de executar os scripts:

1. **Se a constraint UNIQUE não existir:**
   - O script `CORRIGIR-TABELA-PUSH-SUBSCRIPTIONS.sql` vai criá-la
   - Teste novamente ativando as notificações

2. **Se a política RLS estiver faltando:**
   - O script vai criá-la
   - Teste novamente

3. **Se ainda não funcionar:**
   - Verifique os logs do console
   - Execute o teste manual
   - Me envie os erros específicos

