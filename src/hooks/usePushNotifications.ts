import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { validateAndConvertVAPIDKey } from '@/utils/vapidKeyValidator';

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
    const checkSupport = async () => {
      const hasServiceWorker = 'serviceWorker' in navigator;
      const hasPushManager = 'PushManager' in window;
      const hasNotification = 'Notification' in window;
      
      console.log('[Push] Verificação de suporte:');
      console.log('[Push] - Service Worker?', hasServiceWorker);
      console.log('[Push] - PushManager?', hasPushManager);
      console.log('[Push] - Notification?', hasNotification);
      console.log('[Push] - User Agent:', navigator.userAgent);
      console.log('[Push] - É HTTPS?', window.location.protocol === 'https:' || window.location.hostname === 'localhost');
      
      // Verificação básica - Chrome, Firefox, Edge suportam
      let basicSupport = hasServiceWorker && hasPushManager && hasNotification;
      
      // Verificar se está em contexto seguro (HTTPS ou localhost)
      const isSecureContext = window.location.protocol === 'https:' || window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
      
      if (!isSecureContext) {
        console.warn('[Push] - Contexto não seguro. Push notifications requerem HTTPS.');
        basicSupport = false;
      }
      
      // Verificação adicional: tentar obter o Service Worker
      // NÃO desabilitar se o Service Worker não estiver pronto ainda
      if (basicSupport) {
        try {
          // Tentar obter Service Worker pronto (com timeout)
          const registrationPromise = navigator.serviceWorker.ready;
          const timeoutPromise = new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Timeout')), 3000)
          );
          
          try {
            const registration = await Promise.race([registrationPromise, timeoutPromise]) as ServiceWorkerRegistration;
            console.log('[Push] - Service Worker pronto?', !!registration);
            console.log('[Push] - PushManager disponível?', !!registration.pushManager);
            
            // Verificar se PushManager realmente funciona
            if (registration.pushManager) {
              // Tentar obter subscription existente (não cria nova, só verifica se funciona)
              try {
                await registration.pushManager.getSubscription();
                console.log('[Push] - PushManager funcional?', true);
              } catch (pmError: any) {
                console.warn('[Push] - PushManager pode ter problemas:', pmError.message);
                // Mesmo com erro, pode funcionar - não desabilitar
              }
            } else {
              console.warn('[Push] - PushManager não disponível no Service Worker');
              // Não desabilitar, pode estar carregando ainda
            }
          } catch (swError: any) {
            console.warn('[Push] - Service Worker não está pronto ainda:', swError.message);
            console.log('[Push] - Mas continuando, pois pode estar carregando...');
            // NÃO desabilitar - o Service Worker pode estar carregando
            // O Chrome suporta push notifications mesmo se o SW ainda não estiver pronto
          }
        } catch (swError: any) {
          console.warn('[Push] - Erro ao verificar Service Worker:', swError.message);
          // NÃO desabilitar - pode ser apenas um problema temporário
        }
      }
      
      console.log('[Push] - Suportado?', basicSupport);
      setIsSupported(basicSupport);
    };
    
    checkSupport();
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
    try {
      console.log('[Push] ========== INÍCIO subscribe() ==========');
      console.log('[Push] User:', user ? 'existe' : 'não existe');
      console.log('[Push] isSupported:', isSupported);
      
      if (!user || !isSupported) {
        console.error('[Push] ❌ Push notifications não disponíveis');
        toast.error('Push notifications não disponíveis');
        return false;
      }

      setIsLoading(true);
      console.log('[Push] Loading setado para true');

      // Solicitar permissão
      console.log('[Push] Solicitando permissão...');
      const hasPermission = await requestPermission();
      console.log('[Push] Permissão:', hasPermission ? 'CONCEDIDA ✅' : 'NEGADA ❌');
      
      if (!hasPermission) {
        console.error('[Push] ❌ Permissão negada pelo usuário');
        setIsLoading(false);
        return false;
      }

      // Obter registration do service worker
      console.log('[Push] Aguardando Service Worker ficar pronto...');
      let registration;
      try {
        registration = await navigator.serviceWorker.ready;
        console.log('[Push] ✅ Service Worker pronto!');
      } catch (swError: any) {
        console.error('[Push] ❌ Erro ao obter Service Worker:', swError);
        toast.error('Erro ao acessar Service Worker. Recarregue a página.');
        setIsLoading(false);
        return false;
      }
      
      if (!registration || !registration.pushManager) {
        console.error('[Push] ❌ PushManager não disponível');
        toast.error('PushManager não disponível neste navegador.');
        setIsLoading(false);
        return false;
      }

      // Obter VAPID public key - TENTAR DO BACKEND PRIMEIRO
      console.log('[Push] ========== VERIFICAÇÃO DA CHAVE VAPID ==========');
      
      let vapidPublicKey: string | null = null;
      
      // Tentativa 1: Buscar do backend (Edge Function)
      console.log('[Push] Tentativa 1: Buscando chave do backend...');
      try {
        const { data, error } = await supabase.functions.invoke('get-vapid-public-key');
        if (!error && data?.vapidPublicKey) {
          vapidPublicKey = data.vapidPublicKey;
          console.log('[Push] ✅ Chave obtida do backend!');
        } else {
          console.warn('[Push] ⚠️ Não foi possível obter do backend:', error?.message || 'Sem dados');
        }
      } catch (backendError: any) {
        console.warn('[Push] ⚠️ Erro ao buscar do backend:', backendError.message);
      }
      
      // Tentativa 2: Usar variável de ambiente
      if (!vapidPublicKey) {
        console.log('[Push] Tentativa 2: Buscando chave do .env...');
        const vapidFromEnv = import.meta.env.VITE_VAPID_PUBLIC_KEY;
        if (vapidFromEnv) {
          vapidPublicKey = vapidFromEnv;
          console.log('[Push] ✅ Chave obtida do .env!');
        } else {
          console.warn('[Push] ⚠️ Chave não encontrada no .env');
        }
      }
      
      // Tentativa 3: Chave de fallback (hardcoded)
      if (!vapidPublicKey) {
        console.log('[Push] Tentativa 3: Usando chave de fallback...');
        vapidPublicKey = 'BGlpREcbTdz2SRMHeOGGCBCeRGwqx6i9LpcSXg6dD1_yPkLSCNV6TDWtlHNGYPHe6mqKoiW5TVPtBi2lCY3w7xY';
        console.warn('[Push] ⚠️ Usando chave de fallback (hardcoded)');
      }
      
      if (!vapidPublicKey) {
        toast.error('Chave VAPID não encontrada. Entre em contato com o suporte.');
        console.error('[Push] ❌ Nenhuma chave VAPID encontrada');
        setIsLoading(false);
        return false;
      }
      
      // Limpar a chave
      const cleanKey = vapidPublicKey.trim().replace(/\s/g, '').replace(/\n/g, '').replace(/\r/g, '');
      
      console.log('[Push] Chave final, tamanho:', cleanKey.length);
      console.log('[Push] Primeiros 20 chars:', cleanKey.substring(0, 20));
      console.log('[Push] Últimos 20 chars:', cleanKey.substring(cleanKey.length - 20));
      
      if (cleanKey.length < 80 || cleanKey.length > 200) {
        toast.error(`Chave VAPID inválida (${cleanKey.length} chars). Esperado: ~87`);
        console.error('[Push] ❌ Tamanho inválido');
        setIsLoading(false);
        return false;
      }

      // Criar subscription
<<<<<<< HEAD
      let subscription;
      try {
        console.log('[Push] ========== CONVERSÃO DA CHAVE ==========');
        
        // Tentar converter a chave
        let applicationServerKey: Uint8Array;
        try {
          applicationServerKey = validateAndConvertVAPIDKey(cleanKey);
          console.log('[Push] ✅ Conversão bem-sucedida!');
        } catch (convertError: any) {
          console.error('[Push] ❌ Erro na conversão:', convertError);
          throw new Error(`Falha ao converter chave: ${convertError.message}`);
        }
        
        console.log('[Push] Tamanho do Uint8Array:', applicationServerKey.length, 'bytes');
        console.log('[Push] Primeiro byte:', applicationServerKey[0], '(esperado: 4)');
        console.log('[Push] Último byte:', applicationServerKey[applicationServerKey.length - 1]);
        console.log('[Push] É Uint8Array?', applicationServerKey instanceof Uint8Array);
        console.log('[Push] Constructor:', applicationServerKey.constructor.name);
        
        // Verificar se já existe uma subscription antiga
        console.log('[Push] Verificando subscriptions antigas...');
        const existingSubscription = await registration.pushManager.getSubscription();
        if (existingSubscription) {
          console.log('[Push] ⚠️ Subscription antiga encontrada, removendo...');
          try {
            await existingSubscription.unsubscribe();
            console.log('[Push] ✅ Subscription antiga removida');
          } catch (e: any) {
            console.warn('[Push] ⚠️ Erro ao remover subscription antiga:', e.message);
          }
        } else {
          console.log('[Push] ✅ Nenhuma subscription antiga encontrada');
        }
        
        // Tentar criar subscription - MÚLTIPLAS TENTATIVAS
        console.log('[Push] ========== CRIANDO SUBSCRIPTION ==========');
        console.log('[Push] PushManager disponível?', !!registration.pushManager);
        console.log('[Push] Tipo do PushManager:', typeof registration.pushManager);
        
        // Criar cópia limpa do Uint8Array
        console.log('[Push] Criando cópia limpa do Uint8Array...');
        const cleanKey = new Uint8Array(applicationServerKey);
        console.log('[Push] Cópia criada:');
        console.log('[Push] - Tamanho:', cleanKey.length, 'bytes');
        console.log('[Push] - Primeiro byte:', cleanKey[0], '(esperado: 4)');
        console.log('[Push] - É Uint8Array?', cleanKey instanceof Uint8Array);
        console.log('[Push] - ByteLength:', cleanKey.byteLength);
        
        // Validação final EXTREMA
        if (cleanKey.length !== 65 || cleanKey[0] !== 4) {
          const errorMsg = `Chave inválida: tamanho=${cleanKey.length}, primeiro byte=${cleanKey[0]}`;
          console.error('[Push] ❌ VALIDAÇÃO FINAL FALHOU:', errorMsg);
          throw new Error(errorMsg);
        }
        
        console.log('[Push] Chave validada, tentando criar subscription...');
        
        subscription = await registration.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: cleanKey,
        });
        
        console.log('[Push] ✅✅✅ SUBSCRIPTION CRIADA COM SUCESSO!');
        console.log('[Push] Endpoint:', subscription.endpoint);
        console.log('[Push] Keys disponíveis:', Object.keys(subscription));
      } catch (keyError: any) {
        console.error('[Push] ========== ERRO AO CRIAR SUBSCRIPTION ==========');
        console.error('[Push] Nome do erro:', keyError.name);
        console.error('[Push] Mensagem:', keyError.message);
        console.error('[Push] Stack completo:', keyError.stack);
        console.error('[Push] Erro completo:', keyError);
        
        // Logs adicionais para debug
        console.error('[Push] Tipo do applicationServerKey:', typeof applicationServerKey);
        console.error('[Push] applicationServerKey é Uint8Array?', applicationServerKey instanceof Uint8Array);
        if (applicationServerKey) {
          console.error('[Push] Tamanho:', applicationServerKey.length);
          console.error('[Push] Primeiro byte:', applicationServerKey[0]);
        }
        
        // Mensagens de erro mais específicas
        let errorMessage = 'Erro ao ativar notificações';
        if (keyError.message?.includes('applicationServerKey')) {
          errorMessage = 'Chave VAPID inválida. A chave deve ser uma chave P-256 válida.';
          console.error('[Push] ⚠️ Erro relacionado à chave VAPID');
        } else if (keyError.name === 'InvalidStateError') {
          errorMessage = 'Estado inválido. Verifique se o Service Worker está ativo.';
          console.error('[Push] ⚠️ Erro de estado inválido');
        } else if (keyError.message?.includes('not supported')) {
          errorMessage = 'Push notifications não são suportadas neste navegador.';
          console.error('[Push] ⚠️ Não suportado');
        } else {
          errorMessage = `Erro: ${keyError.message || keyError.toString() || 'Erro desconhecido'}`;
        }
        
        toast.error(errorMessage);
        setIsLoading(false);
        return false;
      }
=======
      const applicationServerKey = urlBase64ToUint8Array(vapidPublicKey);
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: applicationServerKey.buffer as ArrayBuffer,
      });
>>>>>>> 0a382979dc4f2c1e20e52d6bb4875238a4d78c84

      // Converter subscription para formato salvável
      const subscriptionData: PushSubscriptionData = {
        endpoint: subscription.endpoint,
        keys: {
          p256dh: arrayBufferToBase64(subscription.getKey('p256dh')!),
          auth: arrayBufferToBase64(subscription.getKey('auth')!),
        },
      };

      // Salvar no banco de dados
<<<<<<< HEAD
      console.log('[Push] Tentando salvar subscription no banco...');
      const { error, data } = await supabase
        .from('push_subscriptions')
=======
      const { error } = await getPushSubscriptionsTable()
>>>>>>> 0a382979dc4f2c1e20e52d6bb4875238a4d78c84
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
        console.error('[Push] ❌ Erro ao salvar subscription:', error);
        console.error('[Push] Código do erro:', error.code);
        console.error('[Push] Mensagem:', error.message);
        console.error('[Push] Detalhes:', error.details);
        
        // Se for erro de conexão, avisar mas não falhar completamente
        if (error.message?.includes('network') || error.message?.includes('connection') || error.code === 'PGRST116') {
          toast.warning('Subscription criada, mas não foi possível salvar no servidor. Verifique sua conexão.');
          console.warn('[Push] ⚠️ Subscription criada localmente, mas não salva no servidor devido a erro de conexão');
          // Ainda consideramos sucesso porque a subscription foi criada
        } else {
          toast.error('Erro ao salvar subscription no servidor: ' + (error.message || 'Erro desconhecido'));
          return false;
        }
      } else {
        console.log('[Push] ✅ Subscription salva no banco com sucesso!');
        if (data) {
          console.log('[Push] Dados salvos:', data);
        }
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
  try {
    console.log('[Push] Convertendo chave VAPID para Uint8Array...');
    console.log('[Push] String original, tamanho:', base64String.length);
    
    // Remover espaços, quebras de linha e caracteres inválidos
    const cleanString = base64String
      .trim()
      .replace(/\s/g, '')
      .replace(/\n/g, '')
      .replace(/\r/g, '');
    
    console.log('[Push] String limpa, tamanho:', cleanString.length);
    
    // Validar que contém apenas caracteres base64 URL-safe
    if (!/^[A-Za-z0-9_-]+$/.test(cleanString)) {
      throw new Error('Chave contém caracteres inválidos. Deve ser base64 URL-safe.');
    }
    
    // Adicionar padding se necessário
    const padding = '='.repeat((4 - (cleanString.length % 4)) % 4);
    console.log('[Push] Padding necessário:', padding.length);
    
    // Converter de URL-safe base64 para base64 padrão
    const base64 = (cleanString + padding)
      .replace(/-/g, '+')
      .replace(/_/g, '/');

    console.log('[Push] Tentando decodificar base64...');
    
    // Decodificar base64
    let rawData: string;
    try {
      rawData = window.atob(base64);
    } catch (e) {
      console.error('[Push] Erro ao decodificar base64:', e);
      throw new Error('Falha ao decodificar base64. Chave pode estar corrompida.');
    }
    
    console.log('[Push] Base64 decodificado, tamanho:', rawData.length, 'bytes');
    
    // Verificar se o tamanho está correto (chave P-256 deve ter 65 bytes = 520 bits)
    if (rawData.length !== 65) {
      console.error(`[Push] ⚠️ Tamanho incorreto: ${rawData.length} bytes (esperado: 65 bytes para P-256)`);
      console.error('[Push] Primeiros bytes:', Array.from(rawData.slice(0, 10).split('').map(c => c.charCodeAt(0))).join(','));
      throw new Error(`Chave VAPID tem tamanho incorreto: ${rawData.length} bytes (esperado: 65 bytes). A chave pode estar corrompida ou no formato errado.`);
    }
    
    // Verificar primeiro byte (deve ser 0x04 para formato não comprimido)
    const firstByte = rawData.charCodeAt(0);
    if (firstByte !== 0x04) {
      console.warn('[Push] ⚠️ Primeiro byte não é 0x04:', firstByte, '(esperado: 4 para formato não comprimido)');
    }
    
    const outputArray = new Uint8Array(rawData.length);

    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    
    console.log('[Push] ✅ Chave convertida com sucesso!');
    console.log('[Push] Primeiro byte:', outputArray[0], '(deve ser 4)');
    console.log('[Push] Último byte:', outputArray[outputArray.length - 1]);
    
    return outputArray;
  } catch (error) {
    console.error('[Push] ❌ Erro ao converter chave VAPID:', error);
    if (error instanceof Error) {
      throw new Error(`Falha ao converter chave VAPID: ${error.message}`);
    }
    throw new Error('Falha ao converter chave VAPID: Erro desconhecido');
  }
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}
