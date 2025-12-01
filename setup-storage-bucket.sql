-- ============================================
-- CONFIGURAÇÃO DO BUCKET DE IMAGENS
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- Este script cria o bucket e configura todas as políticas necessárias

-- 1. Criar bucket "images" (se não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'images',
  'images',
  true,
  5242880, -- 5MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET 
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

-- 2. Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Public read access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own files" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own files" ON storage.objects;
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;

-- 3. Política 1: Leitura pública (qualquer um pode ver as imagens)
CREATE POLICY "Public read access" ON storage.objects
FOR SELECT
USING (bucket_id = 'images');

-- 4. Política 2: Upload para usuários autenticados
CREATE POLICY "Authenticated users can upload" ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'images'
  AND (storage.foldername(name))[1] IN ('avatars', 'posts')
);

-- 5. Política 3: Atualização para o próprio usuário
CREATE POLICY "Users can update own files" ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'images'
  AND auth.uid()::text = (storage.foldername(name))[2]
)
WITH CHECK (
  bucket_id = 'images'
  AND auth.uid()::text = (storage.foldername(name))[2]
);

-- 6. Política 4: Exclusão para o próprio usuário
CREATE POLICY "Users can delete own files" ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'images'
  AND auth.uid()::text = (storage.foldername(name))[2]
);

-- 7. Verificar se tudo foi criado corretamente
SELECT 
  'Bucket configurado!' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.buckets WHERE id = 'images'
    ) THEN '✓ Bucket images existe'
    ELSE '✗ Bucket images não existe'
  END as check_bucket,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.buckets WHERE id = 'images' AND public = true
    ) THEN '✓ Bucket é público'
    ELSE '✗ Bucket não é público'
  END as check_public,
  (
    SELECT COUNT(*) 
    FROM pg_policies 
    WHERE tablename = 'objects' 
    AND schemaname = 'storage'
    AND policyname LIKE '%images%'
  )::text || ' políticas criadas' as policies_count;

-- Mensagem de sucesso
DO $$
BEGIN
  RAISE NOTICE '✅ Bucket de imagens configurado com sucesso!';
  RAISE NOTICE 'Bucket: images';
  RAISE NOTICE 'Público: true';
  RAISE NOTICE 'Limite de tamanho: 5MB';
  RAISE NOTICE 'Tipos permitidos: image/jpeg, image/png, image/gif, image/webp';
END $$;

