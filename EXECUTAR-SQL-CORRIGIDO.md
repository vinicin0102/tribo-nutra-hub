# ✅ SQL Corrigido - Execute Esta Versão

## 🔧 Correções Aplicadas:

1. ✅ **Melhor tratamento de NULL** para email e role
2. ✅ **Verificação de existência da tabela subscriptions** antes de usar
3. ✅ **Múltiplas permissões** (authenticated, anon, service_role)
4. ✅ **Conversão de UUID para TEXT** no retorno JSON
5. ✅ **Drop de todas as variações** da função antes de criar

---

## 🚀 EXECUTE ESTE SQL:

### Arquivo: `criar-funcao-change-plan-admin-v2.sql`

1. **Abra o Supabase Dashboard:**
   - Acesse: https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em **"SQL Editor"**

2. **Abra o arquivo SQL:**
   - No seu computador, abra: **`criar-funcao-change-plan-admin-v2.sql`**

3. **Copie TODO o conteúdo:**
   - Pressione **Ctrl+A** (ou Cmd+A no Mac)
   - Pressione **Ctrl+C** (ou Cmd+C no Mac)

4. **Cole no SQL Editor:**
   - Cole o conteúdo no Supabase SQL Editor
   - Clique em **"RUN"** (ou Ctrl+Enter)

5. **Verifique o resultado:**
   - Deve aparecer uma tabela mostrando a função criada
   - Deve mostrar `function_name = 'change_user_plan_admin'`
   - Deve mostrar `security_definer = true`

---

## ✅ VERIFICAÇÃO:

Execute este SQL para verificar:

```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments
FROM pg_proc
WHERE proname = 'change_user_plan_admin';
```

**Resultado esperado:**
- Uma linha com `function_name = 'change_user_plan_admin'`
- `security_definer = true`
- `arguments = {p_user_id,p_plan,p_expires_at}`

---

## 🧪 TESTE A FUNÇÃO:

Execute este SQL (substitua `USER_ID_AQUI` pelo user_id real de um usuário):

```sql
-- Primeiro, pegue um user_id
SELECT user_id, username, subscription_plan 
FROM profiles 
LIMIT 1;

-- Depois, teste a função (substitua USER_ID_AQUI)
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
  "plan": "diamond",
  "expires_at": null
}
```

---

## 🔄 DEPOIS DE EXECUTAR:

1. **Aguarde 1-2 minutos** para o deploy
2. **Limpe o cache:**
   - Pressione **Ctrl+Shift+R** (ou Cmd+Shift+R no Mac)
3. **Faça logout e login novamente**
4. **Teste a alteração de plano**

---

## ❌ Se Ainda Der Erro:

### Verifique o Console (F12):
Procure por:
- **"🔄 [UserManagement] handleChangePlan chamado"**
- **"❌ ERRO AO ALTERAR PLANO (RPC)"**
- Veja a mensagem de erro completa

### Verifique se a Função Existe:
```sql
SELECT proname FROM pg_proc WHERE proname = 'change_user_plan_admin';
```

**Deve retornar uma linha.**

---

**🚀 Execute o SQL `criar-funcao-change-plan-admin-v2.sql` e teste novamente!**

