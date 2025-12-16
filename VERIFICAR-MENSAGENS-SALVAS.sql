-- =====================================================
-- VERIFICAR SE AS MENSAGENS ESTÃO SENDO SALVAS
-- =====================================================
-- Execute este script AGORA para ver se as mensagens
-- estão sendo salvas no banco de dados
-- =====================================================

-- 1. Ver TODAS as mensagens (últimas 20)
SELECT 
  id,
  user_id,
  content,
  created_at,
  NOW() - created_at as tempo_desde_envio
FROM public.chat_messages
ORDER BY created_at DESC
LIMIT 20;

-- 2. Contar mensagens de hoje
SELECT 
  COUNT(*) as mensagens_hoje,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages
WHERE created_at::date = CURRENT_DATE;

-- 3. Verificar mensagens dos últimos 10 minutos
SELECT 
  COUNT(*) as mensagens_ultimos_10min,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages
WHERE created_at > NOW() - INTERVAL '10 minutes';

-- 4. Verificar se há mensagens sem conteúdo
SELECT 
  COUNT(*) as mensagens_vazias
FROM public.chat_messages
WHERE content IS NULL OR content = '';

-- 5. Verificar estrutura exata da tabela
SELECT 
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
ORDER BY ordinal_position;

