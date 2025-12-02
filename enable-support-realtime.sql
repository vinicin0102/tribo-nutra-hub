-- Habilitar Realtime para a tabela support_chat
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se a tabela support_chat existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'support_chat'
);

-- 2. Habilitar Realtime para a tabela support_chat
ALTER PUBLICATION supabase_realtime ADD TABLE support_chat;

-- 3. Verificar se foi habilitado
SELECT tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'support_chat';

-- 4. Garantir que as políticas RLS permitam SELECT em tempo real
-- (As políticas já devem estar configuradas, mas vamos verificar)
SELECT tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'support_chat';

