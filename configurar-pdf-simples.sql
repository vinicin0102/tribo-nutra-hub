-- ============================================
-- CONFIGURAR UPLOAD DE PDFs - SQL SIMPLES
-- ============================================
-- Execute este SQL no Supabase SQL Editor
-- 
-- IMPORTANTE: Antes de executar este SQL, você PRECISA:
-- 1. Ir em Storage > images > Settings
-- 2. Adicionar "application/pdf" na lista de "Allowed MIME types"
-- 3. Salvar
-- ============================================

-- Remover política antiga se existir
DROP POLICY IF EXISTS "Authenticated users can upload PDFs to images bucket" ON storage.objects;

-- Criar política para permitir upload de PDFs no bucket "images"
CREATE POLICY "Authenticated users can upload PDFs to images bucket"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'images' 
  AND (
    -- Permitir arquivos com extensão .pdf
    name LIKE '%.pdf' 
    OR name LIKE '%/pdfs/%'
    OR storage.extension(name) = 'pdf'
  )
  AND auth.role() = 'authenticated'
);

-- Permitir leitura pública de PDFs
DROP POLICY IF EXISTS "PDFs are publicly accessible" ON storage.objects;

CREATE POLICY "PDFs are publicly accessible"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'images' 
  AND (
    name LIKE '%.pdf' 
    OR name LIKE '%/pdfs/%'
    OR storage.extension(name) = 'pdf'
  )
);

-- Verificar se as políticas foram criadas
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%PDF%' OR policyname LIKE '%pdf%'
ORDER BY policyname;

-- ============================================
-- PRÓXIMOS PASSOS:
-- ============================================
-- 1. Execute este SQL
-- 2. Vá em Storage > images > Settings
-- 3. Adicione "application/pdf" em "Allowed MIME types"
-- 4. Salve
-- 5. Teste o upload de PDF novamente
-- ============================================

