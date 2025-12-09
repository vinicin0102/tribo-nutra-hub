# 🚨 CORREÇÃO URGENTE: Erro de Áudio no Chat

## ⚠️ Erro Atual
```
Erro: Could not find the 'audio_duration' column of 'chat_messages' in the schema cache
```

## ✅ SOLUÇÃO RÁPIDA (3 passos)

### 1️⃣ Abra o Supabase Dashboard
- Acesse: https://supabase.com/dashboard
- Entre no seu projeto

### 2️⃣ Execute o SQL
- Clique em **"SQL Editor"** no menu lateral
- Clique em **"New Query"**
- **COPIE E COLE** o código abaixo:

```sql
ALTER TABLE public.chat_messages 
ADD COLUMN audio_url TEXT;

ALTER TABLE public.chat_messages 
ADD COLUMN audio_duration INTEGER;

ALTER TABLE public.chat_messages 
ADD COLUMN image_url TEXT;
```

- Clique no botão **"RUN"** (ou pressione Ctrl+Enter)

### 3️⃣ Aguarde e Teste
- Aguarde **30 segundos**
- Feche o app completamente
- Abra novamente
- Tente enviar um áudio

---

## 🔍 Se Der Erro "Column Already Exists"

Se aparecer erro dizendo que a coluna já existe, execute este código para verificar:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages' 
  AND column_name IN ('audio_url', 'audio_duration', 'image_url');
```

Se retornar 3 linhas, as colunas já existem. Nesse caso:

1. **Limpe o cache do Supabase:**
   - Vá em **Settings** > **API**
   - Role até **"Clear Cache"** ou **"Refresh Schema"**
   - Ou simplesmente aguarde 2-3 minutos

2. **Limpe o cache do navegador:**
   - Pressione **Ctrl+Shift+R** (Windows/Linux)
   - Ou **Cmd+Shift+R** (Mac)

---

## 📱 Teste Final

1. Abra o app
2. Vá para o Chat
3. Clique no ícone de microfone 🎤
4. Grave um áudio
5. Clique novamente para parar
6. O áudio deve ser enviado sem erro!

---

## ❌ Se Ainda Não Funcionar

Envie uma captura de tela:
1. Do erro que aparece
2. Do resultado do SQL quando você executa o SELECT acima

