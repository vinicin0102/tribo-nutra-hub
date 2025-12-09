-- ============================================
-- CRIAR BUCKET 'images' NO SUPABASE STORAGE
-- ============================================
-- Copie TODO este conteúdo e cole no Supabase SQL Editor
-- ============================================

-- Criar o bucket 'images'
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Permitir que usuários autenticados façam upload
CREATE POLICY IF NOT EXISTS "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- Permitir que qualquer pessoa veja os arquivos
CREATE POLICY IF NOT EXISTS "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- Permitir que usuários autenticados deletem arquivos
CREATE POLICY IF NOT EXISTS "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'images');

-- Verificar se funcionou (deve mostrar "Bucket criado!")
SELECT 
  '✅ Bucket criado!' as status,
  id,
  name,
  public
FROM storage.buckets
WHERE id = 'images';
