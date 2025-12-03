import { useState, useEffect } from 'react';
import { Gift, Check, X, MessageCircle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Skeleton } from '@/components/ui/skeleton';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { cn } from '@/lib/utils';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';

interface Redemption {
  id: string;
  user_id: string;
  reward_id: string;
  points_spent: number;
  status: 'pending' | 'approved' | 'delivered' | 'cancelled';
  created_at: string;
  profiles: {
    username: string;
    avatar_url: string | null;
    full_name: string | null;
  } | null;
  rewards: {
    name: string;
    description: string | null;
  } | null;
}

const getStatusColor = (status: string) => {
  switch (status) {
    case 'approved':
      return 'bg-green-500/20 text-green-500';
    case 'delivered':
      return 'bg-blue-500/20 text-blue-500';
    case 'cancelled':
      return 'bg-red-500/20 text-red-500';
    default:
      return 'bg-yellow-500/20 text-yellow-500';
  }
};

const getStatusLabel = (status: string) => {
  switch (status) {
    case 'approved':
      return 'Aprovado';
    case 'delivered':
      return 'Entregue';
    case 'cancelled':
      return 'Cancelado';
    default:
      return 'Pendente';
  }
};

export function RewardManagement() {
  const queryClient = useQueryClient();
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  // Buscar resgates
  const { data: redemptions, isLoading } = useQuery({
    queryKey: ['support_redemptions', selectedStatus],
    queryFn: async () => {
      let query = supabase
        .from('redemptions')
        .select(`
          *,
          profiles:user_id (username, avatar_url, full_name),
          rewards:reward_id (name, description)
        `)
        .order('created_at', { ascending: false });

      if (selectedStatus !== 'all') {
        query = query.eq('status', selectedStatus);
      }

      const { data, error } = await query;
      if (error) {
        console.error('Erro ao buscar resgates:', error);
        throw error;
      }
      console.log('Resgates encontrados:', data);
      return data as Redemption[];
    },
  });

  // Atualização em tempo real
  useEffect(() => {
    const channel = supabase
      .channel('redemptions_changes')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'redemptions' },
        (payload) => {
          console.log('Mudança em redemptions:', payload);
          queryClient.invalidateQueries({ queryKey: ['support_redemptions'] });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [queryClient]);

  // Mutation para atualizar status do resgate
  const updateStatus = useMutation({
    mutationFn: async ({ id, status }: { id: string; status: string }) => {
      const { error } = await supabase
        .from('redemptions')
        .update({ status, updated_at: new Date().toISOString() })
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support_redemptions'] });
      toast.success('Status atualizado!');
    },
    onError: (error: any) => {
      toast.error(error?.message || 'Erro ao atualizar status');
    },
  });

  // Função para abrir chat com o usuário
  const contactUser = (userId: string, username: string) => {
    // Redirecionar para a aba de suporte com o usuário selecionado
    toast.info(`Entre em contato com ${username} na aba de Chat de Suporte`);
  };

  return (
    <div className="space-y-4">
      {/* Header e filtros */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-white">
            <Gift className="h-5 w-5 text-primary" />
            Resgates de Prêmios
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex gap-2 flex-wrap">
            <Button
              variant={selectedStatus === 'all' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setSelectedStatus('all')}
              className={selectedStatus === 'all' ? 'bg-primary' : 'border-[#2a2a2a] text-gray-400'}
            >
              Todos
            </Button>
            <Button
              variant={selectedStatus === 'pending' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setSelectedStatus('pending')}
              className={selectedStatus === 'pending' ? 'bg-yellow-500' : 'border-[#2a2a2a] text-gray-400'}
            >
              Pendentes
            </Button>
            <Button
              variant={selectedStatus === 'approved' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setSelectedStatus('approved')}
              className={selectedStatus === 'approved' ? 'bg-green-500' : 'border-[#2a2a2a] text-gray-400'}
            >
              Aprovados
            </Button>
            <Button
              variant={selectedStatus === 'delivered' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setSelectedStatus('delivered')}
              className={selectedStatus === 'delivered' ? 'bg-blue-500' : 'border-[#2a2a2a] text-gray-400'}
            >
              Entregues
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Lista de resgates */}
      {isLoading ? (
        <div className="space-y-4">
          {[1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-32 bg-[#2a2a2a]" />
          ))}
        </div>
      ) : redemptions && redemptions.length > 0 ? (
        <div className="space-y-4">
          {redemptions.map((redemption) => (
            <Card
              key={redemption.id}
              className="border border-[#2a2a2a] bg-[#1a1a1a] hover:border-primary/30 transition-colors"
            >
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <Avatar className="h-12 w-12 flex-shrink-0">
                    <AvatarImage 
                      src={redemption.profiles?.avatar_url || ''} 
                      className="object-cover object-center"
                    />
                    <AvatarFallback className="bg-primary text-white">
                      {redemption.profiles?.username?.charAt(0).toUpperCase() || 'U'}
                    </AvatarFallback>
                  </Avatar>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-4 mb-2">
                      <div>
                        <h3 className="font-semibold text-white text-lg">
                          {redemption.rewards?.name || 'Prêmio'}
                        </h3>
                        <p className="text-sm text-gray-400">
                          Resgatado por <span className="text-white font-medium">{redemption.profiles?.username || 'Usuário'}</span>
                        </p>
                      </div>
                      <Badge className={getStatusColor(redemption.status)}>
                        {getStatusLabel(redemption.status)}
                      </Badge>
                    </div>

                    {redemption.rewards?.description && (
                      <p className="text-sm text-gray-400 mb-3">
                        {redemption.rewards.description}
                      </p>
                    )}

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4 text-sm text-gray-400">
                        <span className="font-semibold text-primary">
                          {redemption.points_spent} pontos
                        </span>
                        <span>•</span>
                        <span>
                          {format(new Date(redemption.created_at), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                        </span>
                      </div>

                      <div className="flex items-center gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => contactUser(redemption.user_id, redemption.profiles?.username || 'Usuário')}
                          className="border-primary text-primary hover:bg-primary hover:text-white"
                        >
                          <MessageCircle className="h-4 w-4 mr-2" />
                          Contatar
                        </Button>

                        {redemption.status === 'pending' && (
                          <>
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button
                                  size="sm"
                                  className="bg-green-500 hover:bg-green-600"
                                >
                                  <Check className="h-4 w-4 mr-2" />
                                  Aprovar
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                                <AlertDialogHeader>
                                  <AlertDialogTitle className="text-white">
                                    Aprovar Resgate
                                  </AlertDialogTitle>
                                  <AlertDialogDescription className="text-gray-400">
                                    Tem certeza que deseja aprovar este resgate?
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                                    Cancelar
                                  </AlertDialogCancel>
                                  <AlertDialogAction
                                    onClick={() => updateStatus.mutate({ id: redemption.id, status: 'approved' })}
                                    className="bg-green-500 hover:bg-green-600"
                                  >
                                    Aprovar
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>

                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button
                                  size="sm"
                                  variant="outline"
                                  className="border-red-500 text-red-500 hover:bg-red-500 hover:text-white"
                                >
                                  <X className="h-4 w-4 mr-2" />
                                  Rejeitar
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                                <AlertDialogHeader>
                                  <AlertDialogTitle className="text-white">
                                    Rejeitar Resgate
                                  </AlertDialogTitle>
                                  <AlertDialogDescription className="text-gray-400">
                                    O resgate será cancelado e os pontos serão devolvidos ao usuário.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                                    Cancelar
                                  </AlertDialogCancel>
                                  <AlertDialogAction
                                    onClick={() => updateStatus.mutate({ id: redemption.id, status: 'cancelled' })}
                                    className="bg-red-500 hover:bg-red-600"
                                  >
                                    Rejeitar
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          </>
                        )}

                        {redemption.status === 'approved' && (
                          <Button
                            size="sm"
                            onClick={() => updateStatus.mutate({ id: redemption.id, status: 'delivered' })}
                            className="bg-blue-500 hover:bg-blue-600"
                          >
                            <CheckCircle className="h-4 w-4 mr-2" />
                            Marcar como Entregue
                          </Button>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
          <CardContent className="py-16 text-center">
            <div className="bg-primary/10 rounded-full p-6 w-fit mx-auto mb-4">
              <Gift className="h-12 w-12 text-primary" />
            </div>
            <h3 className="text-lg font-semibold text-white mb-2">
              {selectedStatus === 'pending' ? 'Nenhum resgate pendente' : 'Nenhum resgate'}
            </h3>
            <p className="text-gray-400 text-sm">
              {selectedStatus === 'all' 
                ? 'Quando alunos resgatarem prêmios, eles aparecerão aqui' 
                : selectedStatus === 'pending'
                ? 'Nenhum resgate aguardando aprovação no momento'
                : `Nenhum resgate ${getStatusLabel(selectedStatus).toLowerCase()} no momento`
              }
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

