# 📋 Guia de Execução de Scripts SQL

## ⚠️ IMPORTANTE

**NUNCA execute arquivos `.tsx`, `.ts`, `.js` ou `.jsx` no SQL Editor!**

O SQL Editor do Supabase **SOMENTE** aceita código SQL.

## ✅ Arquivos SQL para Executar

Execute **APENAS** estes arquivos no SQL Editor do Supabase:

### 1. Migração Inicial (se ainda não executou)
📄 **Arquivo:** `supabase/migrations/20251130185609_10e73531-fe4a-4518-90ae-9a6508ff1093.sql`
- Cria todas as tabelas básicas
- Cria triggers e funções iniciais
- **Execute PRIMEIRO** se o banco está vazio

### 2. Sistema de Suporte
📄 **Arquivo:** `apply-support-migration.sql`
- Adiciona colunas: `role`, `is_support_post`, `is_banned`
- Cria tabela `support_chat`
- Cria políticas RLS para suporte
- **Execute DEPOIS** da migração inicial

### 3. Correção de Políticas RLS (se houver erro de recursão)
📄 **Arquivo:** `fix-rls-policies.sql`
- Corrige recursão infinita nas políticas
- Cria função `is_support_user()`
- **Execute se** estiver vendo erro de recursão

### 4. Sistema de Ranking e Premiação
📄 **Arquivo:** `ranking-and-rewards-migration.sql`
- Adiciona coluna `tier` na tabela `profiles`
- Cria tabelas `rewards` e `redemptions`
- Atualiza sistema de pontos (2 por post, 1 por curtida/comentário)
- **Execute DEPOIS** das migrações anteriores

### 5. Configuração do Storage (Bucket de Imagens)
📄 **Arquivo:** `setup-storage-bucket.sql`
- Cria bucket `images` no Storage
- Configura políticas de acesso
- **Execute para** habilitar upload de imagens

### 6. Criar Usuário de Suporte
📄 **Arquivo:** `setup-support-user.sql`
- Cria/atualiza usuário de suporte
- **Execute DEPOIS** de criar o usuário no Dashboard

## 📝 Ordem Recomendada de Execução

Se você está configurando do zero:

1. ✅ `supabase/migrations/20251130185609_10e73531-fe4a-4518-90ae-9a6508ff1093.sql`
2. ✅ `apply-support-migration.sql`
3. ✅ `fix-rls-policies.sql` (se necessário)
4. ✅ `ranking-and-rewards-migration.sql`
5. ✅ `setup-storage-bucket.sql`
6. ✅ `setup-support-user.sql` (após criar usuário no Dashboard)

## 🚫 Arquivos que NÃO devem ser executados no SQL Editor

❌ **NÃO execute estes arquivos no SQL Editor:**
- `src/App.tsx` (TypeScript/React)
- `src/**/*.tsx` (Componentes React)
- `src/**/*.ts` (TypeScript)
- `*.js` (JavaScript)
- `*.mjs` (JavaScript Module)
- Qualquer arquivo que não seja `.sql`

## 🔍 Como Identificar um Arquivo SQL

Arquivos SQL:
- ✅ Terminam com `.sql`
- ✅ Contêm apenas código SQL
- ✅ Começam com comentários SQL (`--`) ou comandos SQL (`CREATE`, `INSERT`, `UPDATE`, etc.)

## 📖 Exemplo de Arquivo SQL Correto

```sql
-- Este é um arquivo SQL correto
CREATE TABLE IF NOT EXISTS public.rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);
```

## 📖 Exemplo de Arquivo que NÃO é SQL

```typescript
// ❌ Este é TypeScript, NÃO execute no SQL Editor!
import { Toaster } from "@/components/ui/toaster";
export default function App() { ... }
```

## 🆘 Se Você Viu o Erro

Se você viu o erro:
```
ERROR: 42601: syntax error at or near "{"
```

Isso significa que você tentou executar um arquivo que não é SQL. 

**Solução:**
1. Pare de executar
2. Abra um arquivo `.sql` (não `.tsx` ou `.ts`)
3. Copie apenas o conteúdo SQL
4. Execute no SQL Editor

## ✅ Verificação

Antes de executar, verifique:
- [ ] O arquivo termina com `.sql`?
- [ ] O conteúdo começa com SQL (CREATE, INSERT, etc.)?
- [ ] Não há imports ou exports?
- [ ] Não há código TypeScript/JavaScript?

Se todas as respostas forem SIM, pode executar! 🎉

