# 🔧 Como Corrigir o Erro de Áudio no Chat

## ⚠️ Erro Atual
```
Erro: Could not find the 'audio_duration' column of 'chat_messages' in the schema cache
```

## ✅ Solução

### Passo 1: Execute o Script SQL

1. Acesse o **Supabase Dashboard**
2. Vá em **SQL Editor** (menu lateral)
3. Clique em **New Query**
4. **Cole o código abaixo** e clique em **RUN**:

```sql
-- Adicionar colunas de áudio à tabela chat_messages
ALTER TABLE public.chat_messages 
ADD COLUMN IF NOT EXISTS audio_url TEXT;

ALTER TABLE public.chat_messages 
ADD COLUMN IF NOT EXISTS audio_duration INTEGER;

ALTER TABLE public.chat_messages 
ADD COLUMN IF NOT EXISTS image_url TEXT;
```

### Passo 2: Verificar se Funcionou

Execute este comando para verificar:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages' 
  AND column_name IN ('audio_url', 'audio_duration', 'image_url');
```

Você deve ver 3 linhas retornadas:
- `audio_url` (text)
- `audio_duration` (integer)
- `image_url` (text)

### Passo 3: Limpar Cache

1. Feche o app completamente
2. Limpe o cache do navegador: **Ctrl+Shift+R** (ou **Cmd+Shift+R** no Mac)
3. Abra o app novamente
4. Tente enviar um áudio

## 🎯 Se Ainda Não Funcionar

1. Verifique se você executou o SQL no banco correto
2. Aguarde 1-2 minutos após executar o SQL
3. Tente fazer logout e login novamente
4. Verifique o console do navegador (F12) para ver erros detalhados

