# ✅ TESTE ESTE SQL - VERSÃO V2 MAIS ROBUSTA

## 🎯 O que mudou na V2:

1. ✅ **Sintaxe mais simples** - Usa subqueries diretas ao invés de EXISTS
2. ✅ **Verificação de admin** - Mostra se você é admin ou não
3. ✅ **Mensagens mais claras** - Mostra exatamente o que aconteceu

---

## 🚀 EXECUTE ESTE SQL:

### Arquivo: `SOLUCAO-SIMPLES-ALTERAR-PLANO-V2.sql`

1. **Abra o Supabase Dashboard:**
   - https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em **"SQL Editor"**

2. **Abra o arquivo:** `SOLUCAO-SIMPLES-ALTERAR-PLANO-V2.sql`

3. **Copie TODO o conteúdo** (Ctrl+A, Ctrl+C)

4. **Cole no SQL Editor** (Ctrl+V)

5. **Execute** (RUN ou Ctrl+Enter)

6. **Verifique os resultados:**
   - **Passo 1:** Mostra todas as policies de UPDATE existentes
   - **Passo 4:** Deve mostrar **"✅ Policy criada com sucesso!"**
   - **Passo 5:** Deve mostrar **"✅ É admin"** para seu email

---

## ✅ O QUE ESPERAR:

### Resultado do Passo 4:
```
status                          | policyname                              | cmd    | roles
--------------------------------|------------------------------------------|--------|--------
✅ Policy criada com sucesso!   | Admins can update subscription plan     | UPDATE | {authenticated}
```

### Resultado do Passo 5:
```
info                | email              | role  | status_admin
--------------------|--------------------|-------|------------------
Verificação de Admin| admin@gmail.com    | admin | ✅ É admin (email)
```

---

## ⚠️ SE DER ERRO:

### Erro: "relation does not exist"
- **Solução:** A tabela `profiles` não existe. Execute primeiro os scripts de criação de tabelas.

### Erro: "permission denied"
- **Solução:** Você não tem permissão. Certifique-se de estar logado como admin no Supabase.

### Erro: "policy already exists"
- **Solução:** Isso é normal! A policy já existe. O `DROP POLICY IF EXISTS` deve ter removido, mas se não funcionou, está tudo bem.

---

## 🔍 SE AINDA NÃO FUNCIONAR:

### 1. Verifique se a policy foi criada:
```sql
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update subscription plan';
```

**Deve retornar uma linha.**

### 2. Verifique se você é admin:
```sql
SELECT 
  u.email,
  p.role
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';
```

**Deve mostrar `role = 'admin'` ou `email = 'admin@gmail.com'`**

### 3. Teste manualmente:
```sql
-- Substitua USER_ID_AQUI pelo user_id de um usuário de teste
UPDATE profiles
SET subscription_plan = 'diamond'
WHERE user_id = 'USER_ID_AQUI';
```

**Se funcionar, a policy está correta!**

---

## 🎯 DEPOIS DE EXECUTAR:

1. **Aguarde 1-2 minutos** para o deploy
2. **Limpe o cache:** Ctrl+Shift+R (ou Cmd+Shift+R)
3. **Faça logout e login novamente**
4. **Teste a alteração de plano no app**

---

**🚀 Execute o SQL `SOLUCAO-SIMPLES-ALTERAR-PLANO-V2.sql` e me diga o que apareceu nos resultados!**

