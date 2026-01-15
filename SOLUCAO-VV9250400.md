# ✅ Solução: vv9250400@gmail.com não está com admin/pontos

## 🔍 Problema Identificado:

O `useIsAdmin` só verificava o email `admin@gmail.com`, não verificava o **role** do perfil. Agora foi corrigido!

---

## ✅ Correções Aplicadas:

1. **`useIsAdmin` atualizado** - Agora verifica o role do perfil também
2. **Script SQL criado** - `atualizar-vv9250400-forcado.sql` para forçar atualização

---

## 🚀 Passo a Passo:

### 1. Execute o Script SQL (FORÇADO):

No Supabase SQL Editor, execute:

```sql
-- Atualizar FORÇADAMENTE
UPDATE profiles
SET 
  points = 70000,
  role = 'admin',
  subscription_plan = 'diamond',
  email = 'vv9250400@gmail.com',
  updated_at = NOW()
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email = 'vv9250400@gmail.com'
);

-- Verificar resultado
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

### 2. Verifique o Resultado:

Deve mostrar:
- ✅ **points**: 70000
- ✅ **role**: admin
- ✅ **subscription_plan**: diamond

### 3. Faça Logout e Login:

- **Faça logout** da conta
- **Faça login novamente** com `vv9250400@gmail.com`
- **Limpe o cache** (Ctrl+Shift+R)

### 4. Verifique no App:

- Deve aparecer **"Painel Admin"** no menu (canto superior direito)
- Deve ter **70.000 pontos** no perfil
- Deve conseguir acessar `/support/dashboard`

---

## 🔧 Se Ainda Não Funcionar:

### Verificar se o perfil existe:

Execute no Supabase SQL Editor:

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

### Se não retornar nada:

O perfil não existe. Execute:

```sql
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
WHERE u.email = 'vv9250400@gmail.com';
```

---

## 📋 Checklist:

- [ ] Script SQL executado sem erros
- [ ] Query de verificação mostra: points=70000, role=admin, subscription_plan=diamond
- [ ] Logout e login feito
- [ ] Cache limpo (Ctrl+Shift+R)
- [ ] "Painel Admin" aparece no menu
- [ ] 70.000 pontos aparecem no perfil

---

**✅ O código foi atualizado! Execute o script SQL e faça logout/login novamente!**

