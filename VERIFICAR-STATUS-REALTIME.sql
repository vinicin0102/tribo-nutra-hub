-- =====================================================
-- VERIFICAR STATUS DO REALTIME
-- =====================================================
-- Execute este script para verificar o status atual
-- do Realtime no Supabase
-- =====================================================

-- 1. Verificar todas as tabelas com Realtime ativo
SELECT 
  schemaname,
  tablename,
  'REALTIME ATIVO' as status
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND schemaname = 'public'
ORDER BY tablename;

-- 2. Verificar especificamente chat_messages
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'chat_messages'
    ) THEN '✅ REALTIME ATIVO para chat_messages'
    ELSE '❌ REALTIME DESATIVADO para chat_messages'
  END as status_chat;

-- 3. Verificar se a tabela existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name = 'chat_messages'
    ) THEN '✅ Tabela chat_messages existe'
    ELSE '❌ Tabela chat_messages NÃO existe'
  END as status_tabela;

-- 4. Verificar RLS
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity THEN '✅ RLS HABILITADO'
    ELSE '❌ RLS DESABILITADO'
  END as rls_status
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'chat_messages';

-- 5. Listar todas as políticas RLS
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN cmd = 'SELECT' THEN 'Ver mensagens'
    WHEN cmd = 'INSERT' THEN 'Enviar mensagens'
    WHEN cmd = 'DELETE' THEN 'Deletar mensagens'
    ELSE cmd
  END as descricao
FROM pg_policies
WHERE tablename = 'chat_messages'
ORDER BY cmd, policyname;

-- 6. Contar mensagens na tabela
SELECT 
  COUNT(*) as total_mensagens,
  COUNT(DISTINCT user_id) as usuarios_unicos,
  MIN(created_at) as primeira_mensagem,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages;

-- 7. Verificar publicação realtime
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
-- INTERPRETAÇÃO DOS RESULTADOS:
-- =====================================================
-- Se status_chat mostrar "❌ REALTIME DESATIVADO":
--   → Execute CORRIGIR-REALTIME-CHAT-URGENTE.sql
--
-- Se status_tabela mostrar "❌ Tabela NÃO existe":
--   → A tabela precisa ser criada (problema grave)
--
-- Se rls_status mostrar "❌ RLS DESABILITADO":
--   → Execute CORRIGIR-REALTIME-CHAT-URGENTE.sql
--
-- Se não houver políticas RLS:
--   → Execute CORRIGIR-REALTIME-CHAT-URGENTE.sql
-- =====================================================

