# ✅ SQL Simplificado - Execute Este

## 🚀 VERSÃO SIMPLES E DIRETA

Criei uma versão **mais simples** do SQL, sem verificações complexas.

---

## 📋 PASSO A PASSO:

### 1. Abra o Supabase Dashboard:
- Acesse: **https://supabase.com/dashboard**
- Selecione seu projeto
- Clique em **"SQL Editor"**

### 2. Abra o arquivo SQL:
- No seu computador, abra: **`criar-funcao-change-plan-admin-simples.sql`**

### 3. Copie TODO o conteúdo:
- Pressione **Ctrl+A** (ou Cmd+A no Mac)
- Pressione **Ctrl+C** (ou Cmd+C no Mac)

### 4. Cole no SQL Editor:
- Cole o conteúdo no Supabase SQL Editor
- Clique em **"RUN"** (ou Ctrl+Enter)

### 5. Verifique:
- Deve aparecer uma mensagem: **"Função criada com sucesso!"**
- Deve mostrar `function_name = 'change_user_plan_admin'`
- Deve mostrar `security_definer = true`

---

## ✅ VERIFICAÇÃO RÁPIDA:

Execute este SQL:

```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

**Deve retornar uma linha com a função.**

---

## 🧪 TESTE RÁPIDO:

Execute este SQL (substitua `USER_ID_AQUI`):

```sql
-- Pegar um user_id
SELECT user_id, username 
FROM profiles 
LIMIT 1;

-- Testar função (substitua USER_ID_AQUI)
SELECT change_user_plan_admin(
  'USER_ID_AQUI'::UUID,
  'diamond',
  NULL
);
```

**Deve retornar:**
```json
{
  "success": true,
  "message": "Plano alterado com sucesso",
  "user_id": "...",
  "plan": "diamond"
}
```

---

## 🔄 DEPOIS:

1. **Aguarde 1-2 minutos**
2. **Limpe o cache:** Ctrl+Shift+R (ou Cmd+Shift+R)
3. **Faça logout e login**
4. **Teste a alteração de plano**

---

**🚀 Execute o SQL `criar-funcao-change-plan-admin-simples.sql` e teste!**

