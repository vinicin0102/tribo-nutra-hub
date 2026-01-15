-- =====================================================
-- 🔍 VERIFICAR SE OS DADOS EXISTEM PARA O PAINEL ADMIN
-- =====================================================
-- Este script verifica se email e telefone existem
-- na tabela profiles para aparecer no painel admin
-- Execute no Supabase SQL Editor
-- =====================================================

-- 1. Verificar quantos perfis têm email e telefone
SELECT 
  COUNT(*) as total_perfis,
  COUNT(*) FILTER (WHERE email IS NOT NULL AND email != '') as perfis_com_email,
  COUNT(*) FILTER (WHERE telefone IS NOT NULL AND telefone != '') as perfis_com_telefone,
  COUNT(*) FILTER (WHERE email IS NOT NULL AND telefone IS NOT NULL AND email != '' AND telefone != '') as perfis_com_email_e_telefone
FROM public.profiles;

-- 2. Listar alguns perfis com seus dados
SELECT 
  user_id,
  username,
  full_name,
  email,
  telefone,
  points,
  created_at
FROM public.profiles
ORDER BY created_at DESC
LIMIT 10;

-- 3. Verificar se há perfis sem email ou telefone mas com dados em auth.users
SELECT 
  p.user_id,
  p.username,
  p.email as email_profile,
  p.telefone as telefone_profile,
  u.email as email_auth,
  u.raw_user_meta_data->>'telefone' as telefone_auth,
  CASE 
    WHEN p.email IS NULL AND u.email IS NOT NULL THEN '❌ Falta email em profile'
    WHEN p.telefone IS NULL AND u.raw_user_meta_data->>'telefone' IS NOT NULL THEN '❌ Falta telefone em profile'
    ELSE '✅ OK'
  END as status
FROM public.profiles p
JOIN auth.users u ON u.id = p.user_id
WHERE (p.email IS NULL OR p.telefone IS NULL)
  AND (u.email IS NOT NULL OR u.raw_user_meta_data->>'telefone' IS NOT NULL)
ORDER BY p.created_at DESC
LIMIT 20;

