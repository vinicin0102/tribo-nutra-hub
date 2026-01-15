-- Garantir que a coluna is_locked existe na tabela modules
ALTER TABLE public.modules ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT false;

-- Função para desbloquear automaticamente todos os módulos quando o usuário assina Diamond
CREATE OR REPLACE FUNCTION public.auto_unlock_modules_on_diamond()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_module_id UUID;
  v_modules_unlocked INTEGER := 0;
  v_total_locked_modules INTEGER;
  v_already_unlocked INTEGER;
BEGIN
  -- Verificar se o subscription_plan mudou para 'diamond'
  IF NEW.subscription_plan = 'diamond' AND (OLD.subscription_plan IS NULL OR OLD.subscription_plan != 'diamond') THEN
    -- Contar total de módulos bloqueados
    SELECT COUNT(*) INTO v_total_locked_modules
    FROM public.modules 
    WHERE is_locked = true;
    
    -- Se não houver módulos bloqueados, não fazer nada
    IF v_total_locked_modules = 0 THEN
      RAISE NOTICE 'ℹ️  Nenhum módulo bloqueado encontrado para desbloquear para usuário %', NEW.user_id;
      RETURN NEW;
    END IF;
    
    -- Contar quantos módulos já estão desbloqueados
    SELECT COUNT(*) INTO v_already_unlocked
    FROM public.unlocked_modules um
    INNER JOIN public.modules m ON m.id = um.module_id
    WHERE um.user_id = NEW.user_id AND m.is_locked = true;
    
    -- Buscar todos os módulos bloqueados (is_locked = true)
    FOR v_module_id IN 
      SELECT id FROM public.modules WHERE is_locked = true
    LOOP
      -- Inserir na tabela unlocked_modules se ainda não existir
      BEGIN
        INSERT INTO public.unlocked_modules (user_id, module_id)
        VALUES (NEW.user_id, v_module_id)
        ON CONFLICT (user_id, module_id) DO NOTHING;
        
        -- Verificar se foi inserido (não estava em conflito)
        IF FOUND THEN
          v_modules_unlocked := v_modules_unlocked + 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Log erro mas continua com os outros módulos
          RAISE WARNING '⚠️  Erro ao desbloquear módulo % para usuário %: %', v_module_id, NEW.user_id, SQLERRM;
      END;
    END LOOP;
    
    -- Log detalhado do resultado
    RAISE NOTICE '✅ Liberação automática concluída para usuário %: % novos módulos desbloqueados (total: % de % bloqueados)', 
      NEW.user_id, v_modules_unlocked, (v_already_unlocked + v_modules_unlocked), v_total_locked_modules;
    
    -- Validar se todos foram desbloqueados
    IF (v_already_unlocked + v_modules_unlocked) < v_total_locked_modules THEN
      RAISE WARNING '⚠️  Apenas % de % módulos bloqueados estão desbloqueados. Verifique se há problemas de permissão.', 
        (v_already_unlocked + v_modules_unlocked), v_total_locked_modules;
    END IF;
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

