import { useState } from 'react';
import { Bell, Send, History, Users, Zap, RefreshCw } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { useAuth } from '@/contexts/AuthContext';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';

// Helper para acessar tabelas que podem não estar nos types
const getPushSubscriptionsTable = () => (supabase as any).from('push_subscriptions');
const getPushNotificationsLogTable = () => (supabase as any).from('push_notifications_log');

interface NotificationLog {
  id: string;
  title: string;
  body: string;
  url: string | null;
  recipients_count: number;
  success_count: number;
  failed_count: number;
  created_at: string;
}

interface QuickNotification {
  title: string;
  body: string;
  icon: string;
}

const quickNotifications: QuickNotification[] = [
  {
    title: '🔥 Novo conteúdo disponível!',
    body: 'Acabamos de lançar um novo módulo exclusivo. Confira agora!',
    icon: '🔥',
  },
  {
    title: '💎 Promoção especial Diamond!',
    body: 'Aproveite condições especiais para se tornar Diamond. Por tempo limitado!',
    icon: '💎',
  },
  {
    title: '📚 Não esqueça de estudar hoje!',
    body: 'Mantenha sua sequência de estudos. Cada dia conta para seu progresso!',
    icon: '📚',
  },
  {
    title: '🏆 Ranking atualizado!',
    body: 'Confira sua posição no ranking e continue acumulando pontos!',
    icon: '🏆',
  },
];

export function PushNotificationManagement() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [url, setUrl] = useState('');

  // Buscar estatísticas de dispositivos registrados
  const { data: stats, isLoading: loadingStats, refetch: refetchStats } = useQuery({
    queryKey: ['push-stats'],
    queryFn: async () => {
      const { data, error, count } = await getPushSubscriptionsTable()
        .select('user_id', { count: 'exact' });

      if (error) throw error;

      // Contar usuários únicos
      const uniqueUsers = new Set(data?.map((d: any) => d.user_id) || []);

      return {
        totalDevices: count || 0,
        uniqueUsers: uniqueUsers.size,
      };
    },
  });

  // Buscar histórico de notificações
  const { data: history, isLoading: loadingHistory } = useQuery({
    queryKey: ['push-history'],
    queryFn: async () => {
      const { data, error } = await getPushNotificationsLogTable()
        .select('*')
        .order('created_at', { ascending: false })
        .limit(20);

      if (error) throw error;
      return data as NotificationLog[];
    },
  });

  // Mutation para enviar notificação via OneSignal
  const sendNotification = useMutation({
    mutationFn: async (payload: { title: string; body: string; url?: string }) => {
      const { data, error } = await supabase.functions.invoke('send-push-notification-onesignal', {
        body: {
          title: payload.title,
          body: payload.body,
          url: payload.url,
          sentBy: user?.id,
        },
      });

      if (error) throw error;
      if (!data.success) throw new Error(data.error || 'Erro ao enviar notificação');

      return data;
    },
    onSuccess: (data) => {
      toast.success('Notificação enviada!', {
        description: `Enviada para ${data.success_count} dispositivo(s)`,
      });
      queryClient.invalidateQueries({ queryKey: ['push-history'] });
      queryClient.invalidateQueries({ queryKey: ['push-stats'] });
      setTitle('');
      setBody('');
      setUrl('');
    },
    onError: (error: any) => {
      toast.error('Erro ao enviar notificação', {
        description: error.message || 'Tente novamente',
      });
    },
  });

  const handleSendNotification = () => {
    if (!title.trim() || !body.trim()) {
      toast.error('Preencha título e mensagem');
      return;
    }
    sendNotification.mutate({ title, body, url: url || undefined });
  };

  const handleQuickNotification = (notification: QuickNotification) => {
    setTitle(notification.title);
    setBody(notification.body);
  };

  const handleSendQuickNotification = (notification: QuickNotification) => {
    sendNotification.mutate({ 
      title: notification.title, 
      body: notification.body,
    });
  };

  return (
    <div className="space-y-4">
      {/* Estatísticas */}
      <div className="grid grid-cols-2 gap-4">
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-primary/10 rounded-lg">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold text-white">
                  {loadingStats ? '...' : stats?.totalDevices || 0}
                </p>
                <p className="text-sm text-gray-400">Dispositivos registrados</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-3 bg-green-500/10 rounded-lg">
                <Bell className="h-6 w-6 text-green-500" />
              </div>
              <div>
                <p className="text-2xl font-bold text-white">
                  {loadingStats ? '...' : stats?.uniqueUsers || 0}
                </p>
                <p className="text-sm text-gray-400">Usuários com push ativo</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Formulário de envio */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Send className="h-5 w-5 text-primary" />
              <CardTitle className="text-white">Enviar Notificação Push</CardTitle>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => refetchStats()}
              className="text-gray-400 hover:text-white"
            >
              <RefreshCw className="h-4 w-4" />
            </Button>
          </div>
          <CardDescription className="text-gray-400">
            Envie notificações push para todos os usuários com notificações ativadas
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title" className="text-white">Título *</Label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Ex: Novo conteúdo disponível!"
              className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
              maxLength={50}
            />
            <p className="text-xs text-gray-400">{title.length}/50 caracteres</p>
          </div>
          <div className="space-y-2">
            <Label htmlFor="body" className="text-white">Mensagem *</Label>
            <Textarea
              id="body"
              value={body}
              onChange={(e) => setBody(e.target.value)}
              placeholder="Ex: Confira o novo módulo que acabamos de lançar!"
              className="bg-[#2a2a2a] border-[#3a3a3a] text-white min-h-[80px]"
              maxLength={200}
            />
            <p className="text-xs text-gray-400">{body.length}/200 caracteres</p>
          </div>
          <div className="space-y-2">
            <Label htmlFor="url" className="text-white">URL de redirecionamento (opcional)</Label>
            <Input
              id="url"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              placeholder="Ex: /courses ou /upgrade"
              className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
            />
            <p className="text-xs text-gray-400">Quando o usuário clicar na notificação, será redirecionado para esta URL</p>
          </div>
          <Button
            onClick={handleSendNotification}
            disabled={sendNotification.isPending || !title.trim() || !body.trim()}
            className="w-full bg-primary hover:bg-primary/90"
          >
            <Send className="h-4 w-4 mr-2" />
            {sendNotification.isPending 
              ? 'Enviando...' 
              : `Enviar para ${stats?.totalDevices || 0} dispositivo(s)`
            }
          </Button>
        </CardContent>
      </Card>

      {/* Notificações rápidas */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <div className="flex items-center gap-2">
            <Zap className="h-5 w-5 text-yellow-500" />
            <CardTitle className="text-white">Notificações Rápidas</CardTitle>
          </div>
          <CardDescription className="text-gray-400">
            Clique para preencher o formulário ou segure para enviar diretamente
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
            {quickNotifications.map((notification, index) => (
              <Button
                key={index}
                variant="outline"
                className="h-auto py-3 px-4 justify-start text-left bg-[#2a2a2a] border-[#3a3a3a] hover:bg-[#3a3a3a] text-white"
                onClick={() => handleQuickNotification(notification)}
                onDoubleClick={() => handleSendQuickNotification(notification)}
              >
                <div className="flex flex-col gap-1 w-full">
                  <span className="font-medium text-sm truncate">{notification.title}</span>
                  <span className="text-xs text-gray-400 truncate">{notification.body}</span>
                </div>
              </Button>
            ))}
          </div>
          <p className="text-xs text-gray-500 mt-2 text-center">
            Clique uma vez para editar • Clique duas vezes para enviar diretamente
          </p>
        </CardContent>
      </Card>

      {/* Histórico */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <div className="flex items-center gap-2">
            <History className="h-5 w-5 text-blue-500" />
            <CardTitle className="text-white">Histórico de Notificações</CardTitle>
          </div>
          <CardDescription className="text-gray-400">
            Últimas 20 notificações enviadas
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loadingHistory ? (
            <p className="text-gray-400 text-center py-4">Carregando...</p>
          ) : !history || history.length === 0 ? (
            <p className="text-gray-400 text-center py-4">Nenhuma notificação enviada ainda</p>
          ) : (
            <div className="space-y-2 max-h-[400px] overflow-y-auto">
              {history.map((log) => (
                <div
                  key={log.id}
                  className="p-3 bg-[#2a2a2a] rounded-lg border border-[#3a3a3a]"
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-white text-sm truncate">{log.title}</p>
                      <p className="text-xs text-gray-400 truncate">{log.body}</p>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <p className="text-xs text-gray-400">
                        {formatDistanceToNow(new Date(log.created_at), {
                          addSuffix: true,
                          locale: ptBR,
                        })}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-xs text-green-500">{log.success_count} ✓</span>
                        {log.failed_count > 0 && (
                          <span className="text-xs text-red-500">{log.failed_count} ✗</span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Nota informativa */}
      <Card className="border border-yellow-500/20 bg-yellow-500/5">
        <CardContent className="pt-4">
          <p className="text-sm text-yellow-400">
            <strong>⚠️ Importante:</strong> As notificações push só funcionam para usuários que ativaram 
            as notificações no app. Certifique-se de que as chaves VAPID estão configuradas corretamente 
            nos secrets do projeto.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
