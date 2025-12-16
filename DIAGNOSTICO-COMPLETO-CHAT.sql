-- =====================================================
-- DIAGNÓSTICO COMPLETO DO CHAT NO BANCO DE DADOS
-- =====================================================
-- Execute este script para verificar TUDO relacionado
-- ao chat no banco de dados
-- =====================================================

-- =====================================================
-- 1. VERIFICAR SE A TABELA EXISTE
-- =====================================================
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name = 'chat_messages'
    ) THEN '✅ Tabela chat_messages EXISTE'
    ELSE '❌ Tabela chat_messages NÃO EXISTE - PROBLEMA CRÍTICO!'
  END as status_tabela;

-- =====================================================
-- 2. VERIFICAR ESTRUTURA DA TABELA
-- =====================================================
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default,
  character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- =====================================================
-- 3. VERIFICAR REALTIME
-- =====================================================
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'chat_messages'
    ) THEN '✅ REALTIME ATIVO'
    ELSE '❌ REALTIME DESATIVADO - PROBLEMA!'
  END as status_realtime,
  schemaname,
  tablename
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND schemaname = 'public' 
  AND tablename = 'chat_messages';

-- =====================================================
-- 4. VERIFICAR RLS (Row Level Security)
-- =====================================================
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS HABILITADO'
    ELSE '❌ RLS DESABILITADO - PROBLEMA!'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'chat_messages';

-- =====================================================
-- 5. VERIFICAR POLÍTICAS RLS
-- =====================================================
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN cmd = 'SELECT' THEN 'Ver mensagens'
    WHEN cmd = 'INSERT' THEN 'Enviar mensagens'
    WHEN cmd = 'UPDATE' THEN 'Editar mensagens'
    WHEN cmd = 'DELETE' THEN 'Deletar mensagens'
    ELSE cmd
  END as descricao,
  qual as condicao_select,
  with_check as condicao_insert
FROM pg_policies
WHERE tablename = 'chat_messages'
ORDER BY cmd, policyname;

-- Verificar se tem políticas suficientes
SELECT 
  CASE 
    WHEN COUNT(*) FILTER (WHERE cmd = 'SELECT') > 0 
         AND COUNT(*) FILTER (WHERE cmd = 'INSERT') > 0 
    THEN '✅ Políticas RLS OK'
    ELSE '❌ FALTAM POLÍTICAS RLS - PROBLEMA!'
  END as status_politicas,
  COUNT(*) FILTER (WHERE cmd = 'SELECT') as politicas_select,
  COUNT(*) FILTER (WHERE cmd = 'INSERT') as politicas_insert,
  COUNT(*) FILTER (WHERE cmd = 'DELETE') as politicas_delete
FROM pg_policies
WHERE tablename = 'chat_messages';

-- =====================================================
-- 6. VERIFICAR DADOS NA TABELA
-- =====================================================
-- Contagem total
SELECT 
  COUNT(*) as total_mensagens,
  COUNT(DISTINCT user_id) as usuarios_unicos,
  MIN(created_at) as primeira_mensagem,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages;

-- Mensagens recentes (últimas 24 horas)
SELECT 
  COUNT(*) as mensagens_ultimas_24h,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages
WHERE created_at > NOW() - INTERVAL '24 hours';

-- Últimas 10 mensagens
SELECT 
  id,
  user_id,
  LEFT(content, 50) as content_preview,
  created_at,
  NOW() - created_at as tempo_desde_criacao
FROM public.chat_messages
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- 7. VERIFICAR TRIGGERS
-- =====================================================
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'chat_messages'
ORDER BY trigger_name;

-- =====================================================
-- 8. VERIFICAR ÍNDICES
-- =====================================================
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'chat_messages'
ORDER BY indexname;

-- =====================================================
-- 9. VERIFICAR PERMISSÕES DA TABELA
-- =====================================================
SELECT 
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name = 'chat_messages'
ORDER BY grantee, privilege_type;

-- =====================================================
-- 10. VERIFICAR PUBLICAÇÃO REALTIME
-- =====================================================
SELECT 
  pubname,
  puballtables,
  pubinsert,
  pubupdate,
  pubdelete,
  pubtruncate
FROM pg_publication
WHERE pubname = 'supabase_realtime';

-- =====================================================
-- 11. TESTE DE INSERÇÃO (SIMULAÇÃO)
-- =====================================================
-- Verificar se um usuário autenticado conseguiria inserir
-- (não vai inserir de verdade, só verifica as políticas)
SELECT 
  'Teste de política INSERT' as teste,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies
      WHERE tablename = 'chat_messages'
        AND cmd = 'INSERT'
        AND (with_check = 'true' OR with_check LIKE '%auth.uid()%')
    ) THEN '✅ Política INSERT permite usuários autenticados'
    ELSE '❌ Política INSERT pode estar bloqueando'
  END as resultado;

-- =====================================================
-- 12. VERIFICAR SE HÁ ERROS DE INTEGRIDADE
-- =====================================================
-- Verificar mensagens sem user_id válido
SELECT 
  COUNT(*) as mensagens_sem_user_valido
FROM public.chat_messages cm
LEFT JOIN auth.users u ON cm.user_id = u.id
WHERE u.id IS NULL;

-- Verificar mensagens sem conteúdo
SELECT 
  COUNT(*) as mensagens_sem_conteudo
FROM public.chat_messages
WHERE content IS NULL OR content = '';

-- =====================================================
-- RESUMO FINAL
-- =====================================================
SELECT 
  '=== RESUMO DO DIAGNÓSTICO ===' as resumo,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'chat_messages')
    THEN '✅ Tabela existe'
    ELSE '❌ Tabela não existe'
  END as tabela,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'chat_messages')
    THEN '✅ Realtime ativo'
    ELSE '❌ Realtime desativado'
  END as realtime,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'chat_messages' AND rowsecurity)
    THEN '✅ RLS habilitado'
    ELSE '❌ RLS desabilitado'
  END as rls,
  CASE 
    WHEN (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'chat_messages' AND cmd = 'SELECT') > 0
         AND (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'chat_messages' AND cmd = 'INSERT') > 0
    THEN '✅ Políticas OK'
    ELSE '❌ Políticas faltando'
  END as politicas;

-- =====================================================
-- INSTRUÇÕES BASEADAS NO RESULTADO:
-- =====================================================
-- Se algum item mostrar ❌:
--   1. Execute CORRIGIR-REALTIME-CHAT-URGENTE.sql
--   2. Verifique os erros específicos acima
--   3. Entre em contato com suporte se persistir
-- =====================================================

