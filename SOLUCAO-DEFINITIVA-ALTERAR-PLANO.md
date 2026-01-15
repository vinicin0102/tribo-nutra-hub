# ✅ Solução Definitiva: Alterar Plano

## 🔍 Problema:

A função RPC não está sendo encontrada ou não está funcionando.

---

## ✅ SOLUÇÃO APLICADA:

### 1. **Fallback Automático**

O código agora:
- ✅ Tenta usar a função RPC primeiro
- ✅ Se a função não existir, usa UPDATE direto automaticamente
- ✅ Mostra mensagem clara se precisar executar o SQL

### 2. **SQL Final Simplificado**

Criei `criar-funcao-change-plan-admin-final.sql` com:
- ✅ Remoção de todas as versões antigas
- ✅ Criação limpa da função
- ✅ Múltiplas permissões (authenticated, anon, service_role)
- ✅ Verificação automática

---

## 🚀 EXECUTE O SQL (RECOMENDADO):

### Arquivo: `criar-funcao-change-plan-admin-final.sql`

1. **Abra o Supabase Dashboard:**
   - Acesse: https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em **"SQL Editor"**

2. **Copie e cole o conteúdo de `criar-funcao-change-plan-admin-final.sql`**

3. **Execute (RUN ou Ctrl+Enter)**

4. **Verifique:**
   - Deve aparecer: **"✅ Função criada!"**
   - Deve mostrar `function_name = 'change_user_plan_admin'`

---

## 🔍 DIAGNÓSTICO:

Execute este SQL para verificar:

**Arquivo:** `DIAGNOSTICO-FUNCAO-RPC.sql`

```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

**Se não retornar nada, a função não existe. Execute o SQL acima.**

---

## ⚡ SOLUÇÃO TEMPORÁRIA (SEM SQL):

O código agora funciona **mesmo sem a função RPC**!

1. **Aguarde o deploy** (alguns minutos)
2. **Limpe o cache:** Ctrl+Shift+R (ou Cmd+Shift+R)
3. **Faça logout e login novamente**
4. **Teste a alteração de plano**

O sistema vai tentar usar a função RPC, e se não existir, vai usar UPDATE direto automaticamente.

**⚠️ ATENÇÃO:** O UPDATE direto pode falhar por RLS. Se falhar, você PRECISA executar o SQL.

---

## 🔧 SE AINDA NÃO FUNCIONAR:

### 1. Verifique o Console (F12):
Procure por:
- **"⚠️ Função RPC não encontrada, tentando UPDATE direto..."**
- **"❌ ERRO AO ATUALIZAR PLANO (UPDATE DIRETO)"**
- Veja a mensagem de erro completa

### 2. Execute o SQL de Diagnóstico:
```sql
SELECT 
  proname as function_name
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

### 3. Se a função não existir:
Execute `criar-funcao-change-plan-admin-final.sql`

### 4. Se a função existir mas ainda falhar:
Pode ser problema de RLS. Execute `FIX-RLS-DEFINITIVO.sql`

---

## 📋 RESUMO:

1. ✅ **Código atualizado** com fallback automático
2. ✅ **SQL final criado** (`criar-funcao-change-plan-admin-final.sql`)
3. ✅ **Script de diagnóstico** (`DIAGNOSTICO-FUNCAO-RPC.sql`)

**Execute o SQL `criar-funcao-change-plan-admin-final.sql` para garantir que funcione perfeitamente!**

---

**🚀 Aguarde o deploy e teste novamente. Se ainda não funcionar, me envie os logs do console (F12)!**

