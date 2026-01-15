-- =====================================================
-- CRIAR PERFIS PARA TODOS OS USUÁRIOS QUE NÃO TÊM
-- =====================================================
-- Este script cria perfis na tabela profiles para todos
-- os usuários que estão em auth.users mas não têm perfil
-- Execute no Supabase SQL Editor
-- =====================================================

-- Criar perfis para usuários que não têm
INSERT INTO public.profiles (
  user_id,
  username,
  full_name,
  avatar_url,
  cpf,
  data_nascimento,
  telefone,
  email,
  points,
  created_at,
  updated_at
)
SELECT 
  u.id,
  COALESCE(
    u.raw_user_meta_data->>'username',
    split_part(u.email, '@', 1)
  ) as username,
  COALESCE(u.raw_user_meta_data->>'full_name', '') as full_name,
  u.raw_user_meta_data->>'avatar_url' as avatar_url,
  u.raw_user_meta_data->>'cpf' as cpf,
  CASE 
    WHEN u.raw_user_meta_data->>'data_nascimento' IS NOT NULL 
    THEN (u.raw_user_meta_data->>'data_nascimento')::DATE
    ELSE NULL
  END as data_nascimento,
  u.raw_user_meta_data->>'telefone' as telefone,
  u.email,
  0 as points,
  u.created_at,
  NOW() as updated_at
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.user_id = u.id
)
ON CONFLICT (user_id) DO NOTHING;

-- Mostrar quantos perfis foram criados
SELECT 
  COUNT(*) as total_perfis_criados
FROM public.profiles p
WHERE p.created_at >= NOW() - INTERVAL '5 minutes';

-- Verificar se ainda há usuários sem perfil
SELECT 
  COUNT(*) as usuarios_ainda_sem_perfil
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE p.user_id IS NULL;

-- =====================================================
-- LISTAR TODOS OS USUÁRIOS E SEUS PERFIS
-- =====================================================
SELECT 
  u.id as user_id,
  u.email,
  u.created_at as data_cadastro_auth,
  p.username,
  p.full_name,
  p.created_at as data_criacao_perfil,
  CASE 
    WHEN p.user_id IS NULL THEN '❌ SEM PERFIL'
    ELSE '✅ TEM PERFIL'
  END as status
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
ORDER BY u.created_at DESC;

