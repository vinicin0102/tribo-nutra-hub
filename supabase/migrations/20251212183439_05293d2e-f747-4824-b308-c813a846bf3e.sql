-- 1. Corrigir política de storage para permitir upload de imagens
DROP POLICY IF EXISTS "Authenticated users can upload files" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload images" ON storage.objects;

CREATE POLICY "Authenticated users can upload images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'images' 
  AND auth.uid() IS NOT NULL
);

-- 2. Garantir política de UPDATE para imagens
DROP POLICY IF EXISTS "Users can update own images" ON storage.objects;

CREATE POLICY "Users can update images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'images' 
  AND auth.uid() IS NOT NULL
);

-- 3. Garantir política de DELETE para imagens
DROP POLICY IF EXISTS "Users can delete own images" ON storage.objects;

CREATE POLICY "Users can delete images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'images' 
  AND auth.uid() IS NOT NULL
);

-- 4. Criar funções RPC SECURITY DEFINER para gerenciar badges (bypassa RLS)
CREATE OR REPLACE FUNCTION public.create_badge_admin(
  p_name TEXT,
  p_icon TEXT,
  p_description TEXT DEFAULT NULL,
  p_points_required INTEGER DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_role TEXT;
  v_badge_id UUID;
BEGIN
  -- Verificar se é admin
  SELECT role INTO v_caller_role FROM profiles WHERE user_id = auth.uid();
  
  IF v_caller_role IS NULL OR v_caller_role != 'admin' THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão. Apenas admins podem criar conquistas.');
  END IF;

  INSERT INTO badges (name, icon, description, points_required)
  VALUES (p_name, p_icon, p_description, p_points_required)
  RETURNING id INTO v_badge_id;

  RETURN json_build_object('success', true, 'id', v_badge_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.update_badge_admin(
  p_badge_id UUID,
  p_name TEXT DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_icon TEXT DEFAULT NULL,
  p_points_required INTEGER DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_role TEXT;
BEGIN
  -- Verificar se é admin
  SELECT role INTO v_caller_role FROM profiles WHERE user_id = auth.uid();
  
  IF v_caller_role IS NULL OR v_caller_role != 'admin' THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão. Apenas admins podem atualizar conquistas.');
  END IF;

  UPDATE badges 
  SET 
    name = COALESCE(p_name, name),
    description = COALESCE(p_description, description),
    icon = COALESCE(p_icon, icon),
    points_required = COALESCE(p_points_required, points_required)
  WHERE id = p_badge_id;

  RETURN json_build_object('success', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.delete_badge_admin(p_badge_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller_role TEXT;
BEGIN
  -- Verificar se é admin
  SELECT role INTO v_caller_role FROM profiles WHERE user_id = auth.uid();
  
  IF v_caller_role IS NULL OR v_caller_role != 'admin' THEN
    RETURN json_build_object('success', false, 'error', 'Sem permissão. Apenas admins podem excluir conquistas.');
  END IF;

  -- Deletar referências em user_badges primeiro
  DELETE FROM user_badges WHERE badge_id = p_badge_id;
  
  -- Deletar o badge
  DELETE FROM badges WHERE id = p_badge_id;

  RETURN json_build_object('success', true);
END;
$$;