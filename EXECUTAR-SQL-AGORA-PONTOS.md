# ⚡ EXECUTAR SQL AGORA - Corrigir Atualização de Pontos

## 🚨 PROBLEMA:

Os pontos não estão salvando porque **falta a RLS policy** que permite admins atualizarem outros perfis.

---

## ✅ SOLUÇÃO RÁPIDA:

### **1. Abra o Supabase SQL Editor:**
- Vá para: https://supabase.com/dashboard
- Selecione seu projeto
- Clique em **"SQL Editor"** (menu lateral)

### **2. Cole e Execute este código:**

```sql
-- Criar policy para admin atualizar qualquer perfil
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

### **3. Clique em "RUN" ou pressione Ctrl+Enter**

### **4. Verifique se funcionou:**

Execute esta query:

```sql
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'profiles' 
AND policyname = 'Admins can update any profile';
```

**Deve retornar uma linha!**

---

## 🧪 TESTE:

1. **Limpe o cache** (Ctrl+Shift+R)
2. **Acesse o painel admin**
3. **Tente alterar pontos** de um usuário
4. **Abra o console** (F12) e veja os logs:
   - Deve aparecer "✅ Pontos atualizados com sucesso!"
   - Se aparecer erro de permissão, a policy não foi criada corretamente

---

## 🔍 Se Ainda Não Funcionar:

### Verifique o Console (F12):

Procure por:
- **"❌ ERRO AO ATUALIZAR PONTOS"** - Veja o código do erro
- **"Erro de permissão"** - A policy não foi criada
- **"Nenhum dado retornado"** - Problema de RLS

### Verifique se é Admin:

```sql
SELECT user_id, email, role 
FROM profiles 
WHERE email = 'admin@gmail.com' OR role = 'admin';
```

Deve retornar sua conta com `role = 'admin'`.

---

## ⚠️ IMPORTANTE:

- Execute o SQL **AGORA** no Supabase
- Sem essa policy, **não vai funcionar**
- A policy permite que admins atualizem qualquer perfil

---

**🚀 Execute o SQL acima no Supabase SQL Editor AGORA!**

