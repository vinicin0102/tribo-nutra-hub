# 🔌 Conexão com o Banco de Dados Atualizada

## ✅ Configuração Aplicada

O projeto foi configurado para conectar ao novo banco de dados Supabase:

- **Project ID:** `oglakfbpuosrhhtbyprw`
- **URL:** `https://oglakfbpuosrhhtbyprw.supabase.co`
- **Anon Key:** Configurada no arquivo `.env`

## 📝 Arquivos Atualizados

1. ✅ `supabase/config.toml` - Project ID atualizado
2. ✅ `.env` - Variáveis de ambiente atualizadas
3. ✅ `.env.example` - Arquivo de exemplo criado

## 🚀 Próximos Passos

### 1. Aplicar as Migrações no Novo Banco

O novo banco precisa ter a estrutura criada. Execute:

1. Acesse o Supabase Dashboard: https://app.supabase.com
2. Selecione o projeto `oglakfbpuosrhhtbyprw`
3. Vá em **SQL Editor**
4. Execute as migrações nesta ordem:

**Primeiro:** Execute a migração inicial
- Arquivo: `supabase/migrations/20251130185609_10e73531-fe4a-4518-90ae-9a6508ff1093.sql`

**Depois:** Execute a migração de suporte
- Arquivo: `apply-support-migration.sql`

### 2. Reiniciar o Servidor de Desenvolvimento

Após atualizar o `.env`, você precisa reiniciar o servidor:

```bash
# Pare o servidor atual (Ctrl+C)
# Depois inicie novamente:
npm run dev
```

### 3. Verificar a Conexão

1. Abra o Console do navegador (F12)
2. Procure pela mensagem:
   ```
   ✅ Conexão com o banco de dados Supabase estabelecida com sucesso!
   ```

## 🔍 Verificar Configuração

Para verificar se está tudo correto:

1. Abra o arquivo `.env` e confirme:
   ```env
   VITE_SUPABASE_URL=https://oglakfbpuosrhhtbyprw.supabase.co
   VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. Verifique o `supabase/config.toml`:
   ```toml
   project_id = "oglakfbpuosrhhtbyprw"
   ```

## ⚠️ Importante

- O arquivo `.env` não está versionado no Git (por segurança)
- Certifique-se de que o arquivo `.env` existe e está na raiz do projeto
- Após alterar o `.env`, sempre reinicie o servidor de desenvolvimento

## 🆘 Problemas Comuns

### Erro: "Missing env.VITE_SUPABASE_URL"
- Verifique se o arquivo `.env` existe na raiz do projeto
- Verifique se as variáveis estão escritas corretamente (sem espaços extras)

### Erro: "Invalid API key"
- Verifique se a chave anon está correta
- Obtenha a chave correta em: Supabase Dashboard > Settings > API

### Erro de conexão
- Verifique sua conexão com a internet
- Verifique se o projeto Supabase está ativo
- Verifique se o Project ID está correto

