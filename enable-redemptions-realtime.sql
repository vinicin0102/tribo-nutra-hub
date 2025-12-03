-- Habilitar Realtime para a tabela redemptions
-- Execute este script no SQL Editor do Supabase

-- Habilitar Realtime para redemptions
ALTER PUBLICATION supabase_realtime ADD TABLE redemptions;

-- Verificar se foi habilitado
SELECT tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'redemptions';

-- Mensagem de confirmação
SELECT 'Realtime habilitado para redemptions!' as status;

