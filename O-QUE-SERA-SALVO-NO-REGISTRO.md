# 📋 O QUE SERÁ SALVO NO REGISTRO - DOCUMENTAÇÃO COMPLETA

## ✅ DADOS COLETADOS NO FORMULÁRIO DE REGISTRO

Quando um usuário se cadastra, os seguintes dados são coletados:

| Campo no Formulário | Tipo | Obrigatório | Validação |
|---------------------|------|-------------|-----------|
| **Email** | email | ✅ Sim | Formato de email válido |
| **Senha** | password | ✅ Sim | Mínimo 6 caracteres |
| **Nome Completo** | text | ✅ Sim | Não pode estar vazio |
| **Nome de Usuário** | text | ✅ Sim | Não pode estar vazio |
| **CPF** | text | ✅ Sim | Formato: 000.000.000-00, validado |
| **Data de Nascimento** | date | ✅ Sim | Mínimo 18 anos |
| **Telefone** | text | ✅ Sim | Formato: (00) 00000-0000 |

---

## 💾 ONDE OS DADOS SÃO SALVOS

### **1. Tabela: `auth.users` (Supabase Auth)**

**O que é salvo:**
- ✅ `email` - Email do usuário
- ✅ `password` - Senha (criptografada pelo Supabase)
- ✅ `raw_user_meta_data` - JSON com todos os dados do formulário:
  ```json
  {
    "username": "nomeusuario",
    "full_name": "Nome Completo",
    "cpf": "12345678901",  // CPF limpo (sem pontos/traços)
    "data_nascimento": "2000-01-01",  // Formato YYYY-MM-DD
    "telefone": "11987654321"  // Telefone limpo (sem formatação)
  }
  ```

**Quando é salvo:**
- Imediatamente quando o usuário clica em "Criar conta"
- Antes mesmo do email ser confirmado

---

### **2. Tabela: `public.profiles` (Perfil do Usuário)**

**O que é salvo automaticamente pelo trigger `on_auth_user_created`:**

| Coluna | Valor | Fonte |
|--------|-------|-------|
| `user_id` | UUID do usuário | `auth.users.id` |
| `username` | Nome de usuário | `raw_user_meta_data->>'username'` ou email |
| `full_name` | Nome completo | `raw_user_meta_data->>'full_name'` |
| `email` | Email | `auth.users.email` |
| `cpf` | CPF (apenas números) | `raw_user_meta_data->>'cpf'` |
| `data_nascimento` | Data de nascimento | `raw_user_meta_data->>'data_nascimento'` (convertido para DATE) |
| `telefone` | Telefone (apenas números) | `raw_user_meta_data->>'telefone'` |
| `points` | Pontos iniciais | `0` (padrão) |
| `created_at` | Data de criação | `NOW()` |
| `updated_at` | Data de atualização | `NOW()` |

**Quando é salvo:**
- Automaticamente quando um novo usuário é criado em `auth.users`
- Via trigger `on_auth_user_created` que executa a função `handle_new_user()`
- Mesmo se o email ainda não foi confirmado

---

## 🔄 FLUXO COMPLETO DE REGISTRO

```
1. Usuário preenche formulário
   ↓
2. Validações no frontend (Auth.tsx)
   - CPF válido
   - Idade mínima 18 anos
   - Campos obrigatórios
   ↓
3. Dados são enviados para AuthContext.signUp()
   ↓
4. AuthContext limpa formatação:
   - CPF: Remove pontos e traços → "12345678901"
   - Telefone: Remove parênteses, traços e espaços → "11987654321"
   ↓
5. Supabase Auth cria usuário em auth.users
   - Salva email e senha (criptografada)
   - Salva dados em raw_user_meta_data
   ↓
6. Trigger on_auth_user_created é executado
   ↓
7. Função handle_new_user() cria perfil em public.profiles
   - Copia todos os dados de raw_user_meta_data
   - Salva email de auth.users.email
   ↓
8. ✅ Perfil criado com TODOS os dados!
```

---

## 📊 ESTRUTURA DAS TABELAS

### **Tabela `auth.users` (gerenciada pelo Supabase)**

```sql
auth.users
├── id (UUID) - ID único do usuário
├── email (TEXT) - Email do usuário
├── encrypted_password (TEXT) - Senha criptografada
├── raw_user_meta_data (JSONB) - Dados do formulário:
│   ├── username
│   ├── full_name
│   ├── cpf
│   ├── data_nascimento
│   └── telefone
├── created_at (TIMESTAMP)
└── email_confirmed_at (TIMESTAMP)
```

### **Tabela `public.profiles` (nossa tabela)**

```sql
public.profiles
├── id (UUID) - ID único do perfil
├── user_id (UUID) - Referência para auth.users.id
├── username (TEXT) - Nome de usuário
├── full_name (TEXT) - Nome completo
├── email (TEXT) - Email (cópia de auth.users.email)
├── cpf (TEXT) - CPF (apenas números)
├── data_nascimento (DATE) - Data de nascimento
├── telefone (TEXT) - Telefone (apenas números)
├── avatar_url (TEXT) - URL do avatar (opcional)
├── bio (TEXT) - Biografia (opcional)
├── points (INTEGER) - Pontos do usuário (padrão: 0)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

---

## ✅ GARANTIAS

### **Todos os dados serão salvos porque:**

1. ✅ **Formulário obrigatório** - Todos os campos são `required` no HTML
2. ✅ **Validação no frontend** - Validações antes de enviar
3. ✅ **Dados enviados corretamente** - AuthContext envia todos os campos
4. ✅ **Trigger automático** - `on_auth_user_created` executa automaticamente
5. ✅ **Função robusta** - `handle_new_user()` tem tratamento de erros
6. ✅ **Colunas existem** - Todas as colunas foram criadas nas migrations

---

## 🔍 COMO VERIFICAR SE ESTÁ FUNCIONANDO

### **1. Verificar se o trigger existe:**

```sql
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

### **2. Verificar se a função existe:**

```sql
SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_name = 'handle_new_user';
```

### **3. Testar registro:**

1. Criar um novo usuário
2. Verificar em `auth.users`:
   ```sql
   SELECT id, email, raw_user_meta_data
   FROM auth.users
   ORDER BY created_at DESC
   LIMIT 1;
   ```
3. Verificar em `public.profiles`:
   ```sql
   SELECT user_id, username, full_name, email, cpf, telefone, data_nascimento
   FROM public.profiles
   ORDER BY created_at DESC
   LIMIT 1;
   ```

---

## 📝 RESUMO FINAL

### **O que será salvo:**

✅ **Email** → `auth.users.email` + `public.profiles.email`  
✅ **Senha** → `auth.users.encrypted_password` (criptografada)  
✅ **Nome de Usuário** → `public.profiles.username`  
✅ **Nome Completo** → `public.profiles.full_name`  
✅ **CPF** → `auth.users.raw_user_meta_data->>'cpf'` + `public.profiles.cpf`  
✅ **Data de Nascimento** → `auth.users.raw_user_meta_data->>'data_nascimento'` + `public.profiles.data_nascimento`  
✅ **Telefone** → `auth.users.raw_user_meta_data->>'telefone'` + `public.profiles.telefone`  

### **Onde será salvo:**

1. **`auth.users`** - Tabela do Supabase Auth (gerenciada automaticamente)
2. **`public.profiles`** - Tabela de perfis (criada pelo trigger)

### **Quando será salvo:**

- ✅ Imediatamente ao clicar em "Criar conta"
- ✅ Antes mesmo de confirmar o email
- ✅ Automaticamente via trigger

---

## ⚠️ IMPORTANTE

**A partir de agora, TODOS os novos registros terão TODOS os dados salvos corretamente!**

A função `handle_new_user()` foi atualizada para salvar:
- ✅ Email
- ✅ CPF
- ✅ Telefone
- ✅ Data de nascimento
- ✅ Nome completo
- ✅ Nome de usuário

**Tudo será salvo automaticamente quando o usuário se cadastrar!** 🎉

