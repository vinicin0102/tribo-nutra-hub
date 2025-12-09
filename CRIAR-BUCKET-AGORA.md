# 🚨 CRIAR BUCKET 'images' AGORA

## ⚠️ O bucket não existe! Siga estes passos:

---

## 📋 MÉTODO 1: Via Interface (MAIS FÁCIL)

### 1️⃣ Acesse o Supabase Dashboard
- Vá em: https://supabase.com/dashboard
- Entre no seu projeto

### 2️⃣ Vá em Storage
- No menu lateral esquerdo, clique em **"Storage"**
- Você verá uma lista de buckets (ou "No buckets yet")

### 3️⃣ Criar o Bucket
1. Clique no botão **"New bucket"** (canto superior direito)
2. Preencha:
   - **Name:** `images` (exatamente assim, minúsculo)
   - **Public bucket:** ✅ **MARQUE ESTA OPÇÃO** (muito importante!)
3. Clique em **"Create bucket"**

### 4️⃣ Configurar Políticas
Após criar, clique no bucket `images` → aba **"Policies"** → **"New Policy"**:

#### Política 1: Upload
- **Policy name:** `Allow authenticated uploads`
- **Allowed operation:** `INSERT`
- **Target roles:** `authenticated`
- **Policy definition:** `(bucket_id = 'images'::text)`

#### Política 2: Leitura
- **Policy name:** `Allow public reads`
- **Allowed operation:** `SELECT`
- **Target roles:** `authenticated`, `anon`
- **Policy definition:** `(bucket_id = 'images'::text)`

#### Política 3: Deletar
- **Policy name:** `Allow authenticated deletes`
- **Allowed operation:** `DELETE`
- **Target roles:** `authenticated`
- **Policy definition:** `(bucket_id = 'images'::text)`

---

## 📋 MÉTODO 2: Via SQL

Execute o arquivo: `EXECUTAR-ESTE-SQL-BUCKET.sql` no Supabase SQL Editor

---

## ✅ VERIFICAÇÃO

Após criar, execute este SQL para verificar:
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'images';
```

Deve aparecer:
```
id: images
name: images
public: true
```

---

## 🎯 DEPOIS DE CRIAR

1. Aguarde 5 segundos
2. Recarregue o app (F5)
3. Teste enviar um áudio
4. Deve funcionar! 🎉

