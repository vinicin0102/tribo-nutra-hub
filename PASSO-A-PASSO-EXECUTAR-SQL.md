# 📋 PASSO A PASSO: Executar SQL para Corrigir Atualização de Pontos

## 🎯 Você está vendo este erro:
**"Erro de permissão. Execute o script criar-policy-admin-update-profiles.sql no Supabase SQL Editor."**

Isso significa que falta a **RLS policy** no banco de dados.

---

## ✅ SOLUÇÃO (5 minutos):

### **PASSO 1: Abrir Supabase**
1. Vá para: **https://supabase.com/dashboard**
2. Faça login na sua conta
3. Selecione seu projeto: **"vinicin0102's Project"**

### **PASSO 2: Abrir SQL Editor**
1. No menu lateral esquerdo, clique em **"SQL Editor"**
2. Ou acesse diretamente: https://supabase.com/dashboard/project/[SEU_PROJECT_ID]/sql/new

### **PASSO 3: Copiar o Código SQL**
Copie **TODO** este código:

```sql
DROP POLICY IF EXISTS "Admins can update any profile" ON profiles;

CREATE POLICY "Admins can update any profile"
ON profiles
FOR UPDATE
TO authenticated
USING (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
)
WITH CHECK (
  (SELECT email FROM auth.users WHERE id = auth.uid()) = 'admin@gmail.com'
  OR
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);
```

### **PASSO 4: Colar e Executar**
1. Cole o código no campo de texto do SQL Editor
2. Clique no botão **"RUN"** (ou pressione **Ctrl+Enter** / **Cmd+Enter**)
3. Aguarde alguns segundos

### **PASSO 5: Verificar se Funcionou**
Você deve ver uma mensagem de sucesso ou uma tabela com o resultado.

Execute esta query para confirmar:

```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

**Deve retornar uma linha!**

---

## 🧪 TESTAR NO APP:

1. **Volte para o app** (sociedadenutra.com)
2. **Limpe o cache:**
   - Pressione **Ctrl+Shift+R** (ou **Cmd+Shift+R** no Mac)
3. **Tente alterar pontos novamente:**
   - Clique em "Alterar pontuação" em um usuário
   - Digite os pontos (ex: 7000000)
   - Clique em "Salvar"
4. **Deve funcionar agora!** ✅

---

## 🔍 Se Ainda Não Funcionar:

### Verifique o Console (F12):
1. Abra o console do navegador (F12)
2. Vá na aba **"Console"**
3. Procure por:
   - **"✅ Pontos atualizados com sucesso!"** = Funcionou!
   - **"❌ ERRO AO ATUALIZAR PONTOS"** = Veja o código do erro
   - **"Erro de permissão"** = A policy não foi criada

### Verifique se a Policy Foi Criada:
Execute no Supabase SQL Editor:

```sql
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

Se **não retornar nada**, a policy não foi criada. Tente executar o SQL novamente.

---

## ⚠️ IMPORTANTE:

- **Execute o SQL no Supabase** - Sem isso, não vai funcionar
- **Aguarde alguns segundos** após executar
- **Limpe o cache** do navegador antes de testar
- **Verifique o console** (F12) para ver os logs

---

**🚀 Execute o SQL acima no Supabase SQL Editor AGORA!**

