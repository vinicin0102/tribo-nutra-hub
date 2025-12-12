# ✅ Solução: Pontos Não Estão Atualizando

## 🔍 Problema Identificado:

Os pontos não estão atualizando porque **a RLS (Row Level Security) policy** só permite que usuários atualizem **seu próprio perfil**, mas não permite que **admins atualizem outros perfis**.

---

## ✅ Solução:

### **Execute este SQL no Supabase SQL Editor:**

```sql
-- 1. Dropar policy existente se houver (para evitar conflito)
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;

-- 2. Criar policy para admin atualizar qualquer perfil
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar se é admin pelo email
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  -- Verificar se tem role admin no perfil
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  -- Mesma verificação para WITH CHECK
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);
```

---

## 📋 Passo a Passo:

### 1. Acesse o Supabase SQL Editor
- Vá para: https://supabase.com/dashboard
- Selecione seu projeto
- Vá em **SQL Editor**

### 2. Execute o Script
- Abra o arquivo: `criar-policy-admin-update-profiles.sql`
- Copie todo o conteúdo
- Cole no SQL Editor
- Clique em **"Run"** ou pressione **Ctrl+Enter**

### 3. Verifique se Funcionou
- Execute esta query:
```sql
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```
- Deve retornar uma linha com `cmd = 'UPDATE'`

### 4. Teste no App
- Limpe o cache (Ctrl+Shift+R)
- Acesse o painel admin
- Tente alterar pontos de um usuário
- Deve funcionar agora!

---

## 🔍 Verificar RLS Policies Atuais:

Se quiser ver todas as policies antes de criar a nova:

```sql
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles'
ORDER BY cmd, policyname;
```

---

## ⚠️ Importante:

- A policy atual `"Users can update own profile"` **não será removida**
- A nova policy **adiciona** permissão para admins
- Ambas as policies funcionarão juntas:
  - Usuários podem atualizar seu próprio perfil
  - Admins podem atualizar qualquer perfil

---

## 🐛 Se Ainda Não Funcionar:

### 1. Verifique o Console do Navegador (F12):
- Procure por logs:
  - "Atualizando pontos: ..."
  - "Perfil existente: ..."
  - "Resposta da atualização de pontos: ..."
- Veja se há erros de permissão (código 42501 ou similar)

### 2. Verifique se é Admin:
- Certifique-se de que está logado com `admin@gmail.com` ou tem `role = 'admin'`
- Execute:
```sql
SELECT user_id, email, role 
FROM profiles 
WHERE email = 'admin@gmail.com' OR role = 'admin';
```

### 3. Teste a Policy Manualmente:
```sql
-- Verificar se você pode atualizar (substitua USER_ID pelo ID de um usuário)
UPDATE profiles 
SET points = 99999 
WHERE user_id = 'USER_ID_AQUI'
RETURNING user_id, username, points;
```

---

**✅ Execute o script SQL `criar-policy-admin-update-profiles.sql` no Supabase SQL Editor!**

