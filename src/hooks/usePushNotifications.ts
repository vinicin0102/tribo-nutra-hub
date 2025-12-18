import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

interface PushSubscriptionData {
  endpoint: string;
  keys: {
    p256dh: string;
    auth: string;
  };
}

// Helper para acessar tabela push_subscriptions (que será criada via migration)
const getPushSubscriptionsTable = () => {
  return (supabase as any).from('push_subscriptions');
};

export function usePushNotifications() {
  const { user } = useAuth();
  const [isSupported, setIsSupported] = useState(false);
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Verificar se o navegador suporta push notifications
    setIsSupported(
      'serviceWorker' in navigator &&
      'PushManager' in window &&
      'Notification' in window
    );
  }, []);

  useEffect(() => {
    if (user && isSupported) {
      checkSubscriptionStatus();
    }
  }, [user, isSupported]);

  const checkSubscriptionStatus = async () => {
    if (!user || !isSupported) return;

    try {
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.getSubscription();

      if (subscription) {
        // Verificar se está salvo no banco
        const { data } = await getPushSubscriptionsTable()
          .select('id')
          .eq('user_id', user.id)
          .eq('endpoint', subscription.endpoint)
          .single();

        setIsSubscribed(!!data);
      } else {
        setIsSubscribed(false);
      }
    } catch (error) {
      console.error('Erro ao verificar subscription:', error);
      setIsSubscribed(false);
    }
  };

  const requestPermission = async (): Promise<boolean> => {
    if (!isSupported) {
      toast.error('Push notifications não são suportadas neste navegador');
      return false;
    }

    const permission = await Notification.requestPermission();
    
    if (permission !== 'granted') {
      toast.error('Permissão de notificações negada');
      return false;
    }

    return true;
  };

  const subscribe = async (): Promise<boolean> => {
    if (!user || !isSupported) {
      toast.error('Push notifications não disponíveis');
      return false;
    }

    setIsLoading(true);

    try {
      // Solicitar permissão
      const hasPermission = await requestPermission();
      if (!hasPermission) {
        setIsLoading(false);
        return false;
      }

      // Obter registration do service worker
      const registration = await navigator.serviceWorker.ready;

      // Obter VAPID public key
      // Se não estiver configurada, usar uma chave de exemplo (não funcionará, mas não quebra)
      const vapidPublicKey = import.meta.env.VITE_VAPID_PUBLIC_KEY || 
        'BEl62iUYgUivxIkv69yViEuiBIa40HI8nVz8J7b8K5Q';

      // Criar subscription
      const applicationServerKey = urlBase64ToUint8Array(vapidPublicKey);
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: applicationServerKey.buffer as ArrayBuffer,
      });

      // Converter subscription para formato salvável
      const subscriptionData: PushSubscriptionData = {
        endpoint: subscription.endpoint,
        keys: {
          p256dh: arrayBufferToBase64(subscription.getKey('p256dh')!),
          auth: arrayBufferToBase64(subscription.getKey('auth')!),
        },
      };

      // Salvar no banco de dados
      const { error } = await getPushSubscriptionsTable()
        .upsert({
          user_id: user.id,
          endpoint: subscriptionData.endpoint,
          p256dh: subscriptionData.keys.p256dh,
          auth: subscriptionData.keys.auth,
          user_agent: navigator.userAgent,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'user_id,endpoint',
        });

      if (error) {
        console.error('Erro ao salvar subscription:', error);
        toast.error('Erro ao ativar notificações');
        return false;
      }

      setIsSubscribed(true);
      toast.success('Notificações push ativadas!');
      return true;
    } catch (error: any) {
      console.error('Erro ao subscrever push notifications:', error);
      
      // Mensagens de erro mais específicas
      if (error.message?.includes('VAPID')) {
        toast.error('Chave VAPID não configurada. Configure VITE_VAPID_PUBLIC_KEY no .env');
      } else if (error.message?.includes('permission')) {
        toast.error('Permissão de notificações negada');
      } else {
        toast.error(`Erro: ${error.message || 'Erro desconhecido'}`);
      }
      
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const unsubscribe = async (): Promise<boolean> => {
    if (!user || !isSupported) {
      return false;
    }

    setIsLoading(true);

    try {
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.getSubscription();

      if (subscription) {
        // Remover do banco
        const { error } = await getPushSubscriptionsTable()
          .delete()
          .eq('user_id', user.id)
          .eq('endpoint', subscription.endpoint);

        if (error) {
          console.error('Erro ao remover subscription:', error);
        }

        // Cancelar subscription
        await subscription.unsubscribe();
      }

      setIsSubscribed(false);
      toast.success('Notificações push desativadas');
      return true;
    } catch (error: any) {
      console.error('Erro ao cancelar subscription:', error);
      toast.error(`Erro: ${error.message || 'Erro desconhecido'}`);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    isSupported,
    isSubscribed,
    isLoading,
    subscribe,
    unsubscribe,
    requestPermission,
  };
}

// Funções auxiliares
function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}
