import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

// OneSignal App ID
const ONESIGNAL_APP_ID = import.meta.env.VITE_ONESIGNAL_APP_ID || 'e1e6712a-5457-4991-a922-f22b1f151c25';

// Declaração de tipos para OneSignal (SDK v16 do navegador)
declare global {
  interface Window {
    oneSignalInitialized?: boolean;
    OneSignal?: {
      init: (options: {
        appId: string;
        allowLocalhostAsSecureOrigin?: boolean;
        autoResubscribe?: boolean;
        notifyButton?: {
          enable?: boolean;
        };
        promptOptions?: {
          slidedown?: {
            prompts?: Array<{
              type: string;
              autoPrompt?: boolean;
              text?: {
                actionMessage?: string;
                acceptButton?: string;
                cancelButton?: string;
              };
              delay?: {
                pageViews?: number;
                timeDelay?: number;
              };
            }>;
          };
        };
      }) => Promise<void>;
      // API v16 - Namespace Notifications
      Notifications: {
        permission: boolean;
        permissionNative: 'default' | 'granted' | 'denied';
        requestPermission: () => Promise<void>;
        addEventListener: (event: string, callback: (data?: any) => void) => void;
        removeEventListener: (event: string, callback: (data?: any) => void) => void;
      };
      // API v16 - Namespace User
      User: {
        PushSubscription: {
          id: string | null | undefined;
          optedIn: boolean;
          optIn: () => Promise<void>;
          optOut: () => Promise<void>;
          addEventListener: (event: string, callback: (data?: any) => void) => void;
          removeEventListener: (event: string, callback: (data?: any) => void) => void;
        };
        addAlias: (label: string, id: string) => void;
        removeAlias: (label: string) => void;
        addTag: (key: string, value: string) => void;
        removeTag: (key: string) => void;
      };
      // API v16 - Login/Logout
      login: (externalId: string) => Promise<void>;
      logout: () => Promise<void>;
      // Métodos legados (podem não existir na v16)
      push: (args: any[]) => void;
      on: (event: string, callback: (data?: any) => void) => void;
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
      // Verificar se já foi inicializado globalmente
      if (window.oneSignalInitialized) {
        console.log('[OneSignal] SDK já inicializado globalmente, pulando...');
        setIsInitialized(true);
        setIsSupported(true);

        // Apenas verificar status atual usando API v16
        try {
          if (window.OneSignal?.User?.PushSubscription) {
            const isEnabled = window.OneSignal.User.PushSubscription.optedIn;
            setIsSubscribed(isEnabled);
          }
        } catch (e) {
          console.warn('[OneSignal] Erro ao verificar status:', e);
        }
        return;
      }

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
            autoResubscribe: true,
            notifyButton: {
              enable: false, // Desabilitar botão de notificação flutuante
            },
            promptOptions: {
              slidedown: {
                prompts: [
                  {
                    type: "push",
                    autoPrompt: false, // Desabilitar prompt automático - usamos nosso prompt customizado
                    text: {
                      actionMessage: "Receba notificações sobre novos conteúdos, promoções exclusivas e atualizações. Você pode desativar a qualquer momento.",
                      acceptButton: "Ativar",
                      cancelButton: "Agora não"
                    },
                    delay: {
                      pageViews: 1,
                      timeDelay: 5
                    }
                  }
                ]
              }
            }
          });
          console.log('[OneSignal] ✅ Init chamado com sucesso');
          window.oneSignalInitialized = true; // Marcar como inicializado globalmente
        } catch (initError: any) {
          // Se o erro for de domínio não permitido ou SDK já inicializado
          const errorMessage = initError?.message || String(initError) || '';

          // Se já foi inicializado, apenas marcar e continuar
          if (errorMessage.includes('already initialized') || errorMessage.includes('SDK already')) {
            console.log('[OneSignal] SDK já foi inicializado anteriormente');
            window.oneSignalInitialized = true;
            setIsSupported(true);
            setIsInitialized(true);
            return;
          }

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
          // Não lançar erro - apenas continuar silenciosamente
          setIsInitialized(true);
          return;
        }

        console.log('[OneSignal] ✅ Inicializado com sucesso');
        setIsInitialized(true);
        setIsSupported(true);

        // Verificar se já está inscrito usando API v16
        const isEnabled = window.OneSignal.User?.PushSubscription?.optedIn || false;
        console.log('[OneSignal] Push notifications habilitadas?', isEnabled);
        setIsSubscribed(isEnabled);

        // Configurar handler para mudanças na subscription usando API v16
        window.OneSignal.User?.PushSubscription?.addEventListener('change', (event: any) => {
          console.log('[OneSignal] Subscription mudou:', event);
          const subscribed = event?.current?.optedIn || false;
          setIsSubscribed(subscribed);
        });

        // Associar user_id do Supabase ao OneSignal usando API v16
        if (user) {
          try {
            const oneSignalUserId = window.OneSignal.User?.PushSubscription?.id;
            console.log('[OneSignal] OneSignal User ID:', oneSignalUserId);

            if (oneSignalUserId) {
              // Associar o user_id do Supabase ao OneSignal usando login
              await window.OneSignal.login(user.id);
              console.log('[OneSignal] ✅ User ID associado:', user.id);

              // Salvar a subscription no banco
              await saveSubscriptionToDatabase(oneSignalUserId, user.id);
            }
          } catch (error) {
            console.error('[OneSignal] Erro ao associar user_id:', error);
          }
        }

        // Listener para mudanças no status de subscription já foi configurado acima

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
      console.log('[OneSignal] Solicitando permissão usando API v16...');

      // Solicitar permissão usando a nova API v16
      await window.OneSignal.Notifications.requestPermission();

      // Fazer opt-in na subscription
      await window.OneSignal.User.PushSubscription.optIn();

      // Verificar se foi habilitado usando API v16
      const isEnabled = window.OneSignal.User?.PushSubscription?.optedIn || false;
      setIsSubscribed(isEnabled);

      if (isEnabled) {
        // Associar user_id se houver usuário logado usando API v16
        if (user) {
          const oneSignalUserId = window.OneSignal.User?.PushSubscription?.id;
          if (oneSignalUserId) {
            await window.OneSignal.login(user.id);
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
      // Usar optOut da API v16 para desinscrever
      await window.OneSignal.User.PushSubscription.optOut();

      // Remover associação do user_id usando logout
      if (user) {
        await window.OneSignal.logout();

        // Remover do banco
        const oneSignalUserId = window.OneSignal.User?.PushSubscription?.id;
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

