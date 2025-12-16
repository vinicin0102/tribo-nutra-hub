-- =====================================================
-- TESTAR INSERÇÃO DE MENSAGEM NO CHAT
-- =====================================================
-- Este script vai testar se conseguimos inserir
-- uma mensagem diretamente no banco
-- =====================================================

-- 1. Verificar políticas RLS de INSERT
SELECT 
  policyname,
  cmd,
  with_check as condicao_insert,
  qual as condicao_select
FROM pg_policies
WHERE tablename = 'chat_messages'
  AND cmd = 'INSERT';

-- 2. Verificar se RLS está bloqueando
SELECT 
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'chat_messages';

-- 3. Verificar se há alguma política que permite INSERT
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Existe política INSERT'
    ELSE '❌ NÃO EXISTE POLÍTICA INSERT - PROBLEMA!'
  END as status_politica_insert,
  COUNT(*) as total_politicas_insert
FROM pg_policies
WHERE tablename = 'chat_messages'
  AND cmd = 'INSERT';

-- 4. Verificar conteúdo das políticas INSERT
SELECT 
  policyname,
  with_check,
  CASE 
    WHEN with_check LIKE '%auth.uid()%' OR with_check = 'true' THEN '✅ Permite usuários autenticados'
    WHEN with_check IS NULL THEN '⚠️ Sem condição (pode estar bloqueando)'
    ELSE '❌ Condição pode estar bloqueando'
  END as analise
FROM pg_policies
WHERE tablename = 'chat_messages'
  AND cmd = 'INSERT';

-- =====================================================
-- CORREÇÃO URGENTE: Recriar política INSERT
-- =====================================================

-- Remover política INSERT existente (se houver)
DROP POLICY IF EXISTS "Authenticated users can insert chat messages" ON public.chat_messages;

-- Criar política INSERT que permite qualquer usuário autenticado
CREATE POLICY "Authenticated users can insert chat messages" ON public.chat_messages
  FOR INSERT 
  WITH CHECK (auth.uid() IS NOT NULL);

-- Verificar se foi criada
SELECT 
  '✅ Política INSERT recriada' as status,
  policyname,
  with_check
FROM pg_policies
WHERE tablename = 'chat_messages'
  AND cmd = 'INSERT';

-- =====================================================
-- TESTE: Tentar inserir uma mensagem de teste
-- (Só funciona se você estiver autenticado como admin)
-- =====================================================
-- Descomente as linhas abaixo para testar:
-- INSERT INTO public.chat_messages (user_id, content)
-- VALUES (
--   (SELECT id FROM auth.users LIMIT 1),
--   'Mensagem de teste do SQL'
-- );
-- SELECT '✅ Mensagem de teste inserida' as resultado;

