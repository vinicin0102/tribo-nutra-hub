# 🎯 COMO EXECUTAR O SQL - Guia Visual

## ❌ Você está vendo este erro:
**"Erro de permissão. Execute o script criar-policy-admin-update-profiles.sql no Supabase SQL Editor."**

---

## ✅ SOLUÇÃO (3 passos):

### **PASSO 1: Abrir Supabase**
1. Abra uma **nova aba** no Chrome
2. Vá para: **https://supabase.com/dashboard**
3. Faça login
4. Selecione seu projeto

### **PASSO 2: Abrir SQL Editor**
1. No menu lateral esquerdo, procure por **"SQL Editor"**
2. Clique nele
3. Você verá um campo de texto grande

### **PASSO 3: Copiar, Colar e Executar**

**Copie TODO este código:**

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

**Depois:**
1. Cole no campo de texto do SQL Editor
2. Clique no botão **"RUN"** (geralmente no canto inferior direito)
3. Ou pressione **Ctrl+Enter** (Windows) ou **Cmd+Enter** (Mac)

---

## ✅ Verificar se Funcionou:

Execute esta query:

```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

**Deve retornar uma linha!**

---

## 🧪 TESTAR:

1. **Volte para a aba do app** (sociedadenutra.com)
2. **Feche o modal** de "Alterar Pontuação" (clique em X ou Cancelar)
3. **Limpe o cache:** Pressione **Ctrl+Shift+R** (ou **Cmd+Shift+R** no Mac)
4. **Tente novamente:**
   - Clique em "Alterar pontuação" em um usuário
   - Digite os pontos
   - Clique em "Salvar"
5. **Deve funcionar agora!** ✅

---

## 🔍 Se Ainda Aparecer Erro:

### Verifique o Console (F12):
1. Pressione **F12** no navegador
2. Vá na aba **"Console"**
3. Procure por:
   - **"✅ Pontos atualizados com sucesso!"** = Funcionou!
   - **"❌ ERRO AO ATUALIZAR PONTOS"** = Veja o código do erro

### Verifique se a Policy Foi Criada:
No Supabase SQL Editor, execute:

```sql
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

Se **não retornar nada**, a policy não foi criada. Tente executar o SQL novamente.

---

## ⚠️ IMPORTANTE:

- **Execute o SQL no Supabase** - É obrigatório!
- **Aguarde alguns segundos** após executar
- **Limpe o cache** do navegador antes de testar
- **Verifique o console** (F12) para ver os logs

---

**🚀 Execute o SQL acima no Supabase SQL Editor AGORA!**

