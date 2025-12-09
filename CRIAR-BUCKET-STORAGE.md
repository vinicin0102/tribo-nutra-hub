# 🪣 Criar Bucket no Supabase Storage

## ⚠️ ERRO: "Bucket not found"

O bucket `images` não existe no seu Supabase Storage. Siga estes passos para criar:

---

## 📋 PASSO A PASSO:

### 1️⃣ Acesse o Supabase Dashboard
- Vá em: https://supabase.com/dashboard
- Entre no seu projeto

### 2️⃣ Vá em Storage
- No menu lateral esquerdo, clique em **"Storage"**
- Você verá a lista de buckets (provavelmente vazia)

### 3️⃣ Criar Novo Bucket
- Clique no botão **"New bucket"** (ou "Novo bucket")
- **Nome do bucket:** `images`
- **Public bucket:** ✅ **MARQUE ESTA OPÇÃO** (importante para URLs públicas funcionarem)
- Clique em **"Create bucket"**

### 4️⃣ Configurar Políticas (RLS)
Após criar o bucket, você precisa permitir que usuários autenticados façam upload:

1. Clique no bucket `images` que você acabou de criar
2. Vá na aba **"Policies"** (Políticas)
3. Clique em **"New Policy"**
4. Selecione **"Create policy from scratch"**
5. Configure:
   - **Policy name:** `Allow authenticated uploads`
   - **Allowed operation:** `INSERT`
   - **Target roles:** `authenticated`
   - **Policy definition:** 
     ```sql
     (bucket_id = 'images'::text)
     ```
6. Clique em **"Review"** e depois **"Save policy"**

7. Crie outra política para leitura:
   - **Policy name:** `Allow public reads`
   - **Allowed operation:** `SELECT`
   - **Target roles:** `authenticated`, `anon` (público)
   - **Policy definition:**
     ```sql
     (bucket_id = 'images'::text)
     ```
   - Clique em **"Review"** e depois **"Save policy"**

---

## ✅ VERIFICAÇÃO:

Após criar o bucket e as políticas:

1. Volte ao app
2. Tente enviar um áudio novamente
3. Deve funcionar! 🎉

---

## 🔧 ALTERNATIVA RÁPIDA (via SQL):

Se preferir, você pode executar este SQL no Supabase SQL Editor:

```sql
-- Criar bucket 'images' (se não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true, -- bucket público
  52428800, -- 50MB limite
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'audio/webm', 'audio/mp4', 'audio/ogg']
)
ON CONFLICT (id) DO NOTHING;

-- Política para upload (usuários autenticados)
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- Política para leitura (público)
CREATE POLICY "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');
```

**⚠️ IMPORTANTE:** Execute este SQL no **Supabase SQL Editor**, não no código!

---

## 🎯 DEPOIS DE CRIAR:

1. Aguarde alguns segundos
2. Teste enviar um áudio no chat
3. Deve funcionar imediatamente!

