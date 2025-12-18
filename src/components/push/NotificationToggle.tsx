import { Bell, BellOff } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { usePushNotifications } from '@/hooks/usePushNotifications';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export function NotificationToggle() {
  console.log('[Push] NotificationToggle renderizando...');
  
  const { isSupported, isSubscribed, isLoading, subscribe, unsubscribe } = usePushNotifications();
  
  console.log('[Push] Hook retornou:');
  console.log('[Push] - isSupported:', isSupported);
  console.log('[Push] - isSubscribed:', isSubscribed);
  console.log('[Push] - isLoading:', isLoading);
  console.log('[Push] - subscribe existe?', typeof subscribe === 'function');
  console.log('[Push] - unsubscribe existe?', typeof unsubscribe === 'function');

  const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  
  if (!isSupported) {
    console.log('[Push] Navegador não suportado, mostrando mensagem');
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="text-white flex items-center gap-2">
            <BellOff className="h-5 w-5 text-gray-400" />
            Notificações Push
          </CardTitle>
          <CardDescription>
            {isSafari 
              ? 'Safari tem suporte limitado a push notifications. Para melhor experiência, use Chrome, Firefox ou Edge no desktop, ou instale o app PWA no iOS.'
              : 'Seu navegador não suporta notificações push. Use Chrome, Firefox ou Edge para ativar.'}
          </CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
      <CardHeader>
        <CardTitle className="text-white flex items-center gap-2">
          {isSubscribed ? (
            <>
              <Bell className="h-5 w-5 text-primary" />
              Notificações Ativadas
            </>
          ) : (
            <>
              <BellOff className="h-5 w-5 text-gray-400" />
              Notificações Desativadas
            </>
          )}
        </CardTitle>
        <CardDescription>
          {isSubscribed
            ? 'Você receberá notificações push no seu dispositivo quando houver novas mensagens, comentários ou atualizações'
            : 'Ative para receber notificações push no seu dispositivo'}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Button
          onClick={(e) => {
            e.preventDefault();
            e.stopPropagation();
            
            console.log('[Push] ========== BOTÃO CLICADO ==========');
            console.log('[Push] Event:', e);
            console.log('[Push] isSubscribed:', isSubscribed);
            console.log('[Push] isLoading:', isLoading);
            console.log('[Push] disabled?', isLoading);
            console.log('[Push] subscribe tipo:', typeof subscribe);
            console.log('[Push] unsubscribe tipo:', typeof unsubscribe);
            
            if (isLoading) {
              console.log('[Push] ⚠️ Botão está disabled (isLoading=true)');
              return;
            }
            
            const handler = async () => {
              try {
                if (isSubscribed) {
                  console.log('[Push] Chamando unsubscribe...');
                  await unsubscribe();
                } else {
                  console.log('[Push] Chamando subscribe...');
                  await subscribe();
                }
              } catch (error: any) {
                console.error('[Push] Erro ao executar função:', error);
                console.error('[Push] Erro completo:', error);
                console.error('[Push] Stack:', error?.stack);
              }
            };
            
            handler();
          }}
          disabled={isLoading}
          variant={isSubscribed ? 'outline' : 'default'}
          className="w-full"
          type="button"
        >
          {isLoading
            ? 'Carregando...'
            : isSubscribed
            ? 'Desativar Notificações'
            : 'Ativar Notificações'}
        </Button>
      </CardContent>
    </Card>
  );
}

