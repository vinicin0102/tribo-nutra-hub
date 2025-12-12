-- ============================================
-- VERIFICAR BUCKET E POLÍTICAS
-- ============================================

-- 1. Verificar se o bucket existe
SELECT 
  '1. BUCKET:' as verificação,
  id,
  name,
  public,
  created_at
FROM storage.buckets 
WHERE id = 'images';

-- 2. Verificar políticas criadas
SELECT 
  '2. POLÍTICAS:' as verificação,
  policyname,
  cmd as operação,
  roles::text as roles
FROM pg_policies
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%images%' OR policyname IN (
    'Allow authenticated uploads',
    'Allow public reads',
    'Allow authenticated deletes'
  )
ORDER BY policyname;

-- 3. Verificar permissões do usuário atual
SELECT 
  '3. USUÁRIO ATUAL:' as verificação,
  current_user as usuário,
  current_database() as banco;
