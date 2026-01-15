# 🪣 Configuração do Bucket de Imagens no Supabase

## ⚠️ Erro Atual

Se você está vendo o erro:
```
Bucket de imagens não configurado no Supabase. Configure o bucket "images" no Storage.
```

Isso significa que o bucket de Storage ainda não foi criado no Supabase.

## ✅ Solução Rápida

### Passo 1: Acessar o Supabase Dashboard

1. Acesse: https://app.supabase.com
2. Selecione o projeto `oglakfbpuosrhhtbyprw`
3. Vá em **Storage** (no menu lateral)

### Passo 2: Criar o Bucket "images"

1. Na página de Storage, clique em **New bucket**
2. Preencha:
   - **Name:** `images`
   - **Public bucket:** ✅ Marque esta opção (importante para que as imagens sejam acessíveis publicamente)
3. Clique em **Create bucket**

### Passo 3: Configurar Políticas de Acesso

Após criar o bucket, você precisa configurar as políticas de acesso:

1. Clique no bucket `images` que você acabou de criar
2. Vá na aba **Policies**
3. Clique em **New Policy**

#### Política 1: Permitir leitura pública (SELECT)

1. Selecione **For full customization**
2. Configure:
   - **Policy name:** `Public read access`
   - **Allowed operation:** `SELECT`
   - **Policy definition:**
     ```sql
     true
     ```
3. Clique em **Review** e depois **Save policy**

#### Política 2: Permitir upload para usuários autenticados (INSERT)

1. Clique em **New Policy** novamente
2. Selecione **For full customization**
3. Configure:
   - **Policy name:** `Authenticated users can upload`
   - **Allowed operation:** `INSERT`
   - **Policy definition:**
     ```sql
     auth.role() = 'authenticated'
     ```
4. Clique em **Review** e depois **Save policy**

#### Política 3: Permitir atualização para o próprio usuário (UPDATE)

1. Clique em **New Policy** novamente
2. Selecione **For full customization**
3. Configure:
   - **Policy name:** `Users can update own files`
   - **Allowed operation:** `UPDATE`
   - **Policy definition:**
     ```sql
     auth.uid()::text = (storage.foldername(name))[1]
     ```
4. Clique em **Review** e depois **Save policy**

#### Política 4: Permitir exclusão para o próprio usuário (DELETE)

1. Clique em **New Policy** novamente
2. Selecione **For full customization**
3. Configure:
   - **Policy name:** `Users can delete own files`
   - **Allowed operation:** `DELETE`
   - **Policy definition:**
     ```sql
     auth.uid()::text = (storage.foldername(name))[1]
     ```
4. Clique em **Review** e depois **Save policy**

### Passo 4: Verificar Configuração

Após configurar tudo, você deve ter 4 políticas no bucket `images`:
- ✅ Public read access (SELECT)
- ✅ Authenticated users can upload (INSERT)
- ✅ Users can update own files (UPDATE)
- ✅ Users can delete own files (DELETE)

## 🔧 Configuração Alternativa via SQL

Se preferir, você pode executar este SQL no **SQL Editor**:

```sql
-- Criar bucket (se não existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Política 1: Leitura pública
CREATE POLICY "Public read access" ON storage.objects
FOR SELECT
USING (bucket_id = 'images');

-- Política 2: Upload para usuários autenticados
CREATE POLICY "Authenticated users can upload" ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'images' 
  AND auth.role() = 'authenticated'
);

-- Política 3: Atualização para o próprio usuário
CREATE POLICY "Users can update own files" ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política 4: Exclusão para o próprio usuário
CREATE POLICY "Users can delete own files" ON storage.objects
FOR DELETE
USING (
  bucket_id = 'images'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

## 📁 Estrutura de Pastas

O código organiza as imagens em pastas por tipo:
- `avatars/` - Avatares de usuários
- `posts/` - Imagens de posts

Cada arquivo é salvo com o formato: `{tipo}/{user_id}/{uuid}.{extensão}`

## ✅ Verificação

Após configurar, teste:

1. Tente fazer upload de uma imagem no perfil
2. Tente fazer upload de uma imagem em um post
3. Verifique se as imagens aparecem corretamente

Se ainda houver erro, verifique:
- Se o bucket está marcado como **Public**
- Se as políticas foram criadas corretamente
- Se você está logado (para uploads)

## 🆘 Problemas Comuns

### Erro: "Bucket not found"
- Verifique se o bucket foi criado com o nome exato: `images`
- Verifique se está no projeto correto do Supabase

### Erro: "new row violates row-level security policy"
- Verifique se as políticas de INSERT foram criadas
- Verifique se você está autenticado

### Imagens não aparecem
- Verifique se o bucket está marcado como **Public**
- Verifique se a política de SELECT foi criada
- Verifique a URL da imagem no console do navegador

