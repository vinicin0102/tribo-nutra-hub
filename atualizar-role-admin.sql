-- =====================================================
-- Script para dar permissões de ADMIN ao usuário
-- Email: auxiliodp1@gmail.com
-- =====================================================

-- Atualizar o role do usuário para 'admin'
UPDATE profiles
SET role = 'admin'
WHERE email = 'auxiliodp1@gmail.com';

-- Verificar se foi atualizado
SELECT user_id, username, email, role 
FROM profiles 
WHERE email = 'auxiliodp1@gmail.com';

-- =====================================================
-- INSTRUÇÕES:
-- 1. Acesse o Supabase Dashboard
-- 2. Vá em SQL Editor
-- 3. Cole e execute este script
-- 4. Verifique se o role foi atualizado para 'admin'
-- =====================================================
