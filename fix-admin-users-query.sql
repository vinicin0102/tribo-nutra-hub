-- =====================================================
-- VERIFICAR E CORRIGIR QUERY DE USUÁRIOS PARA ADMIN
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- 1. Verificar quantos perfis existem
SELECT COUNT(*) as total_profiles FROM public.profiles;

-- 2. Verificar se há usuários com email
SELECT 
  p.id,
  p.user_id,
  p.username,
  p.role,
  u.email
FROM public.profiles p
LEFT JOIN auth.users u ON u.id = p.user_id
ORDER BY p.created_at DESC
LIMIT 10;

-- 3. Verificar política RLS de profiles
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'profiles';

-- 4. Garantir que a política permite SELECT para todos
DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
CREATE POLICY "Profiles are viewable by everyone" 
  ON public.profiles FOR SELECT 
  USING (true);

-- 5. Verificar se admin@gmail.com tem perfil
SELECT 
  p.*,
  u.email
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE u.email = 'admin@gmail.com';

-- =====================================================
-- PRONTO! 🎉
-- =====================================================

