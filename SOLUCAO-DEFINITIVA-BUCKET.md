# 🔧 SOLUÇÃO DEFINITIVA - CRIAR BUCKET 'images'

## ⚠️ PROBLEMA:
O erro "Bucket not found" aparece porque o bucket `images` não existe no Supabase Storage.

---

## ✅ SOLUÇÃO (5 MINUTOS):

### PASSO 1: Acesse o Supabase Dashboard
1. Vá em: https://supabase.com/dashboard
2. Entre no seu projeto

### PASSO 2: Vá em Storage
1. No menu lateral esquerdo, clique em **"Storage"**
2. Você verá uma tela com "No buckets yet" ou lista de buckets

### PASSO 3: Criar o Bucket
1. Clique no botão **"New bucket"** (canto superior direito)
2. Preencha:
   - **Name:** `images` (exatamente assim, minúsculo)
   - **Public bucket:** ✅ **MARQUE ESTA OPÇÃO** (muito importante!)
3. Clique em **"Create bucket"**

### PASSO 4: Configurar Políticas (RLS)
Após criar o bucket, você precisa permitir acesso:

1. Clique no bucket `images` que você acabou de criar
2. Vá na aba **"Policies"** (ao lado de "Files")
3. Clique em **"New Policy"**

#### Política 1: Upload (INSERT)
- Selecione: **"Create policy from scratch"**
- **Policy name:** `Allow authenticated uploads`
- **Allowed operation:** Selecione `INSERT`
- **Target roles:** Selecione `authenticated`
- **Policy definition:** Cole este código:
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** → **"Save policy"**

#### Política 2: Leitura (SELECT)
- Clique em **"New Policy"** novamente
- **Policy name:** `Allow public reads`
- **Allowed operation:** Selecione `SELECT`
- **Target roles:** Selecione `authenticated` e `anon` (público)
- **Policy definition:** Cole este código:
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** → **"Save policy"**

#### Política 3: Deletar (DELETE)
- Clique em **"New Policy"** novamente
- **Policy name:** `Allow authenticated deletes`
- **Allowed operation:** Selecione `DELETE`
- **Target roles:** Selecione `authenticated`
- **Policy definition:** Cole este código:
  ```sql
  (bucket_id = 'images'::text)
  ```
- Clique em **"Review"** → **"Save policy"**

---

## ✅ VERIFICAÇÃO:

1. Volte ao app
2. Recarregue a página (F5 ou Cmd+R)
3. Tente enviar um áudio novamente
4. **Deve funcionar!** 🎉

---

## 🔍 VERIFICAR SE FUNCIONOU:

Execute este SQL no Supabase SQL Editor para verificar:
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'images';
```

Se aparecer:
```
id: images
name: images
public: true
```

**Então está correto!** ✅

---

## ❌ SE AINDA NÃO FUNCIONAR:

1. Verifique se o bucket está marcado como **"Public"**
2. Verifique se as 3 políticas foram criadas
3. Verifique se você está logado no app
4. Limpe o cache do navegador (Ctrl+Shift+R ou Cmd+Shift+R)

---

## 📸 PRECISA DE AJUDA?

Se ainda não funcionar, envie:
1. Captura de tela do bucket criado (mostrando que está "Public")
2. Captura de tela das políticas criadas
3. O erro exato que aparece no app

