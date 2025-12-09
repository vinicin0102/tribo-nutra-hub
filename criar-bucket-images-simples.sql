-- ============================================
-- CRIAR BUCKET 'images' - VERSÃO SIMPLES
-- ============================================
-- Execute este script no Supabase SQL Editor
-- ============================================

-- 1. Criar bucket 'images' (se não existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO UPDATE SET
  public = true;

-- 2. Política para UPLOAD (usuários autenticados)
CREATE POLICY IF NOT EXISTS "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- 3. Política para LEITURA (público)
CREATE POLICY IF NOT EXISTS "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- 4. Política para DELETAR (usuários autenticados)
CREATE POLICY IF NOT EXISTS "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'images');

-- 5. Verificar se funcionou
SELECT 
  '✅ Bucket criado!' as status,
  id,
  name,
  public
FROM storage.buckets
WHERE id = 'images';

