# 🚀 Configurar PDF - Passo a Passo Rápido

## ⚡ Solução Mais Rápida (2 minutos)

### Passo 1: Configurar o bucket "images" no Supabase

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. No menu lateral, clique em **Storage**
4. Clique no bucket **"images"**
5. Clique na aba **Settings** (Configurações)
6. Role até a seção **"Allowed MIME types"**
7. Clique em **"Add MIME type"** ou edite a lista
8. Adicione: `application/pdf`
9. Clique em **Save**

### Passo 2: Executar o SQL (Opcional - apenas para políticas)

Execute este SQL no **SQL Editor** do Supabase:

```sql
-- Permitir upload de PDFs no bucket images
DROP POLICY IF EXISTS "Authenticated users can upload PDFs to images bucket" ON storage.objects;

CREATE POLICY "Authenticated users can upload PDFs to images bucket"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'images' 
  AND (storage.extension(name) = 'pdf' OR name LIKE '%.pdf')
  AND auth.role() = 'authenticated'
);
```

### Pronto! ✅

Agora você pode fazer upload de PDFs normalmente.

---

## 🔄 Alternativa: Criar bucket "documents" separado

Se preferir ter um bucket separado para documentos:

1. **Storage** > **New bucket**
2. Nome: `documents`
3. ✅ Marque **Public bucket**
4. **Allowed MIME types**: `application/pdf`
5. **Create bucket**
6. Execute o script completo `configurar-storage-pdf.sql`

---

## ❓ Problemas?

Se ainda não funcionar:
- Verifique se o bucket está **público**
- Verifique se `application/pdf` está na lista de MIME types permitidos
- Recarregue a página após configurar

