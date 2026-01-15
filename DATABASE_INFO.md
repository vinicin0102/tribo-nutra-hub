# 📊 Informações do Banco de Dados

## 🌐 Localização do Banco de Dados

Este projeto usa **Supabase** como banco de dados, que é um serviço de banco de dados PostgreSQL hospedado na nuvem.

### 🔑 Identificação do Projeto

- **Project ID:** `yhvhefrknmwqhuinrcfi`
- **URL do Projeto:** `https://yhvhefrknmwqhuinrcfi.supabase.co`

### 📁 Arquivos de Configuração

1. **`supabase/config.toml`**
   - Contém o Project ID do Supabase
   - Project ID: `yhvhefrknmwqhuinrcfi`

2. **`.env`** (arquivo local, não versionado)
   - Contém as credenciais de conexão:
     - `VITE_SUPABASE_URL` - URL do projeto Supabase
     - `VITE_SUPABASE_PUBLISHABLE_KEY` - Chave pública (anon key)
   - ⚠️ Este arquivo não está no Git por questões de segurança

3. **`src/integrations/supabase/client.ts`**
   - Cliente Supabase configurado
   - Lê as variáveis de ambiente para conectar ao banco

### 🗄️ Estrutura do Banco de Dados

As migrações estão em:
- `supabase/migrations/20251130185609_10e73531-fe4a-4518-90ae-9a6508ff1093.sql` - Migração inicial
- `supabase/migrations/20251201000000_support_system.sql` - Sistema de suporte

### 🔐 Como Acessar o Banco de Dados

#### Opção 1: Supabase Dashboard (Recomendado)

1. Acesse: https://app.supabase.com
2. Faça login na sua conta
3. Selecione o projeto com ID: `yhvhefrknmwqhuinrcfi`
4. Você terá acesso a:
   - **Table Editor** - Ver e editar tabelas
   - **SQL Editor** - Executar queries SQL
   - **Authentication** - Gerenciar usuários
   - **Storage** - Gerenciar arquivos
   - **Database** - Ver estrutura do banco

#### Opção 2: SQL Editor Direto

1. No Supabase Dashboard, vá em **SQL Editor**
2. Você pode executar queries SQL diretamente
3. Use os scripts `.sql` deste projeto:
   - `apply-support-migration.sql` - Aplicar migração de suporte
   - `setup-support-user.sql` - Criar usuário de suporte
   - `check-support-user.sql` - Verificar usuário de suporte

### 📋 Tabelas do Banco de Dados

O banco contém as seguintes tabelas principais:

1. **profiles** - Perfis de usuários
2. **posts** - Publicações do feed
3. **likes** - Curtidas em posts
4. **comments** - Comentários em posts
5. **chat_messages** - Mensagens do chat geral
6. **support_chat** - Mensagens do chat de suporte
7. **badges** - Conquistas/badges
8. **user_badges** - Badges dos usuários
9. **notifications** - Notificações
10. **support_messages** - Mensagens de suporte (formulário)

### 🔍 Verificar Conexão

Para verificar se está conectado corretamente:

1. Abra o Console do navegador (F12)
2. Procure pela mensagem: `✅ Conexão com o banco de dados Supabase estabelecida com sucesso!`
3. Se aparecer erro, verifique as variáveis de ambiente no arquivo `.env`

### 📝 Variáveis de Ambiente Necessárias

Crie um arquivo `.env` na raiz do projeto com:

```env
VITE_SUPABASE_URL=https://yhvhefrknmwqhuinrcfi.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sua_chave_anon_aqui
```

Para obter a chave:
1. Acesse o Supabase Dashboard
2. Vá em **Settings** > **API**
3. Copie a **anon/public key**

### 🛠️ Executar Migrações

Para aplicar as migrações do banco:

1. Acesse o Supabase Dashboard
2. Vá em **SQL Editor**
3. Execute o arquivo `apply-support-migration.sql`
4. Ou execute as migrações em `supabase/migrations/`

### 📞 Suporte

Se precisar de ajuda:
- Documentação Supabase: https://supabase.com/docs
- Dashboard: https://app.supabase.com
- Verifique os arquivos de troubleshooting:
  - `TROUBLESHOOTING_SUPPORT.md`
  - `MIGRATION_INSTRUCTIONS.md`

