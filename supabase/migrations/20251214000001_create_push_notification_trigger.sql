-- Função para log de push notifications (para debug)
-- Nota: Para enviar push notifications reais, você precisa criar uma Edge Function
-- que use a biblioteca web-push com as chaves VAPID privadas
CREATE OR REPLACE FUNCTION public.log_push_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  subscription_count INTEGER;
BEGIN
  -- Contar quantas subscriptions o usuário tem
  SELECT COUNT(*) INTO subscription_count
  FROM public.push_subscriptions
  WHERE user_id = NEW.user_id;
  
  -- Log para debug (você pode remover isso em produção)
  RAISE NOTICE 'Nova notificação criada para usuário %: % - % subscriptions ativas', 
    NEW.user_id, NEW.title, subscription_count;
  
  -- Aqui você pode adicionar lógica para chamar uma Edge Function
  -- que enviará a push notification usando web-push
  -- Exemplo: PERFORM net.http_post(...) para chamar Edge Function
  
  RETURN NEW;
END;
$$;

-- Trigger para log quando notificação é criada
DROP TRIGGER IF EXISTS on_notification_created ON public.notifications;
CREATE TRIGGER on_notification_created
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  WHEN (NEW.read = false)
  EXECUTE FUNCTION public.log_push_notification();

COMMENT ON FUNCTION public.log_push_notification() IS 
'Função de trigger que loga quando uma notificação é criada. Para enviar push notifications reais, crie uma Edge Function que use web-push.';

