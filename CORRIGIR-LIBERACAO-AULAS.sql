-- =====================================================
-- CORREÇÃO: Liberação de Aulas por Primeiro Login
-- =====================================================
-- Este script adiciona o campo first_login_at para rastrear
-- a data do primeiro login do usuário, que será usado
-- como base para a liberação das aulas em X dias.
-- =====================================================

-- 1. Adicionar coluna first_login_at na tabela profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS first_login_at TIMESTAMP WITH TIME ZONE;

-- 2. Preencher first_login_at para usuários existentes
-- Usando a data mais antiga disponível: 
-- primeiro registro em daily_points OU created_at do perfil
UPDATE profiles p
SET first_login_at = COALESCE(
    (
        SELECT MIN(dp.created_at)
        FROM daily_points dp
        WHERE dp.user_id = p.user_id
    ),
    p.created_at
)
WHERE first_login_at IS NULL;

-- 3. Criar função para definir first_login_at no primeiro login
CREATE OR REPLACE FUNCTION set_first_login_at()
RETURNS TRIGGER AS $$
BEGIN
    -- Somente define first_login_at se ainda não foi definido
    IF NEW.first_login_at IS NULL THEN
        NEW.first_login_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Remover trigger existente se houver
DROP TRIGGER IF EXISTS trigger_set_first_login_at ON profiles;

-- 5. Criar trigger para definir first_login_at automaticamente
-- Isso será acionado quando a tabela daily_points for atualizada
-- Mas como já temos o update acima, os existentes já estarão cobertos

-- 6. Criar função para o trigger de daily_points
CREATE OR REPLACE FUNCTION update_first_login_on_daily_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza first_login_at no perfil se ainda não foi definido
    UPDATE profiles
    SET first_login_at = NOW()
    WHERE user_id = NEW.user_id
    AND first_login_at IS NULL;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Remover trigger existente se houver
DROP TRIGGER IF EXISTS trigger_update_first_login ON daily_points;

-- 8. Criar trigger na tabela daily_points
CREATE TRIGGER trigger_update_first_login
AFTER INSERT ON daily_points
FOR EACH ROW
EXECUTE FUNCTION update_first_login_on_daily_points();

-- 9. Verificar resultado
SELECT 
    user_id,
    username,
    first_login_at,
    created_at,
    subscription_plan
FROM profiles
ORDER BY created_at DESC
LIMIT 10;

-- =====================================================
-- IMPORTANTE: Execute este script no Supabase SQL Editor
-- =====================================================
