# 🚨 EXECUTE ESTE SQL AGORA - Erro de Permissão

## ⚠️ O erro persiste porque o SQL ainda não foi executado!

---

## 📋 PASSO A PASSO RÁPIDO:

### 1. Abra o Supabase Dashboard:
- Acesse: https://supabase.com/dashboard
- Selecione seu projeto
- Clique em **"SQL Editor"** no menu lateral

### 2. Copie e Cole este SQL Completo:

```sql
-- =====================================================
-- FIX RLS DEFINITIVO - Atualizar Pontos Admin
-- =====================================================

-- PASSO 1: Ver todas as policies de UPDATE atuais
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE';

-- PASSO 2: Dropar TODAS as policies de UPDATE
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;
DROP POLICY IF EXISTS "Support can update profiles" ON profiles;
DROP POLICY IF EXISTS "Admin can update profiles" ON profiles;

-- PASSO 3: Recriar policy para usuários atualizarem seu próprio perfil
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- PASSO 4: Criar policy para admin
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  -- Verificar email diretamente
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  -- Verificar role admin
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  -- Mesma verificação para WITH CHECK
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND email = 'admin@gmail.com'
  )
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);

-- PASSO 5: Verificar se foram criadas corretamente
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
ORDER BY policyname;

-- PASSO 6: Testar se você é admin
SELECT 
  u.id as user_id,
  u.email,
  p.role,
  p.points
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';
```

### 3. Clique em **"RUN"** (ou pressione Ctrl+Enter)

### 4. Verifique o Resultado:
- **PASSO 5** deve mostrar 2 policies:
  - `Users can update own profile`
  - `Admins can update any profile`
- **PASSO 6** deve mostrar seu email com `role = 'admin'`

---

## ✅ DEPOIS DE EXECUTAR:

1. **Limpe o cache do navegador:**
   - Pressione **Ctrl+Shift+R** (hard refresh)

2. **Faça logout e login novamente**

3. **Teste o botão "Salvar" novamente**

---

## 🔍 SE AINDA NÃO FUNCIONAR:

### Verifique o Console (F12):
Procure por:
- **"❌ ERRO AO ATUALIZAR PONTOS"**
- Veja o **código do erro** (ex: 42501 = permissão negada)
- Veja a **mensagem completa**

### Verifique se a Policy Foi Criada:

Execute no SQL Editor:
```sql
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

**Deve retornar uma linha com `cmd = 'UPDATE'`**

---

## ⚠️ IMPORTANTE:

**Este SQL PRECISA ser executado no Supabase SQL Editor!**

Sem executar este SQL, o botão "Salvar" **NÃO VAI FUNCIONAR** porque o banco de dados está bloqueando a atualização por falta de permissão (RLS policy).

---

**🚀 Execute o SQL acima e me diga o resultado!**

