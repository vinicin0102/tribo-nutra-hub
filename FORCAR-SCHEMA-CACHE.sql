-- =====================================================
-- FORÇAR ATUALIZAÇÃO DO SCHEMA CACHE DO SUPABASE
-- =====================================================
-- Execute este script APÓS adicionar a coluna unlock_date
-- =====================================================

-- 1. Verificar se a coluna existe
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'modules' AND column_name = 'unlock_date';

-- 2. Se a coluna não apareceu, criar ela novamente
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_date TIMESTAMPTZ DEFAULT NULL;

-- 3. FORÇAR reload do schema do PostgREST (método 1)
NOTIFY pgrst, 'reload schema';

-- 4. FORÇAR reload do schema do PostgREST (método 2)
SELECT pg_notify('pgrst', 'reload schema');

-- 5. FORÇAR reload do schema do PostgREST (método 3)
SELECT pg_notify('pgrst', 'reload config');

-- =====================================================
-- IMPORTANTE: APÓS EXECUTAR ESTE SCRIPT
-- =====================================================
-- 
-- Opção 1: Vá em "Project Settings" > "API" e clique em 
--          "Reload schema cache" se houver esse botão
--
-- Opção 2: Aguarde 1-2 minutos e tente novamente
--
-- Opção 3: Faça um pequeno ALTER na tabela para forçar:
-- =====================================================

-- 6. Truque para forçar atualização do cache - renomear e voltar
DO $$
BEGIN
  -- Tentar criar um comentário na tabela força o cache a atualizar
  COMMENT ON TABLE modules IS 'Módulos dos cursos - atualizado em ' || now()::text;
END $$;

-- 7. Verificar novamente
SELECT 
  'modules' as tabela,
  column_name, 
  data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'modules'
  AND column_name IN ('unlock_date', 'is_locked', 'unlock_after_days')
ORDER BY column_name;

-- =====================================================
-- SE AINDA NÃO FUNCIONAR:
-- Vá em Settings > API e copie a URL do projeto
-- Depois acesse: https://SEU-PROJETO.supabase.co/rest/v1/
-- Isso força o PostgREST a recarregar
-- =====================================================
