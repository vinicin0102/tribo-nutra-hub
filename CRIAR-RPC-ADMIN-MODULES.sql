-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ATUALIZAR MÓDULO COMPLETO
-- =====================================================
-- Esta função contorna o problema do schema cache
-- porque funções RPC são resolvidas no banco, não no PostgREST
-- =====================================================

-- 1. Garantir que a coluna existe
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_after_days INTEGER DEFAULT 0;

-- 2. Criar função para atualizar módulo
CREATE OR REPLACE FUNCTION admin_update_module(
  p_id UUID,
  p_title TEXT,
  p_description TEXT,
  p_course_id UUID,
  p_order_index INTEGER,
  p_is_published BOOLEAN,
  p_is_locked BOOLEAN,
  p_unlock_after_days INTEGER,
  p_cover_url TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  UPDATE modules SET
    title = p_title,
    description = p_description,
    course_id = p_course_id,
    order_index = p_order_index,
    is_published = p_is_published,
    is_locked = p_is_locked,
    unlock_after_days = p_unlock_after_days,
    cover_url = p_cover_url,
    updated_at = now()
  WHERE id = p_id;

  SELECT row_to_json(m) INTO result
  FROM modules m
  WHERE m.id = p_id;

  RETURN result;
END;
$$;

-- 3. Criar função para criar módulo
CREATE OR REPLACE FUNCTION admin_create_module(
  p_title TEXT,
  p_description TEXT,
  p_course_id UUID,
  p_order_index INTEGER,
  p_is_published BOOLEAN,
  p_is_locked BOOLEAN,
  p_unlock_after_days INTEGER,
  p_cover_url TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  new_id UUID;
BEGIN
  INSERT INTO modules (title, description, course_id, order_index, is_published, is_locked, unlock_after_days, cover_url)
  VALUES (p_title, p_description, p_course_id, p_order_index, p_is_published, p_is_locked, p_unlock_after_days, p_cover_url)
  RETURNING id INTO new_id;

  SELECT row_to_json(m) INTO result
  FROM modules m
  WHERE m.id = new_id;

  RETURN result;
END;
$$;

-- 4. Dar permissões
GRANT EXECUTE ON FUNCTION admin_update_module TO authenticated;
GRANT EXECUTE ON FUNCTION admin_create_module TO authenticated;

-- 5. Forçar reload
NOTIFY pgrst, 'reload schema';

-- 6. Verificar
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE 'admin_%module%';

-- =====================================================
-- RESULTADO ESPERADO:
-- | routine_name        |
-- |---------------------|
-- | admin_update_module |
-- | admin_create_module |
-- =====================================================
