-- Script de debug para verificar resgates
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar se há resgates na tabela
SELECT COUNT(*) as total_resgates FROM redemptions;

-- 2. Ver todos os resgates (sem RLS)
SELECT 
  r.id,
  r.user_id,
  r.reward_id,
  r.points_spent,
  r.status,
  r.created_at,
  u.email as user_email,
  p.username,
  rw.name as reward_name
FROM redemptions r
LEFT JOIN auth.users u ON r.user_id = u.id
LEFT JOIN profiles p ON r.user_id = p.user_id
LEFT JOIN rewards rw ON r.reward_id = rw.id
ORDER BY r.created_at DESC
LIMIT 10;

-- 3. Verificar políticas RLS da tabela redemptions
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'redemptions';

-- 4. Criar política para suporte ver todos os resgates
DROP POLICY IF EXISTS "Support can view all redemptions" ON public.redemptions;

CREATE POLICY "Support can view all redemptions" 
ON public.redemptions 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND role IN ('support', 'admin')
  )
);

-- 5. Criar política para suporte atualizar resgates
DROP POLICY IF EXISTS "Support can update redemptions" ON public.redemptions;

CREATE POLICY "Support can update redemptions" 
ON public.redemptions 
FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE user_id = auth.uid()
    AND role IN ('support', 'admin')
  )
);

-- 6. Verificar as novas políticas
SELECT 'Políticas criadas!' as status;

SELECT policyname, cmd
FROM pg_policies 
WHERE tablename = 'redemptions'
ORDER BY policyname;

