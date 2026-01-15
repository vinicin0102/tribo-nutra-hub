-- =====================================================
-- VERIFICAR E CORRIGIR CHAT - SUPABASE
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- para diagnosticar e corrigir problemas no chat
-- =====================================================

-- 1. Verificar se a tabela chat_messages existe
SELECT 
  table_name,
  table_schema
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages';

-- 2. Verificar estrutura da tabela
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'chat_messages'
ORDER BY ordinal_position;

-- 3. Verificar se realtime está habilitado
SELECT 
  schemaname,
  tablename,
  CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' 
        AND schemaname = 'public' 
        AND tablename = 'chat_messages'
    ) THEN 'HABILITADO'
    ELSE 'DESABILITADO'
  END AS realtime_status
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'chat_messages';

-- 4. Verificar políticas RLS
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'chat_messages'
ORDER BY policyname;

-- 5. Verificar se RLS está habilitado
SELECT 
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'chat_messages';

-- 6. CORRIGIR: Habilitar realtime para chat_messages
DO $$
BEGIN
  -- Adicionar tabela à publicação realtime se não estiver
  IF NOT EXISTS (
    SELECT 1 
    FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'chat_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
    RAISE NOTICE '✅ Realtime habilitado para chat_messages';
  ELSE
    RAISE NOTICE 'ℹ️ Realtime já está habilitado para chat_messages';
  END IF;
END $$;

-- 7. CORRIGIR: Garantir que RLS está habilitado
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- 8. CORRIGIR: Criar/atualizar políticas RLS se não existirem
DO $$
BEGIN
  -- Política para SELECT (todos podem ver mensagens)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'chat_messages' 
    AND policyname = 'Anyone can view chat messages'
  ) THEN
    CREATE POLICY "Anyone can view chat messages" ON public.chat_messages
      FOR SELECT USING (true);
    RAISE NOTICE '✅ Política SELECT criada';
  ELSE
    RAISE NOTICE 'ℹ️ Política SELECT já existe';
  END IF;

  -- Política para INSERT (usuários autenticados podem inserir)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'chat_messages' 
    AND policyname = 'Authenticated users can insert chat messages'
  ) THEN
    CREATE POLICY "Authenticated users can insert chat messages" ON public.chat_messages
      FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
    RAISE NOTICE '✅ Política INSERT criada';
  ELSE
    RAISE NOTICE 'ℹ️ Política INSERT já existe';
  END IF;

  -- Política para DELETE (usuários podem deletar suas próprias mensagens)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'chat_messages' 
    AND policyname = 'Users can delete own chat messages'
  ) THEN
    CREATE POLICY "Users can delete own chat messages" ON public.chat_messages
      FOR DELETE USING (auth.uid() = user_id);
    RAISE NOTICE '✅ Política DELETE criada';
  ELSE
    RAISE NOTICE 'ℹ️ Política DELETE já existe';
  END IF;

  -- Política para DELETE (suporte/admin pode deletar qualquer mensagem)
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'chat_messages' 
    AND policyname = 'Support can delete any chat messages'
  ) THEN
    CREATE POLICY "Support can delete any chat messages" ON public.chat_messages
      FOR DELETE USING (
        EXISTS (
          SELECT 1 FROM public.profiles 
          WHERE user_id = auth.uid() 
          AND role IN ('support', 'admin')
        )
      );
    RAISE NOTICE '✅ Política DELETE para suporte criada';
  ELSE
    RAISE NOTICE 'ℹ️ Política DELETE para suporte já existe';
  END IF;
END $$;

-- 9. Verificar últimas mensagens do chat (para debug)
SELECT 
  id,
  user_id,
  LEFT(content, 50) as content_preview,
  created_at
FROM public.chat_messages
ORDER BY created_at DESC
LIMIT 10;

-- 10. Verificar contagem total de mensagens
SELECT COUNT(*) as total_messages FROM public.chat_messages;

-- =====================================================
-- RESUMO DAS CORREÇÕES:
-- =====================================================
-- ✅ Realtime habilitado para chat_messages
-- ✅ RLS habilitado
-- ✅ Políticas RLS criadas/verificadas:
--    - SELECT: Todos podem ver
--    - INSERT: Usuários autenticados podem inserir
--    - DELETE: Usuários podem deletar próprias mensagens
--    - DELETE: Suporte/admin pode deletar qualquer mensagem
-- =====================================================

