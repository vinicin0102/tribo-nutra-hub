import { Bell, BellOff } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useOneSignal } from '@/hooks/useOneSignal';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export function NotificationToggle() {
  const { isSupported, isSubscribed, isLoading, isInitialized, subscribe, unsubscribe } = useOneSignal();

  if (!isInitialized && isLoading) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="text-white flex items-center gap-2">
            <Bell className="h-5 w-5 text-gray-400" />
            Notificações Push
          </CardTitle>
          <CardDescription>
            Inicializando OneSignal...
          </CardDescription>
        </CardHeader>
      </Card>
    );
  }

  if (!isSupported) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="text-white flex items-center gap-2">
            <BellOff className="h-5 w-5 text-gray-400" />
            Notificações Push
          </CardTitle>
          <CardDescription>
            OneSignal não está disponível. Verifique sua conexão e tente novamente.
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
          onClick={async (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            if (isLoading) return;
            
            if (isSubscribed) {
              await unsubscribe();
            } else {
              await subscribe();
            }
          }}
          disabled={isLoading || !isInitialized}
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

