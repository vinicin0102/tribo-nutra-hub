# Onde estão sendo salvos os dados de cadastro

## Situação Atual:

### ✅ **Email**
- **Localização**: Tabela `auth.users` (coluna `email`)
- **Status**: ✅ Está sendo salvo corretamente

### ⚠️ **CPF**
- **Localização**: `auth.users.raw_user_meta_data->>'cpf'` (metadados do Supabase Auth)
- **Status**: ⚠️ Está sendo enviado no cadastro, mas NÃO está na tabela `profiles`
- **Problema**: A função `handle_new_user()` não salva o CPF na tabela `profiles`

### ⚠️ **Data de Nascimento**
- **Localização**: `auth.users.raw_user_meta_data->>'data_nascimento'` (metadados do Supabase Auth)
- **Status**: ⚠️ Está sendo enviado no cadastro, mas NÃO está na tabela `profiles`
- **Problema**: A função `handle_new_user()` não salva a data de nascimento na tabela `profiles`

### ❌ **Telefone**
- **Status**: ❌ NÃO está sendo coletado no formulário de cadastro
- **Problema**: Não há campo de telefone no `Auth.tsx`

## Como acessar os dados atualmente:

### Email:
```sql
SELECT email FROM auth.users WHERE id = 'USER_ID';
```

### CPF e Data de Nascimento:
```sql
SELECT 
  raw_user_meta_data->>'cpf' as cpf,
  raw_user_meta_data->>'data_nascimento' as data_nascimento
FROM auth.users 
WHERE id = 'USER_ID';
```

## Recomendação:

Para facilitar o acesso e consulta, recomendo:
1. Adicionar colunas `cpf`, `data_nascimento` e `telefone` na tabela `profiles`
2. Atualizar a função `handle_new_user()` para salvar esses dados
3. Adicionar campo de telefone no formulário de cadastro (se necessário)

