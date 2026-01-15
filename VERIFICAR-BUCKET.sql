-- Verificar se o bucket 'images' existe
SELECT id, name, public, created_at
FROM storage.buckets
WHERE id = 'images';

-- Se não aparecer nada, o bucket não existe
-- Execute o arquivo EXECUTAR-AGORA.sql primeiro

