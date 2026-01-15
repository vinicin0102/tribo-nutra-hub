# ⚠️ ATENÇÃO: Execute o Arquivo SQL Correto!

## ❌ Erro Comum:

Você tentou executar um arquivo **TypeScript/JavaScript** no Supabase SQL Editor.

O erro mostra:
```
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
```

Isso é código **TypeScript**, não **SQL**!

---

## ✅ SOLUÇÃO:

### 1. Abra o arquivo SQL correto:

**Arquivo:** `criar-funcao-update-points-admin.sql`

Este arquivo contém apenas código **SQL**, não TypeScript!

### 2. Copie TODO o conteúdo do arquivo SQL:

O arquivo deve começar com:
```sql
-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ATUALIZAR PONTOS (ADMIN)
-- =====================================================
```

**NÃO deve começar com:**
```typescript
import { useQuery...
```

### 3. Cole no Supabase SQL Editor:

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Clique em **"SQL Editor"** no menu lateral
4. **Cole o conteúdo do arquivo SQL** (não o TypeScript!)
5. Clique em **"RUN"** (ou pressione Ctrl+Enter)

---

## 📋 Conteúdo do Arquivo SQL Correto:

O arquivo `criar-funcao-update-points-admin.sql` deve conter algo como:

```sql
-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ATUALIZAR PONTOS (ADMIN)
-- =====================================================

-- Dropar função se já existir
DROP FUNCTION IF EXISTS update_user_points_admin(UUID, INTEGER);

-- Criar função com SECURITY DEFINER
CREATE OR REPLACE FUNCTION update_user_points_admin(
  p_user_id UUID,
  p_points INTEGER
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
...
```

**Se você ver `import`, `export`, `function`, `const`, `await` - isso NÃO é SQL!**

---

## 🔍 Como Identificar:

### ✅ Arquivo SQL (correto):
- Extensão: `.sql`
- Começa com `--` (comentários SQL)
- Contém `CREATE FUNCTION`, `SELECT`, `UPDATE`, etc.
- **NÃO contém** `import`, `export`, `const`, `function`, `await`

### ❌ Arquivo TypeScript/JavaScript (errado):
- Extensão: `.ts`, `.tsx`, `.js`, `.jsx`
- Começa com `import` ou `export`
- Contém `const`, `function`, `async`, `await`
- **NÃO deve ser executado no SQL Editor!**

---

## 🚀 Passo a Passo Correto:

1. **Abra o arquivo:** `criar-funcao-update-points-admin.sql`
2. **Selecione TODO o conteúdo** (Ctrl+A)
3. **Copie** (Ctrl+C)
4. **Abra o Supabase SQL Editor**
5. **Cole** (Ctrl+V)
6. **Execute** (Ctrl+Enter ou clique em RUN)

---

**✅ Execute o arquivo SQL correto e me diga o resultado!**

