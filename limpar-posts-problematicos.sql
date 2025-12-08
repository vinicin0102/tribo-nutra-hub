-- 🧹 LIMPAR POSTS PROBLEMÁTICOS DO BANCO
-- Execute este script no Supabase SQL Editor para limpar posts inválidos

-- ⚠️ ATENÇÃO: Este script vai DELETAR posts problemáticos!
-- Faça backup antes se necessário

-- 1️⃣ DELETAR POSTS COM CONTEÚDO VAZIO OU NULL
DELETE FROM posts
WHERE content IS NULL 
   OR TRIM(content) = ''
   OR content = ' ';

-- 2️⃣ DELETAR POSTS COM user_id INVÁLIDO (não existe em auth.users)
DELETE FROM posts
WHERE user_id NOT IN (SELECT id FROM auth.users);

-- 3️⃣ DELETAR POSTS DUPLICADOS (mantém apenas o mais recente)
DELETE FROM posts
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      id,
      ROW_NUMBER() OVER (
        PARTITION BY user_id, TRIM(content) 
        ORDER BY created_at DESC
      ) as rn
    FROM posts
    WHERE content IS NOT NULL 
      AND TRIM(content) != ''
      AND user_id IN (SELECT id FROM auth.users)
  ) t
  WHERE rn > 1
);

-- 4️⃣ DELETAR POSTS COM DATAS INVÁLIDAS (futuro ou muito antigo)
DELETE FROM posts
WHERE created_at > NOW() + INTERVAL '1 day'
   OR created_at < '2020-01-01';

-- 5️⃣ CORRIGIR CONTAGENS NOS POSTS

-- Corrigir likes_count
UPDATE posts p
SET likes_count = COALESCE((
  SELECT COUNT(*) 
  FROM likes l 
  WHERE l.post_id = p.id
), 0);

-- Corrigir comments_count
UPDATE posts p
SET comments_count = COALESCE((
  SELECT COUNT(*) 
  FROM comments c 
  WHERE c.post_id = p.id
), 0);

-- 6️⃣ CORRIGIR CONTAGENS NOS PERFIS

-- Corrigir posts_count
UPDATE profiles p
SET posts_count = COALESCE((
  SELECT COUNT(*) 
  FROM posts 
  WHERE user_id = p.user_id
), 0);

-- Corrigir likes_given_count
UPDATE profiles p
SET likes_given_count = COALESCE((
  SELECT COUNT(*) 
  FROM likes 
  WHERE user_id = p.user_id
), 0);

-- Corrigir comments_given_count
UPDATE profiles p
SET comments_given_count = COALESCE((
  SELECT COUNT(*) 
  FROM comments 
  WHERE user_id = p.user_id
), 0);

-- 7️⃣ VERIFICAR RESULTADO

SELECT 
  'Total de posts após limpeza' as info,
  COUNT(*) as quantidade
FROM posts
WHERE content IS NOT NULL 
  AND TRIM(content) != ''
  AND user_id IN (SELECT id FROM auth.users);

-- Ver posts mais recentes
SELECT 
  p.id,
  pr.username,
  LEFT(p.content, 50) as conteudo,
  p.created_at
FROM posts p
LEFT JOIN profiles pr ON pr.user_id = p.user_id
WHERE p.content IS NOT NULL 
  AND TRIM(p.content) != ''
  AND p.user_id IN (SELECT id FROM auth.users)
ORDER BY p.created_at DESC
LIMIT 20;

