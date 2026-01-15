-- =====================================================
-- VERIFICAR E CORRIGIR RLS PARA MÓDULOS
-- =====================================================
-- Execute este script no Supabase SQL Editor
-- =====================================================

-- 1. Verificar se a coluna unlock_date existe
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'modules' AND column_name = 'unlock_date';

-- 2. Verificar políticas RLS atuais na tabela modules
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'modules';

-- 3. Se não houver política de UPDATE para admins, criar uma
-- Primeiro, vamos garantir que admins podem atualizar módulos

-- Verificar se RLS está ativo
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname = 'modules';

-- 4. Criar política permissiva para admins atualizarem módulos
DO $$
BEGIN
  -- Tentar dropar política existente de update se existir
  DROP POLICY IF EXISTS "Admins can update modules" ON modules;
  
  -- Criar nova política
  CREATE POLICY "Admins can update modules" ON modules
    FOR UPDATE
    USING (
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE profiles.id = auth.uid() 
        AND profiles.role = 'admin'
      )
    );
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Erro ao criar política: %', SQLERRM;
END $$;

-- 5. Ou simplesmente permitir que usuários autenticados atualizem (mais simples)
DO $$
BEGIN
  DROP POLICY IF EXISTS "Authenticated users can update modules" ON modules;
  
  CREATE POLICY "Authenticated users can update modules" ON modules
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Erro ao criar política: %', SQLERRM;
END $$;

-- 6. Verificar novamente as políticas
SELECT policyname, cmd, permissive
FROM pg_policies 
WHERE tablename = 'modules';
