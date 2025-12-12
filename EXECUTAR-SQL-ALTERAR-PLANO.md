# 🚨 Execute o SQL para Alterar Planos

## ⚠️ O erro "Erro ao alterar plano" aparece porque a função RPC ainda não foi criada!

---

## 📋 PASSO A PASSO:

### 1. Abra o Supabase Dashboard:
- Acesse: https://supabase.com/dashboard
- Selecione seu projeto
- Clique em **"SQL Editor"** no menu lateral

### 2. Copie e Cole este SQL Completo:

**Arquivo:** `criar-funcao-change-plan-admin.sql`

Copie TODO o conteúdo deste arquivo e cole no SQL Editor.

### 3. Clique em **"RUN"** (ou pressione Ctrl+Enter)

### 4. Verifique se a função foi criada:

Execute este SQL:
```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

**Deve retornar:**
- `function_name = 'change_user_plan_admin'`
- `security_definer = true`

---

## ✅ DEPOIS DE EXECUTAR:

1. **Aguarde o deploy do código** (alguns minutos)
2. **Limpe o cache do navegador:**
   - Pressione **Ctrl+Shift+R** (hard refresh)
3. **Faça logout e login novamente**
4. **Teste a alteração de plano novamente**

---

## 🔍 Se Ainda Não Funcionar:

### Verifique o Console (F12):
Procure por:
- **"🖱️ Botão Salvar (Plano) clicado"** - O botão foi clicado
- **"🔄 [UserManagement] handleChangePlan chamado"** - A função foi chamada
- **"❌ ERRO AO ALTERAR PLANO (RPC)"** - Erro na função RPC
- **"❌ Função RPC não encontrada"** - A função não existe no banco

### Verifique se a Função Existe:

Execute no SQL Editor:
```sql
SELECT proname FROM pg_proc WHERE proname = 'change_user_plan_admin';
```

**Deve retornar uma linha com `change_user_plan_admin`**

### Teste a Função Manualmente:

Execute no SQL Editor (substitua `USER_ID_AQUI` pelo user_id de um usuário de teste):
```sql
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
  "user_id": "USER_ID_AQUI",
  "plan": "diamond"
}
```

---

## ⚠️ IMPORTANTE:

**Este SQL PRECISA ser executado no Supabase SQL Editor!**

Sem executar este SQL, o botão "Salvar" **NÃO VAI FUNCIONAR** porque a função RPC não existe no banco de dados.

---

**🚀 Execute o SQL `criar-funcao-change-plan-admin.sql` e teste novamente!**

