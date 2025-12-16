-- =====================================================
-- CORRIGIR REALTIME DO CHAT - URGENTE
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- para FORÇAR a ativação do Realtime no chat
-- =====================================================

-- 1. REMOVER a tabela da publicação realtime (se estiver)
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS public.chat_messages;

-- 2. ADICIONAR novamente para garantir que está ativo
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- 3. Verificar se foi adicionado corretamente
SELECT 
  schemaname,
  tablename,
  'REALTIME ATIVO ✅' as status
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
  AND schemaname = 'public' 
  AND tablename = 'chat_messages';

-- 4. Garantir que RLS está habilitado
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- 5. Verificar políticas RLS existentes
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN cmd = 'SELECT' THEN '✅ SELECT permitido'
    WHEN cmd = 'INSERT' THEN '✅ INSERT permitido'
    WHEN cmd = 'DELETE' THEN '✅ DELETE permitido'
    ELSE cmd
  END as status
FROM pg_policies
WHERE tablename = 'chat_messages'
ORDER BY policyname;

-- 6. Criar/atualizar políticas RLS (forçar recriação)
DROP POLICY IF EXISTS "Anyone can view chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Authenticated users can insert chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Users can delete own chat messages" ON public.chat_messages;
DROP POLICY IF EXISTS "Support can delete any chat messages" ON public.chat_messages;

-- Recriar políticas
CREATE POLICY "Anyone can view chat messages" ON public.chat_messages
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert chat messages" ON public.chat_messages
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can delete own chat messages" ON public.chat_messages
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Support can delete any chat messages" ON public.chat_messages
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE user_id = auth.uid() 
      AND role IN ('support', 'admin')
    )
  );

-- 7. Verificar estrutura da tabela
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- 8. Verificar últimas mensagens (para confirmar que a tabela está funcionando)
SELECT 
  id,
  user_id,
  LEFT(content, 30) as content_preview,
  created_at
FROM public.chat_messages
ORDER BY created_at DESC
LIMIT 5;

-- 9. Verificar se há mensagens recentes (últimas 24 horas)
SELECT 
  COUNT(*) as mensagens_ultimas_24h,
  MAX(created_at) as ultima_mensagem
FROM public.chat_messages
WHERE created_at > NOW() - INTERVAL '24 hours';

-- =====================================================
-- RESUMO DAS CORREÇÕES APLICADAS:
-- =====================================================
-- ✅ Realtime FORÇADO para chat_messages
-- ✅ RLS habilitado
-- ✅ Políticas RLS recriadas (garantindo que estão corretas)
-- ✅ Estrutura da tabela verificada
-- =====================================================
-- 
-- APÓS EXECUTAR ESTE SCRIPT:
-- 1. Recarregue a página do chat
-- 2. Tente enviar uma mensagem
-- 3. Verifique o console do navegador (F12) para ver os logs
-- 4. A mensagem deve aparecer imediatamente
-- =====================================================

