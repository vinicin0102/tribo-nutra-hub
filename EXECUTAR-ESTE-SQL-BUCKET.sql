-- ============================================
-- CRIAR BUCKET 'images' - EXECUTE ESTE SQL
-- ============================================

-- 1. Criar bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Remover políticas antigas
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- 3. Criar política de UPLOAD
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'images');

-- 4. Criar política de LEITURA
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'images');

-- 5. Criar política de DELETE
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'images');

-- 6. Verificar resultado
SELECT 
  '✅ SUCESSO! Bucket criado!' as resultado,
  id,
  name,
  public
FROM storage.buckets 
WHERE id = 'images';

