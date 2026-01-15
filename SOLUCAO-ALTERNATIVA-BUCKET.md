# 🔧 SOLUÇÃO ALTERNATIVA - CRIAR BUCKET MANUALMENTE

Se o SQL não funcionou, crie o bucket manualmente:

## 📋 PASSO A PASSO MANUAL:

### 1️⃣ Acesse o Supabase Dashboard
- Vá em: https://supabase.com/dashboard
- Entre no seu projeto

### 2️⃣ Vá em Storage
- No menu lateral esquerdo, clique em **"Storage"**
- Você verá a lista de buckets

### 3️⃣ Criar Novo Bucket
- Clique no botão **"New bucket"** (ou "Novo bucket")
- **Nome do bucket:** `images`
- **Public bucket:** ✅ **MARQUE ESTA OPÇÃO** (muito importante!)
- Clique em **"Create bucket"**

### 4️⃣ Configurar Políticas (RLS)
Após criar o bucket:

1. Clique no bucket `images` que você acabou de criar
2. Vá na aba **"Policies"** (Políticas)
3. Clique em **"New Policy"**
4. Selecione **"Create policy from scratch"**

#### Política 1: Upload
- **Policy name:** `Allow authenticated uploads`
- **Allowed operation:** `INSERT`
- **Target roles:** `authenticated`
- **Policy definition:** 
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** e depois **"Save policy"**

#### Política 2: Leitura
- **Policy name:** `Allow public reads`
- **Allowed operation:** `SELECT`
- **Target roles:** `authenticated`, `anon` (público)
- **Policy definition:**
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** e depois **"Save policy"**

#### Política 3: Deletar
- **Policy name:** `Allow authenticated deletes`
- **Allowed operation:** `DELETE`
- **Target roles:** `authenticated`
- **Policy definition:**
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** e depois **"Save policy"**

---

## ✅ VERIFICAÇÃO:

1. Volte ao app
2. Recarregue a página (F5)
3. Tente enviar um áudio novamente
4. Deve funcionar! 🎉

---

## 🔍 VERIFICAR SE O BUCKET EXISTE:

Execute este SQL no Supabase SQL Editor:
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'images';
```

Se não aparecer nada, o bucket não existe e você precisa criá-lo.

