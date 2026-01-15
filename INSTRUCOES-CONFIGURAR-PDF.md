# Como Configurar o Storage para Aceitar PDFs

O erro "mime type application/pdf is not supported" ocorre porque o bucket do Supabase não está configurado para aceitar PDFs.

## Solução Rápida (Recomendada)

### Opção 1: Usar o bucket "images" existente

1. Acesse o **Supabase Dashboard**
2. Vá em **Storage** > **images**
3. Clique em **Settings** (Configurações)
4. Na seção **File size limit**, verifique o limite
5. Na seção **Allowed MIME types**, adicione:
   - `application/pdf`
6. Clique em **Save**

### Opção 2: Criar um bucket separado "documents" (Melhor organização)

1. Acesse o **Supabase Dashboard**
2. Vá em **Storage**
3. Clique em **New bucket**
4. Configure:
   - **Name**: `documents`
   - **Public bucket**: ✅ Sim (marcado)
   - **File size limit**: 10 MB (ou o que preferir)
   - **Allowed MIME types**: `application/pdf`
5. Clique em **Create bucket**

6. Execute o script SQL `configurar-storage-pdf.sql` no Supabase SQL Editor para criar as políticas RLS

## Após Configurar

Depois de configurar o bucket, o upload de PDFs funcionará automaticamente. O código já está preparado para usar:
- Primeiro tenta o bucket "documents" (se existir)
- Se não existir, usa o bucket "images"

## Verificação

Para verificar se está funcionando:
1. Tente fazer upload de um PDF novamente
2. Se ainda der erro, verifique:
   - Se o bucket está público
   - Se o MIME type `application/pdf` está na lista de permitidos
   - Se as políticas RLS estão configuradas corretamente

