# Instruções para Aplicar a Migração de Suporte

## ⚠️ Erro Atual

Se você está vendo o erro:
```
Could not find the 'is_support_post' column of 'posts' in the schema cache
```

Isso significa que a migração do sistema de suporte ainda não foi executada no banco de dados.

## ✅ Solução Rápida

### Passo 1: Acessar o SQL Editor do Supabase

1. Acesse o [Supabase Dashboard](https://app.supabase.com)
2. Selecione seu projeto
3. Vá em **SQL Editor** (no menu lateral)

### Passo 2: Executar a Migração

1. No SQL Editor, clique em **New Query**
2. Abra o arquivo `apply-support-migration.sql` deste projeto
3. Copie **TODO** o conteúdo do arquivo
4. Cole no SQL Editor
5. Clique em **Run** (ou pressione Ctrl+Enter / Cmd+Enter)

### Passo 3: Verificar se Funcionou

Após executar, você deve ver uma tabela com checkmarks (✓) indicando que tudo foi criado:

```
status              | check_role              | check_support_post        | check_banned              | check_support_chat
--------------------|-------------------------|---------------------------|---------------------------|-------------------
Migração concluída! | ✓ Coluna role em profiles | ✓ Coluna is_support_post em posts | ✓ Coluna is_banned em profiles | ✓ Tabela support_chat
```

### Passo 4: Recarregar a Aplicação

1. Volte para sua aplicação (`http://localhost:8080`)
2. Recarregue a página (F5 ou Ctrl+R)
3. O erro deve desaparecer

## 📋 O que a Migração Faz

A migração adiciona:

1. ✅ Coluna `role` na tabela `profiles` (user, support, admin)
2. ✅ Coluna `is_support_post` na tabela `posts` (para destacar posts do suporte)
3. ✅ Coluna `is_banned` na tabela `profiles` (para banir usuários)
4. ✅ Tabela `support_chat` (para chat de suporte)
5. ✅ Políticas RLS (Row Level Security) para permissões de suporte
6. ✅ Índices para melhor performance

## 🔍 Verificação Manual

Se quiser verificar manualmente, execute:

```sql
-- Verificar colunas da tabela posts
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'posts' 
AND column_name IN ('is_support_post');

-- Verificar colunas da tabela profiles
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN ('role', 'is_banned');

-- Verificar se a tabela support_chat existe
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'support_chat';
```

## ❌ Se Ainda Não Funcionar

1. **Verifique se você está no projeto correto** no Supabase Dashboard
2. **Verifique se há erros** no resultado da execução do SQL
3. **Tente executar cada seção separadamente** se houver erro em alguma parte
4. **Verifique os logs** no Supabase Dashboard > Logs

## 📝 Notas Importantes

- A migração é **idempotente** (pode ser executada múltiplas vezes sem problemas)
- Ela verifica se as colunas/tabelas já existem antes de criar
- Não apaga dados existentes
- É segura para executar em produção

