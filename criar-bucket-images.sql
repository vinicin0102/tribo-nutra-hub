-- ============================================
-- CRIAR BUCKET 'images' NO SUPABASE STORAGE
-- ============================================
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Criar bucket 'images' (se não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true, -- bucket público (permite URLs públicas)
  52428800, -- 50MB limite de tamanho
  ARRAY[
    'image/jpeg', 
    'image/jpg', 
    'image/png', 
    'image/gif', 
    'image/webp',
    'audio/webm',
    'audio/mp4',
    'audio/ogg',
    'audio/mpeg'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 52428800,
  allowed_mime_types = ARRAY[
    'image/jpeg', 
    'image/jpg', 
    'image/png', 
    'image/gif', 
    'image/webp',
    'audio/webm',
    'audio/mp4',
    'audio/ogg',
    'audio/mpeg'
  ];

-- 2. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- 3. Política para UPLOAD (usuários autenticados podem fazer upload)
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- 4. Política para LEITURA (qualquer pessoa pode ver/baixar)
CREATE POLICY "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- 5. Política para DELETAR (apenas usuários autenticados podem deletar seus próprios arquivos)
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'images');

-- 6. Verificar se o bucket foi criado
SELECT 
  '✅ Bucket criado:' as status,
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets
WHERE id = 'images';

-- 7. Verificar políticas criadas
SELECT 
  '✅ Políticas criadas:' as status,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname IN ('Allow authenticated uploads', 'Allow public reads', 'Allow authenticated deletes')
ORDER BY policyname;

