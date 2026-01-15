# ✅ Solução Definitiva: Função RPC para Atualizar Pontos

## 🔍 Problema Identificado:

O erro de permissão persiste porque:
1. **RLS policies são complexas** e podem ter conflitos
2. **UPDATE direto na tabela** é bloqueado pela RLS
3. **Verificação de admin** pode não estar funcionando corretamente

---

## ✅ SOLUÇÃO: Função RPC com SECURITY DEFINER

Criamos uma função RPC (`update_user_points_admin`) que:
- ✅ Executa com **privilégios elevados** (SECURITY DEFINER)
- ✅ **Ignora as RLS policies** automaticamente
- ✅ **Valida se o usuário é admin** antes de executar
- ✅ Retorna JSON com sucesso/erro

---

## 📋 PASSO A PASSO:

### 1. Execute o SQL no Supabase SQL Editor:

**Arquivo:** `criar-funcao-update-points-admin.sql`

1. Abra o Supabase Dashboard
2. Vá em **SQL Editor**
3. Copie todo o conteúdo de `criar-funcao-update-points-admin.sql`
4. Cole no SQL Editor
5. Clique em **RUN** (ou Ctrl+Enter)

### 2. Verifique se a função foi criada:

Execute este SQL:
```sql
SELECT 
  proname as function_name,
  prosecdef as security_definer,
  proargnames as arguments
FROM pg_proc
WHERE proname = 'update_user_points_admin';
```

**Deve retornar uma linha com:**
- `function_name = 'update_user_points_admin'`
- `security_definer = true`

### 3. Aguarde o deploy do código:

O código já foi atualizado para usar a função RPC. Aguarde alguns minutos para o Vercel fazer o deploy.

### 4. Limpe o cache e teste:

1. **Limpe o cache do navegador:**
   - Pressione **Ctrl+Shift+R** (hard refresh)

2. **Faça logout e login novamente**

3. **Teste o botão "Salvar"**

---

## 🔍 Como Funciona:

### Antes (UPDATE direto - bloqueado por RLS):
```typescript
const { data, error } = await supabase
  .from('profiles')
  .update({ points: points })
  .eq('user_id', userId);
// ❌ Bloqueado pela RLS policy
```

### Depois (Função RPC - ignora RLS):
```typescript
const { data, error } = await supabase.rpc('update_user_points_admin', {
  p_user_id: userId,
  p_points: points
});
// ✅ Funciona porque executa com SECURITY DEFINER
```

---

## 🧪 Testar a Função Manualmente:

Execute no Supabase SQL Editor (substitua `USER_ID_AQUI` pelo user_id de um usuário de teste):

```sql
SELECT update_user_points_admin(
  'USER_ID_AQUI'::UUID,
  99999
);
```

**Deve retornar:**
```json
{
  "success": true,
  "message": "Pontos atualizados com sucesso",
  "user_id": "USER_ID_AQUI",
  "points": 99999
}
```

---

## ⚠️ Se Ainda Não Funcionar:

### 1. Verifique se a função existe:
```sql
SELECT proname FROM pg_proc WHERE proname = 'update_user_points_admin';
```

### 2. Verifique se você é admin:
```sql
SELECT 
  u.email,
  p.role
FROM auth.users u
LEFT JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'admin@gmail.com' OR u.email = 'vv9250400@gmail.com';
```

### 3. Verifique o console (F12):
Procure por:
- **"✅ Pontos atualizados com sucesso via RPC"**
- **"❌ Função RPC retornou erro"**
- **"❌ ERRO AO ATUALIZAR PONTOS (RPC)"**

---

## 🎯 Vantagens desta Solução:

1. ✅ **Não depende de RLS policies** - executa com privilégios elevados
2. ✅ **Validação de admin** dentro da função
3. ✅ **Retorna JSON estruturado** com sucesso/erro
4. ✅ **Mais seguro** - apenas admins podem executar
5. ✅ **Mais confiável** - não depende de políticas complexas

---

**🚀 Execute o SQL `criar-funcao-update-points-admin.sql` e teste novamente!**

