# 📋 Como Executar o SQL para Alterar Planos

## ✅ A mensagem de erro está correta!

A mensagem **"Função RPC não encontrada"** significa que você precisa executar o SQL no Supabase.

---

## 🚀 PASSO A PASSO COMPLETO:

### 1. Abra o Supabase Dashboard:
- Acesse: **https://supabase.com/dashboard**
- Faça login se necessário
- Selecione seu projeto

### 2. Abra o SQL Editor:
- No menu lateral esquerdo, clique em **"SQL Editor"**
- Ou acesse diretamente: **https://supabase.com/dashboard/project/[SEU_PROJETO]/sql/new**

### 3. Abra o arquivo SQL:
- No seu computador, abra o arquivo: **`criar-funcao-change-plan-admin.sql`**
- Este arquivo está na raiz do projeto

### 4. Copie TODO o conteúdo:
- Pressione **Ctrl+A** (ou Cmd+A no Mac) para selecionar tudo
- Pressione **Ctrl+C** (ou Cmd+C no Mac) para copiar

### 5. Cole no SQL Editor:
- No Supabase SQL Editor, clique na área de texto
- Pressione **Ctrl+V** (ou Cmd+V no Mac) para colar

### 6. Execute o SQL:
- Clique no botão **"RUN"** (ou pressione **Ctrl+Enter**)
- Aguarde alguns segundos

### 7. Verifique o resultado:
- Você deve ver uma mensagem de sucesso
- Deve aparecer uma tabela mostrando a função criada

---

## ✅ VERIFICAÇÃO:

### Execute este SQL para verificar se funcionou:

```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

**Resultado esperado:**
- Deve retornar uma linha
- `function_name = 'change_user_plan_admin'`
- `security_definer = true`

---

## 🔄 DEPOIS DE EXECUTAR:

1. **Aguarde 1-2 minutos** para o código fazer deploy
2. **Limpe o cache do navegador:**
   - Pressione **Ctrl+Shift+R** (Windows/Linux)
   - Pressione **Cmd+Shift+R** (Mac)
3. **Faça logout e login novamente** no app
4. **Teste a alteração de plano** novamente

---

## 🧪 TESTE A FUNÇÃO:

Execute este SQL no Supabase SQL Editor (substitua `USER_ID_AQUI` pelo user_id de um usuário de teste):

```sql
-- Primeiro, pegue o user_id de um usuário
SELECT user_id, username, subscription_plan 
FROM profiles 
LIMIT 5;

-- Depois, teste a função (substitua USER_ID_AQUI pelo user_id real)
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

## ❌ Se Der Erro ao Executar:

### Erro: "function already exists"
- **Solução:** Isso é normal! A função já existe. Pode continuar.

### Erro: "permission denied"
- **Solução:** Verifique se você está logado como admin no Supabase.

### Erro: "relation does not exist"
- **Solução:** Execute primeiro os scripts de criação de tabelas (`create-stripe-payments-tables-safe.sql`).

---

## 📝 CONTEÚDO DO ARQUIVO SQL:

O arquivo `criar-funcao-change-plan-admin.sql` deve começar com:

```sql
-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ALTERAR PLANO (ADMIN)
-- =====================================================
-- Esta função executa com privilégios elevados (SECURITY DEFINER)
-- e ignora as RLS policies, permitindo que admins alterem planos
-- =====================================================

-- Dropar função se já existir
DROP FUNCTION IF EXISTS change_user_plan_admin(UUID, TEXT, TIMESTAMP WITH TIME ZONE);
...
```

**Se você ver `import`, `export`, `function`, `const` - isso NÃO é SQL!**

---

## 🎯 RESUMO:

1. ✅ Abra Supabase Dashboard
2. ✅ Vá em SQL Editor
3. ✅ Copie conteúdo de `criar-funcao-change-plan-admin.sql`
4. ✅ Cole no SQL Editor
5. ✅ Clique em RUN
6. ✅ Aguarde deploy
7. ✅ Limpe cache
8. ✅ Teste novamente

---

**🚀 Execute o SQL e me diga se funcionou!**

