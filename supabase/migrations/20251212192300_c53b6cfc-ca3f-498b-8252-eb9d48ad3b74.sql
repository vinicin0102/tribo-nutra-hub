-- Função para atribuir badges automaticamente baseado em pontos
CREATE OR REPLACE FUNCTION public.assign_badges_by_points()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Para cada badge que o usuário tem pontos suficientes, inserir se não existir
  INSERT INTO user_badges (user_id, badge_id)
  SELECT NEW.user_id, b.id
  FROM badges b
  WHERE b.points_required IS NOT NULL 
    AND b.points_required <= COALESCE(NEW.points, 0)
    AND NOT EXISTS (
      SELECT 1 FROM user_badges ub 
      WHERE ub.user_id = NEW.user_id AND ub.badge_id = b.id
    );
  
  RETURN NEW;
END;
$$;

-- Remover trigger existente se houver
DROP TRIGGER IF EXISTS on_points_updated ON profiles;

-- Trigger que executa quando pontos são atualizados
CREATE TRIGGER on_points_updated
  AFTER INSERT OR UPDATE OF points ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION assign_badges_by_points();