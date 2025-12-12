-- Configurar Storage para aceitar PDFs
-- Este script configura o bucket "images" para aceitar PDFs OU cria um bucket "documents" separado

-- Opção 1: Se você quiser usar o bucket "images" existente para PDFs também
-- Você precisa ir no Supabase Dashboard > Storage > images > Settings
-- E adicionar "application/pdf" na lista de allowed MIME types

-- Opção 2: Criar um bucket separado para documentos (RECOMENDADO)
-- Verificar se o bucket "documents" já existe
DO $$ 
BEGIN
  -- Tentar criar o bucket "documents" se não existir
  -- Nota: Criação de bucket via SQL não é suportada diretamente
  -- Você precisa criar manualmente no Dashboard ou usar a API
  RAISE NOTICE 'Para criar o bucket "documents":';
  RAISE NOTICE '1. Vá em Supabase Dashboard > Storage';
  RAISE NOTICE '2. Clique em "New bucket"';
  RAISE NOTICE '3. Nome: "documents"';
  RAISE NOTICE '4. Público: Sim';
  RAISE NOTICE '5. Allowed MIME types: application/pdf';
END $$;

-- Criar política RLS para o bucket "documents" (se existir)
-- Permitir leitura pública
CREATE POLICY IF NOT EXISTS "Documents are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'documents');

-- Permitir upload para usuários autenticados
CREATE POLICY IF NOT EXISTS "Authenticated users can upload documents"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

-- Permitir atualização para usuários autenticados
CREATE POLICY IF NOT EXISTS "Authenticated users can update documents"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

-- Permitir deleção para usuários autenticados
CREATE POLICY IF NOT EXISTS "Authenticated users can delete documents"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'documents' 
  AND auth.role() = 'authenticated'
);

-- Se preferir usar o bucket "images" existente, adicione esta política:
-- (Mas você ainda precisa configurar o MIME type no Dashboard)
CREATE POLICY IF NOT EXISTS "Authenticated users can upload PDFs to images bucket"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'images' 
  AND (storage.extension(name) = 'pdf' OR name LIKE '%.pdf')
  AND auth.role() = 'authenticated'
);

