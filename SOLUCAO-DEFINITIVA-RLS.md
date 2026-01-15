# ✅ Solução Definitiva: RLS Policy para Atualizar Pontos

## 🔍 Problema:

O erro persiste mesmo após executar o SQL. Isso pode ser porque:

1. **A policy não foi criada corretamente**
2. **Há conflito com outras policies**
3. **A verificação de admin não está funcionando**

---

## ✅ SOLUÇÃO DEFINITIVA:

### **Execute este SQL no Supabase SQL Editor:**

```sql
-- 1. Ver policies existentes
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'profiles' AND cmd = 'UPDATE';

-- 2. Dropar TODAS as policies de UPDATE
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;

-- 3. Recriar policy para usuários atualizarem seu próprio perfil
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4. Criar policy para admin (versão simplificada)
CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
)
WITH CHECK (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  (SELECT role FROM profiles WHERE user_id = auth.uid()) = 'admin'
);

-- 5. Verificar se foram criadas
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'profiles' AND cmd = 'UPDATE';
```

---

## 🧪 TESTAR SE FUNCIONOU:

### 1. Verifique se você é admin:

Execute no Supabase SQL Editor:

```sql
SELECT 
  u.id as user_id,
  u.email,
  p.role,
  p.points
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';
```

**Deve mostrar `role = 'admin'`**

### 2. Teste manual no SQL Editor:

```sql
-- Substitua USER_ID_AQUI pelo user_id de um usuário de teste
UPDATE profiles
SET points = 99999
WHERE user_id = 'USER_ID_AQUI'
RETURNING user_id, username, points;
```

**Se funcionar no SQL Editor, deve funcionar no app também.**

### 3. Teste no App:

1. Limpe o cache (Ctrl+Shift+R)
2. Faça logout e login novamente
3. Tente alterar pontos
4. Abra o console (F12) e veja os logs

---

## 🔍 Se Ainda Não Funcionar:

### Verifique o Console (F12):

Procure por:
- **"❌ ERRO AO ATUALIZAR PONTOS"**
- Veja o **código do erro** (ex: 42501 = permissão negada)
- Veja a **mensagem completa**

### Verifique se a Policy Foi Criada:

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

### Verifique se Você é Admin:

```sql
SELECT 
  p.user_id,
  p.role,
  u.email
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';
```

**Deve mostrar `role = 'admin'`**

---

## ⚠️ ALTERNATIVA: Desabilitar RLS Temporariamente (APENAS PARA TESTE)

**⚠️ ATENÇÃO: Isso remove a segurança. Use apenas para testar!**

```sql
-- Desabilitar RLS temporariamente (APENAS PARA TESTE)
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Testar atualização
UPDATE profiles SET points = 99999 WHERE user_id = 'USER_ID_AQUI';

-- Reabilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

**Se funcionar com RLS desabilitado, o problema é definitivamente a policy.**

---

**🚀 Execute o SQL acima no Supabase SQL Editor e me diga o que aparece no console (F12)!**

