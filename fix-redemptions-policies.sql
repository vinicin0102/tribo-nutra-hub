-- Corrigir políticas RLS de redemptions para suporte
-- Execute este script no SQL Editor do Supabase

-- 1. Remover TODAS as políticas existentes (usando CASCADE se necessário)
DO $$ 
DECLARE
  pol record;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'redemptions'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.redemptions', pol.policyname);
  END LOOP;
END $$;

-- 2. Criar política para TODOS verem TODOS os resgates
CREATE POLICY "Everyone can view redemptions" 
ON public.redemptions 
FOR SELECT 
TO authenticated
USING (true);

-- 3. Criar política para TODOS atualizarem
CREATE POLICY "Everyone can update redemptions" 
ON public.redemptions 
FOR UPDATE 
TO authenticated
USING (true)
WITH CHECK (true);

-- 4. Criar política de INSERT apenas para o próprio usuário
CREATE POLICY "Users can create own redemptions" 
ON public.redemptions 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 5. Verificar políticas criadas
SELECT 
  'Políticas recriadas com sucesso!' as status;

SELECT 
  tablename, 
  policyname, 
  cmd as operacao
FROM pg_policies 
WHERE tablename = 'redemptions'
ORDER BY policyname;
