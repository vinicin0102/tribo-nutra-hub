INSERT INTO storage.buckets (id, name, public)
VALUES ('images', 'images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

CREATE POLICY IF NOT EXISTS "Allow authenticated uploads"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'images');

CREATE POLICY IF NOT EXISTS "Allow public reads"
ON storage.objects FOR SELECT TO public
USING (bucket_id = 'images');

CREATE POLICY IF NOT EXISTS "Allow authenticated deletes"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'images');

SELECT 'Bucket criado!' as status, id, name, public
FROM storage.buckets WHERE id = 'images';

