import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

// OneSignal App ID
const ONESIGNAL_APP_ID = import.meta.env.VITE_ONESIGNAL_APP_ID || 'e1e6712a-5457-4991-a922-f22b1f151c25';

// Declaração de tipos para OneSignal (SDK do navegador)
declare global {
  interface Window {
    OneSignal?: {
      init: (options: { appId: string; allowLocalhostAsSecureOrigin?: boolean }) => Promise<void>;
      isPushNotificationsEnabled: () => Promise<boolean>;
      showNativePrompt: () => Promise<void>;
      setNotificationOpenedHandler: (handler: (result: any) => void) => void;
      getUserId: () => Promise<string | null>;
      setExternalUserId: (userId: string) => Promise<void>;
      removeExternalUserId: () => Promise<void>;
      push: (args: any[]) => void;
      on: (event: string, callback: () => void) => void;
      off: (event: string, callback: () => void) => void;
      once: (event: string, callback: () => void) => void;
    };
  }
}

export function useOneSignal() {
  const { user } = useAuth();
  const [isSupported, setIsSupported] = useState(false);
  const [isSubscribed, setIsSubscribed] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    // Verificar se OneSignal está disponível
    const checkOneSignal = async () => {
      console.log('[OneSignal] ========== INICIANDO CHECK ==========');
      console.log('[OneSignal] Window disponível?', typeof window !== 'undefined');
      console.log('[OneSignal] OneSignal disponível?', !!window.OneSignal);
      console.log('[OneSignal] App ID:', ONESIGNAL_APP_ID);
      
      // Verificar se o script do OneSignal foi carregado
      if (typeof window === 'undefined') {
        console.error('[OneSignal] Window não disponível (SSR?)');
        setIsSupported(false);
        return;
      }

      if (!window.OneSignal) {
        console.log('[OneSignal] Script não carregado ainda, carregando...');
        
        // Verificar se já existe um script carregando
        const existingScript = document.querySelector('script[src*="OneSignal"]');
        if (existingScript) {
          console.log('[OneSignal] Script já existe, aguardando carregamento...');
          existingScript.addEventListener('load', () => {
            console.log('[OneSignal] Script existente carregado');
            initializeOneSignal();
          });
          return;
        }
        
        // Carregar o script do OneSignal
        const script = document.createElement('script');
        script.src = 'https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js';
        script.async = true;
        script.onload = () => {
          console.log('[OneSignal] ✅ Script carregado com sucesso');
          // Aguardar um pouco para garantir que OneSignal está disponível
          setTimeout(() => {
            if (window.OneSignal) {
              initializeOneSignal();
            } else {
              console.error('[OneSignal] ❌ OneSignal ainda não disponível após carregar script');
              setIsSupported(false);
            }
          }, 100);
        };
        script.onerror = (error) => {
          console.error('[OneSignal] ❌ Erro ao carregar script:', error);
          setIsSupported(false);
          toast.error('Erro ao carregar OneSignal. Verifique sua conexão.');
        };
        document.head.appendChild(script);
        console.log('[OneSignal] Script adicionado ao head');
      } else {
        console.log('[OneSignal] OneSignal já disponível, inicializando...');
        initializeOneSignal();
      }
    };

    const initializeOneSignal = async () => {
      try {
        console.log('[OneSignal] ========== INICIALIZANDO ==========');
        
        // Verificar se está em localhost - OneSignal pode não funcionar em dev
        const isLocalhost = window.location.hostname === 'localhost' || 
                           window.location.hostname === '127.0.0.1';
        
        if (!window.OneSignal) {
          console.error('[OneSignal] ❌ OneSignal não disponível após tentativa de carregar');
          setIsSupported(false);
          return;
        }

        console.log('[OneSignal] Inicializando com App ID:', ONESIGNAL_APP_ID);
        console.log('[OneSignal] Ambiente:', isLocalhost ? 'LOCALHOST (dev)' : 'PRODUÇÃO');
        console.log('[OneSignal] Tipo do OneSignal:', typeof window.OneSignal);
        console.log('[OneSignal] Métodos disponíveis:', Object.keys(window.OneSignal));
        
        // Inicializar OneSignal
        try {
          await window.OneSignal.init({
            appId: ONESIGNAL_APP_ID,
            allowLocalhostAsSecureOrigin: true, // Para desenvolvimento local
          });
          console.log('[OneSignal] ✅ Init chamado com sucesso');
        } catch (initError: any) {
          // Se o erro for de domínio não permitido, apenas desabilitar silenciosamente
          const errorMessage = initError?.message || String(initError) || '';
          if (errorMessage.includes('Can only be used on') || 
              errorMessage.includes('not allowed') ||
              errorMessage.includes('domain')) {
            console.warn('[OneSignal] ⚠️ OneSignal não está configurado para este domínio. Notificações push desabilitadas.');
            if (isLocalhost) {
              console.log('[OneSignal] 💡 Dica: No localhost, as notificações funcionarão apenas em produção.');
            }
            setIsSupported(false);
            setIsInitialized(true); // Marcar como inicializado para não ficar "carregando"
            return;
          }
          console.error('[OneSignal] ❌ Erro no init:', initError);
          throw initError;
        }

        console.log('[OneSignal] ✅ Inicializado com sucesso');
        setIsInitialized(true);
        setIsSupported(true);

        // Verificar se já está inscrito
        const isEnabled = await window.OneSignal.isPushNotificationsEnabled();
        console.log('[OneSignal] Push notifications habilitadas?', isEnabled);
        setIsSubscribed(isEnabled);

        // Configurar handler para quando notificação for aberta
        window.OneSignal.setNotificationOpenedHandler((result) => {
          console.log('[OneSignal] Notificação aberta:', result);
          // Você pode navegar para uma página específica aqui se necessário
        });

        // Associar user_id do Supabase ao OneSignal
        if (user) {
          try {
            const oneSignalUserId = await window.OneSignal.getUserId();
            console.log('[OneSignal] OneSignal User ID:', oneSignalUserId);
            
            if (oneSignalUserId) {
              // Associar o user_id do Supabase ao OneSignal
              await window.OneSignal.setExternalUserId(user.id);
              console.log('[OneSignal] ✅ User ID associado:', user.id);

              // Salvar a subscription no banco
              await saveSubscriptionToDatabase(oneSignalUserId, user.id);
            }
          } catch (error) {
            console.error('[OneSignal] Erro ao associar user_id:', error);
          }
        }

        // Listener para mudanças no status de subscription
        window.OneSignal.on('subscriptionChange', async (isSubscribed: boolean) => {
          console.log('[OneSignal] Status de subscription mudou:', isSubscribed);
          setIsSubscribed(isSubscribed);
          
          if (isSubscribed && user) {
            const oneSignalUserId = await window.OneSignal.getUserId();
            if (oneSignalUserId) {
              await saveSubscriptionToDatabase(oneSignalUserId, user.id);
            }
          }
        });

      } catch (error: any) {
        console.error('[OneSignal] Erro ao inicializar:', error);
        setIsSupported(false);
        setIsInitialized(true); // Marcar como inicializado mesmo com erro
        // Não mostrar toast de erro se for problema de domínio
        const errorMessage = error?.message || '';
        if (!errorMessage.includes('Can only be used on')) {
          console.warn('[OneSignal] Notificações push não disponíveis neste ambiente');
        }
      }
    };

    checkOneSignal();
  }, [user]);

  const saveSubscriptionToDatabase = async (oneSignalUserId: string, supabaseUserId: string) => {
    try {
      console.log('[OneSignal] Salvando subscription no banco...');
      
      const { error } = await supabase
        .from('push_subscriptions')
        .upsert({
          user_id: supabaseUserId,
          endpoint: `onesignal:${oneSignalUserId}`, // Formato especial para OneSignal
          p256dh: '', // OneSignal não usa essas chaves
          auth: '',
          user_agent: navigator.userAgent,
          updated_at: new Date().toISOString(),
        }, {
          onConflict: 'user_id,endpoint',
        });

      if (error) {
        console.error('[OneSignal] Erro ao salvar subscription:', error);
      } else {
        console.log('[OneSignal] ✅ Subscription salva no banco');
      }
    } catch (error) {
      console.error('[OneSignal] Erro ao salvar subscription:', error);
    }
  };

  const subscribe = async (): Promise<boolean> => {
    if (!isSupported || !window.OneSignal) {
      toast.error('OneSignal não está disponível');
      return false;
    }

    setIsLoading(true);

    try {
      console.log('[OneSignal] Solicitando permissão...');
      
      // Solicitar permissão e mostrar prompt nativo
      await window.OneSignal.showNativePrompt();
      
      // Verificar se foi habilitado
      const isEnabled = await window.OneSignal.isPushNotificationsEnabled();
      setIsSubscribed(isEnabled);

      if (isEnabled) {
        // Associar user_id se houver usuário logado
        if (user) {
          const oneSignalUserId = await window.OneSignal.getUserId();
          if (oneSignalUserId) {
            await window.OneSignal.setExternalUserId(user.id);
            await saveSubscriptionToDatabase(oneSignalUserId, user.id);
          }
        }

        toast.success('Notificações push ativadas!');
        return true;
      } else {
        toast.warning('Permissão de notificações negada');
        return false;
      }
    } catch (error: any) {
      console.error('[OneSignal] Erro ao subscrever:', error);
      toast.error('Erro ao ativar notificações: ' + (error.message || 'Erro desconhecido'));
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const unsubscribe = async (): Promise<boolean> => {
    if (!isSupported || !window.OneSignal) {
      return false;
    }

    setIsLoading(true);

    try {
      // OneSignal não tem um método direto para desabilitar
      // O usuário precisa desabilitar nas configurações do navegador
      // Mas podemos remover a associação do user_id
      if (user) {
        await window.OneSignal.removeExternalUserId();
        
        // Remover do banco
        const oneSignalUserId = await window.OneSignal.getUserId();
        if (oneSignalUserId) {
          await supabase
            .from('push_subscriptions')
            .delete()
            .eq('user_id', user.id)
            .eq('endpoint', `onesignal:${oneSignalUserId}`);
        }
      }

      setIsSubscribed(false);
      toast.success('Notificações push desativadas');
      return true;
    } catch (error: any) {
      console.error('[OneSignal] Erro ao cancelar subscription:', error);
      toast.error('Erro ao desativar notificações');
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    isSupported,
    isSubscribed,
    isLoading,
    isInitialized,
    subscribe,
    unsubscribe,
  };
}

