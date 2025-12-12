-- Habilitar Realtime para a tabela profiles
-- Isso permite que os pontos sejam atualizados em tempo real quando mudarem no banco

-- Adicionar tabela profiles à publicação realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;

-- Verificar se foi adicionado
SELECT 
  schemaname,
  tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename = 'profiles';

-- Se a query acima retornar uma linha, está funcionando!

