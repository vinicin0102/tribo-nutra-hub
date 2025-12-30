-- =====================================================
-- CRIAR FUNÇÃO RPC PARA ATUALIZAR MÓDULO
-- =====================================================
-- Esta função permite atualizar módulos sem depender
-- do schema cache do PostgREST
-- =====================================================

-- 1. Primeiro, garantir que a coluna existe
ALTER TABLE modules ADD COLUMN IF NOT EXISTS unlock_date TIMESTAMPTZ DEFAULT NULL;

-- 2. Criar função RPC para atualizar módulo
CREATE OR REPLACE FUNCTION update_module_with_unlock_date(
  p_id UUID,
  p_title TEXT DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_course_id UUID DEFAULT NULL,
  p_order_index INTEGER DEFAULT NULL,
  p_is_published BOOLEAN DEFAULT NULL,
  p_is_locked BOOLEAN DEFAULT NULL,
  p_unlock_date TIMESTAMPTZ DEFAULT NULL,
  p_cover_url TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  UPDATE modules SET
    title = COALESCE(p_title, title),
    description = COALESCE(p_description, description),
    course_id = COALESCE(p_course_id, course_id),
    order_index = COALESCE(p_order_index, order_index),
    is_published = COALESCE(p_is_published, is_published),
    is_locked = COALESCE(p_is_locked, is_locked),
    unlock_date = p_unlock_date, -- Permite NULL explícito
    cover_url = p_cover_url, -- Permite NULL explícito
    updated_at = now()
  WHERE id = p_id;

  SELECT row_to_json(m) INTO result
  FROM modules m
  WHERE m.id = p_id;

  RETURN result;
END;
$$;

-- 3. Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION update_module_with_unlock_date TO authenticated;

-- 4. Criar função similar para criar módulo
CREATE OR REPLACE FUNCTION create_module_with_unlock_date(
  p_title TEXT,
  p_description TEXT DEFAULT NULL,
  p_course_id UUID DEFAULT NULL,
  p_order_index INTEGER DEFAULT 0,
  p_is_published BOOLEAN DEFAULT false,
  p_is_locked BOOLEAN DEFAULT false,
  p_unlock_date TIMESTAMPTZ DEFAULT NULL,
  p_cover_url TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
  new_id UUID;
BEGIN
  INSERT INTO modules (title, description, course_id, order_index, is_published, is_locked, unlock_date, cover_url)
  VALUES (p_title, p_description, p_course_id, p_order_index, p_is_published, p_is_locked, p_unlock_date, p_cover_url)
  RETURNING id INTO new_id;

  SELECT row_to_json(m) INTO result
  FROM modules m
  WHERE m.id = new_id;

  RETURN result;
END;
$$;

-- 5. Dar permissão
GRANT EXECUTE ON FUNCTION create_module_with_unlock_date TO authenticated;

-- 6. Forçar reload do schema
NOTIFY pgrst, 'reload schema';
SELECT pg_notify('pgrst', 'reload schema');

-- Verificar se as funções foram criadas
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%module%unlock%';
