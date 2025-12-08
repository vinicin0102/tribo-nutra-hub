-- 🔍 DIAGNÓSTICO GERAL DO BANCO DE DADOS
-- Execute este script no Supabase SQL Editor para verificar problemas

-- 1️⃣ VERIFICAR ESTRUTURA DAS TABELAS PRINCIPAIS

-- Verificar tabela profiles
SELECT 
  'profiles' as tabela,
  COUNT(*) as total_registros,
  COUNT(DISTINCT user_id) as usuarios_unicos,
  COUNT(*) FILTER (WHERE subscription_plan = 'diamond') as usuarios_diamond,
  COUNT(*) FILTER (WHERE points > 0) as usuarios_com_pontos,
  AVG(points)::numeric(10,2) as media_pontos
FROM profiles;

-- Verificar tabela posts
SELECT 
  'posts' as tabela,
  COUNT(*) as total_posts,
  COUNT(DISTINCT user_id) as usuarios_com_posts,
  COUNT(*) FILTER (WHERE is_support_post = true) as posts_suporte,
  COUNT(*) FILTER (WHERE image_url IS NOT NULL) as posts_com_imagem,
  MIN(created_at) as primeiro_post,
  MAX(created_at) as ultimo_post
FROM posts;

-- Verificar tabela likes
SELECT 
  'likes' as tabela,
  COUNT(*) as total_likes,
  COUNT(DISTINCT user_id) as usuarios_que_curtiram,
  COUNT(DISTINCT post_id) as posts_curtidos
FROM likes;

-- Verificar tabela comments
SELECT 
  'comments' as tabela,
  COUNT(*) as total_comentarios,
  COUNT(DISTINCT user_id) as usuarios_que_comentaram,
  COUNT(DISTINCT post_id) as posts_comentados
FROM comments;

-- 2️⃣ VERIFICAR POSTS DUPLICADOS OU PROBLEMAS

-- Posts com mesmo conteúdo e mesmo usuário (possíveis duplicatas)
SELECT 
  user_id,
  content,
  COUNT(*) as quantidade,
  array_agg(id ORDER BY created_at) as ids,
  array_agg(created_at ORDER BY created_at) as datas
FROM posts
WHERE content IS NOT NULL AND content != ''
GROUP BY user_id, content
HAVING COUNT(*) > 1
ORDER BY quantidade DESC
LIMIT 20;

-- Posts com user_id inválido (não existe em auth.users)
SELECT 
  p.id,
  p.user_id,
  p.content,
  p.created_at
FROM posts p
LEFT JOIN auth.users u ON u.id = p.user_id
WHERE u.id IS NULL
LIMIT 20;

-- Posts com conteúdo vazio ou apenas espaços
SELECT 
  id,
  user_id,
  content,
  created_at
FROM posts
WHERE content IS NULL OR TRIM(content) = ''
LIMIT 20;

-- 3️⃣ VERIFICAR INTEGRIDADE DOS DADOS

-- Verificar se likes_count está correto
SELECT 
  p.id,
  p.user_id,
  p.likes_count as likes_na_tabela,
  COUNT(l.id) as likes_reais,
  (p.likes_count - COUNT(l.id)) as diferenca
FROM posts p
LEFT JOIN likes l ON l.post_id = p.id
GROUP BY p.id, p.likes_count
HAVING p.likes_count != COUNT(l.id)
LIMIT 20;

-- Verificar se comments_count está correto
SELECT 
  p.id,
  p.user_id,
  p.comments_count as comentarios_na_tabela,
  COUNT(c.id) as comentarios_reais,
  (p.comments_count - COUNT(c.id)) as diferenca
FROM posts p
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id, p.comments_count
HAVING p.comments_count != COUNT(c.id)
LIMIT 20;

-- 4️⃣ VERIFICAR POSTS RECENTES (últimos 20)

SELECT 
  p.id,
  p.user_id,
  pr.username,
  pr.email,
  LEFT(p.content, 50) as conteudo_preview,
  p.likes_count,
  p.comments_count,
  p.is_support_post,
  p.created_at,
  p.updated_at
FROM posts p
LEFT JOIN profiles pr ON pr.user_id = p.user_id
ORDER BY p.created_at DESC
LIMIT 20;

-- 5️⃣ VERIFICAR POSTS COM PROBLEMAS

-- Posts sem perfil associado
SELECT 
  p.id,
  p.user_id,
  p.content,
  p.created_at
FROM posts p
LEFT JOIN profiles pr ON pr.user_id = p.user_id
WHERE pr.user_id IS NULL
LIMIT 20;

-- Posts com datas estranhas (futuro ou muito antigo)
SELECT 
  id,
  user_id,
  content,
  created_at
FROM posts
WHERE created_at > NOW() + INTERVAL '1 day'
   OR created_at < '2020-01-01'
ORDER BY created_at DESC
LIMIT 20;

-- 6️⃣ VERIFICAR CONTAGENS NOS PERFIS

-- Verificar se posts_count está correto
SELECT 
  p.user_id,
  pr.username,
  pr.posts_count as posts_na_tabela,
  COUNT(posts.id) as posts_reais,
  (pr.posts_count - COUNT(posts.id)) as diferenca
FROM profiles p
LEFT JOIN posts ON posts.user_id = p.user_id
GROUP BY p.user_id, pr.posts_count, pr.username
HAVING pr.posts_count != COUNT(posts.id)
LIMIT 20;

-- 7️⃣ LIMPAR POSTS PROBLEMÁTICOS (CUIDADO - Execute apenas se necessário!)

-- ⚠️ ATENÇÃO: Descomente apenas se quiser limpar posts problemáticos

-- Deletar posts duplicados (mantém apenas o mais recente)
-- DELETE FROM posts
-- WHERE id IN (
--   SELECT id
--   FROM (
--     SELECT 
--       id,
--       ROW_NUMBER() OVER (PARTITION BY user_id, content ORDER BY created_at DESC) as rn
--     FROM posts
--     WHERE content IS NOT NULL AND content != ''
--   ) t
--   WHERE rn > 1
-- );

-- Deletar posts com user_id inválido
-- DELETE FROM posts
-- WHERE user_id NOT IN (SELECT id FROM auth.users);

-- Deletar posts com conteúdo vazio
-- DELETE FROM posts
-- WHERE content IS NULL OR TRIM(content) = '';

-- 8️⃣ CORRIGIR CONTAGENS (Execute se necessário)

-- Corrigir likes_count
-- UPDATE posts p
-- SET likes_count = (
--   SELECT COUNT(*) 
--   FROM likes l 
--   WHERE l.post_id = p.id
-- );

-- Corrigir comments_count
-- UPDATE posts p
-- SET comments_count = (
--   SELECT COUNT(*) 
--   FROM comments c 
--   WHERE c.post_id = p.id
-- );

-- Corrigir posts_count nos perfis
-- UPDATE profiles p
-- SET posts_count = (
--   SELECT COUNT(*) 
--   FROM posts 
--   WHERE user_id = p.user_id
-- );

-- Corrigir likes_given_count nos perfis
-- UPDATE profiles p
-- SET likes_given_count = (
--   SELECT COUNT(*) 
--   FROM likes 
--   WHERE user_id = p.user_id
-- );

-- Corrigir comments_given_count nos perfis
-- UPDATE profiles p
-- SET comments_given_count = (
--   SELECT COUNT(*) 
--   FROM comments 
--   WHERE user_id = p.user_id
-- );

