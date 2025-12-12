# ⚡ EXECUTAR AGORA - vv9250400@gmail.com

## 🎯 O que fazer:

### 1. Abra o Supabase SQL Editor
- Vá para: https://supabase.com/dashboard
- Clique no seu projeto
- No menu lateral, clique em **"SQL Editor"**

### 2. Cole este código:

```sql
-- Conceder 70.000 pontos e admin para vv9250400@gmail.com
INSERT INTO profiles (
  user_id,
  username,
  email,
  points,
  role,
  subscription_plan,
  created_at,
  updated_at
)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'username', 'vv9250400'),
  'vv9250400@gmail.com',
  70000,
  'admin',
  'diamond',
  NOW(),
  NOW()
FROM auth.users u
WHERE u.email = 'vv9250400@gmail.com'
ON CONFLICT (user_id) DO UPDATE
SET 
  points = 70000,
  role = 'admin',
  subscription_plan = 'diamond',
  email = 'vv9250400@gmail.com',
  updated_at = NOW();
```

### 3. Clique em "RUN" ou pressione Ctrl+Enter

### 4. Verifique o resultado:

Execute esta query para ver se funcionou:

```sql
SELECT 
  p.user_id,
  p.username,
  p.email,
  p.points,
  p.role,
  p.subscription_plan
FROM profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'vv9250400@gmail.com';
```

---

## ✅ Deve mostrar:

- **points**: 70000
- **role**: admin
- **subscription_plan**: diamond

---

## ⚠️ Se der erro:

### Erro: "relation auth.users does not exist"
- Use apenas a parte do `INSERT INTO profiles` sem o `SELECT FROM auth.users`
- Ou me avise que vou criar uma versão alternativa

### Erro: "column user_id does not exist"
- Me avise que vou verificar a estrutura da tabela

### Erro: "permission denied"
- Verifique se você tem permissão para executar SQL no Supabase

---

## 📋 Depois de executar:

1. O usuário precisa **fazer logout e login novamente**
2. Limpar cache do navegador (Ctrl+Shift+R)
3. Deve aparecer "Painel Admin" no menu
4. Deve ter 70.000 pontos

---

**🚀 Execute o código acima no Supabase SQL Editor agora!**

