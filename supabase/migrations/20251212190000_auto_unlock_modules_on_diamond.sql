-- Função para desbloquear automaticamente todos os módulos quando o usuário assina Diamond
CREATE OR REPLACE FUNCTION public.auto_unlock_modules_on_diamond()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_module_id UUID;
  v_modules_unlocked INTEGER := 0;
BEGIN
  -- Verificar se o subscription_plan mudou para 'diamond'
  IF NEW.subscription_plan = 'diamond' AND (OLD.subscription_plan IS NULL OR OLD.subscription_plan != 'diamond') THEN
    -- Buscar todos os módulos bloqueados (is_locked = true)
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      INSERT INTO public.unlocked_modules (user_id, module_id)
      VALUES (NEW.user_id, v_module_id)
      ON CONFLICT (user_id, module_id) DO NOTHING;
      
      -- Contar apenas se foi inserido (não estava em conflito)
      IF FOUND THEN
        v_modules_unlocked := v_modules_unlocked + 1;
      END IF;
    END LOOP;
    
    -- Log detalhado
    RAISE NOTICE '✅ Módulos desbloqueados automaticamente para usuário %: % módulos', NEW.user_id, v_modules_unlocked;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Criar trigger que executa quando subscription_plan é atualizado
DROP TRIGGER IF EXISTS trigger_auto_unlock_modules_on_diamond ON public.profiles;
CREATE TRIGGER trigger_auto_unlock_modules_on_diamond
  AFTER UPDATE OF subscription_plan ON public.profiles
  FOR EACH ROW
  WHEN (NEW.subscription_plan = 'diamond' AND (OLD.subscription_plan IS NULL OR OLD.subscription_plan != 'diamond'))
  EXECUTE FUNCTION public.auto_unlock_modules_on_diamond();

-- Comentário explicativo
COMMENT ON FUNCTION public.auto_unlock_modules_on_diamond() IS 
'Desbloqueia automaticamente todos os módulos bloqueados quando o usuário assina o plano Diamond';

