-- =====================================================
-- 🔍 VERIFICAR FUNÇÃO handle_new_user EM DETALHES
-- =====================================================
-- Este script verifica se a função handle_new_user
-- está configurada corretamente para salvar todos os dados
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. Ver definição completa da função
SELECT 
  p.proname as function_name,
  pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
  AND p.proname = 'handle_new_user';

-- 2. Verificar se a função salva todos os campos necessários
-- (Verificar se menciona: email, cpf, telefone, data_nascimento, full_name)
SELECT 
  CASE 
    WHEN routine_definition LIKE '%email%' THEN '✅ Salva EMAIL'
    ELSE '❌ NÃO salva EMAIL'
  END as salva_email,
  CASE 
    WHEN routine_definition LIKE '%cpf%' THEN '✅ Salva CPF'
    ELSE '❌ NÃO salva CPF'
  END as salva_cpf,
  CASE 
    WHEN routine_definition LIKE '%telefone%' THEN '✅ Salva TELEFONE'
    ELSE '❌ NÃO salva TELEFONE'
  END as salva_telefone,
  CASE 
    WHEN routine_definition LIKE '%data_nascimento%' THEN '✅ Salva DATA_NASCIMENTO'
    ELSE '❌ NÃO salva DATA_NASCIMENTO'
  END as salva_data_nascimento,
  CASE 
    WHEN routine_definition LIKE '%full_name%' THEN '✅ Salva FULL_NAME'
    ELSE '❌ NÃO salva FULL_NAME'
  END as salva_full_name,
  CASE 
    WHEN routine_definition LIKE '%username%' THEN '✅ Salva USERNAME'
    ELSE '❌ NÃO salva USERNAME'
  END as salva_username
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

-- 3. Verificar parâmetros da função
SELECT 
  parameter_name,
  data_type,
  parameter_mode
FROM information_schema.parameters
WHERE specific_schema = 'public'
  AND specific_name LIKE 'handle_new_user%'
ORDER BY ordinal_position;

-- 4. Verificar se a função tem tratamento de erros
SELECT 
  CASE 
    WHEN routine_definition LIKE '%EXCEPTION%' THEN '✅ Tem tratamento de erros'
    ELSE '⚠️ Sem tratamento de erros'
  END as tratamento_erros,
  CASE 
    WHEN routine_definition LIKE '%ON CONFLICT%' THEN '✅ Tem ON CONFLICT'
    ELSE '⚠️ Sem ON CONFLICT'
  END as tem_on_conflict
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'handle_new_user';

