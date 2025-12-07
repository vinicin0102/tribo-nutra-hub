import { useState } from 'react';
import { Ban, CheckCircle, Trash2, Search, VolumeX, Volume2, Crown, Coins, MoreVertical } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { 
  useSupportUsers, 
  useBanUserTemporary, 
  useUnbanUser,
  useMuteUser,
  useUnmuteUser,
  useDeleteUser,
  useChangeUserPlan,
  useUpdateUserPoints
} from '@/hooks/useSupport';
import { useIsAdmin } from '@/hooks/useAdmin';
import { toast } from 'sonner';
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

interface UserProfile {
  user_id: string;
  username: string;
  full_name?: string;
  avatar_url?: string;
  email?: string;
  points?: number;
  subscription_plan?: string;
  role?: string;
  is_banned?: boolean;
  banned_until?: string;
  is_muted?: boolean;
  mute_until?: string;
}

export function UserManagement() {
  const isAdmin = useIsAdmin();
  const { data: usersData = [], isLoading, error } = useSupportUsers();
  const users = usersData as UserProfile[];
  
  const banUserTemporary = useBanUserTemporary();
  const unbanUser = useUnbanUser();
  const muteUser = useMuteUser();
  const unmuteUser = useUnmuteUser();
  const deleteUser = useDeleteUser();
  const changePlan = useChangeUserPlan();
  const updatePoints = useUpdateUserPoints();
  
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
  const [showPlanDialog, setShowPlanDialog] = useState(false);
  const [showPointsDialog, setShowPointsDialog] = useState(false);
  const [newPlan, setNewPlan] = useState<'free' | 'diamond'>('free');
  const [newPoints, setNewPoints] = useState('');

  const filteredUsers = users.filter(
    (user) =>
      user.username?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.full_name?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleBan3Days = async (userId: string, username: string) => {
    try {
      await banUserTemporary.mutateAsync({ userId, days: 3 });
      toast.success(`Usuário ${username} foi banido por 3 dias`);
    } catch (error: any) {
      toast.error(`Erro ao banir usuário: ${error?.message || 'Erro desconhecido'}`);
    }
  };

  const handleUnban = async (userId: string, username: string) => {
    try {
      await unbanUser.mutateAsync(userId);
      toast.success(`Usuário ${username} foi desbanido`);
    } catch (error) {
      toast.error('Erro ao desbanir usuário');
    }
  };

  const handleMute = async (userId: string, username: string, days?: number) => {
    try {
      await muteUser.mutateAsync({ userId, days });
      toast.success(`Usuário ${username} foi mutado${days ? ` por ${days} dias` : ' permanentemente'}`);
    } catch (error: any) {
      toast.error(`Erro ao mutar usuário: ${error?.message || 'Erro desconhecido'}`);
    }
  };

  const handleUnmute = async (userId: string, username: string) => {
    try {
      await unmuteUser.mutateAsync(userId);
      toast.success(`Usuário ${username} foi desmutado`);
    } catch (error) {
      toast.error('Erro ao desmutar usuário');
    }
  };

  const handleDelete = async (userId: string, username: string) => {
    try {
      await deleteUser.mutateAsync(userId);
      toast.success(`Usuário ${username} foi excluído`);
    } catch (error) {
      toast.error('Erro ao excluir usuário');
    }
  };

  const handleChangePlan = async () => {
    if (!selectedUser) return;
    try {
      await changePlan.mutateAsync({
        userId: selectedUser.user_id,
        plan: newPlan,
        expiresAt: null,
      });
      toast.success(`Plano de ${selectedUser.username} alterado para ${newPlan}`);
      setShowPlanDialog(false);
      setSelectedUser(null);
    } catch (error) {
      toast.error('Erro ao alterar plano');
    }
  };

  const handleUpdatePoints = async () => {
    if (!selectedUser || !newPoints) return;
    try {
      const points = parseInt(newPoints);
      if (isNaN(points) || points < 0) {
        toast.error('Pontos inválidos');
        return;
      }
      await updatePoints.mutateAsync({
        userId: selectedUser.user_id,
        points,
      });
      toast.success(`Pontuação de ${selectedUser.username} alterada para ${points}`);
      setShowPointsDialog(false);
      setSelectedUser(null);
      setNewPoints('');
    } catch (error) {
      toast.error('Erro ao alterar pontuação');
    }
  };

  if (!isAdmin) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardContent className="pt-6">
          <p className="text-white text-center">Acesso negado. Apenas admin@gmail.com pode acessar esta área.</p>
        </CardContent>
      </Card>
    );
  }

  if (isLoading) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardContent className="pt-6">
          <p className="text-gray-400 text-center">Carregando usuários...</p>
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardContent className="pt-6">
          <p className="text-red-400 text-center">Erro ao carregar usuários: {String(error)}</p>
          <Button onClick={() => window.location.reload()} className="w-full mt-4">Recarregar</Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="text-white">Painel Administrativo</CardTitle>
          <div className="mt-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Buscar por nome ou username..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
              />
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <div className="divide-y divide-[#2a2a2a] max-h-[calc(100vh-300px)] overflow-y-auto">
            {filteredUsers.length === 0 ? (
              <div className="p-4 text-center text-gray-400">
                <p>Nenhum usuário encontrado</p>
              </div>
            ) : (
              filteredUsers.map((user) => (
                <div
                  key={user.user_id}
                  className="p-4 flex items-center justify-between hover:bg-[#2a2a2a] transition-colors"
                >
                  <div className="flex items-center gap-3 flex-1">
                    <Avatar className="h-10 w-10">
                      <AvatarImage src={user.avatar_url || ''} />
                      <AvatarFallback className="bg-primary text-white">
                        {user.username?.charAt(0).toUpperCase() || 'U'}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                      <p className="text-white font-semibold truncate">
                        {user.full_name || user.username || 'Usuário'}
                      </p>
                      <p className="text-xs text-gray-400 truncate">@{user.username}</p>
                      {user.email && (
                        <p className="text-xs text-gray-500 truncate">{user.email}</p>
                      )}
                      <div className="flex items-center gap-2 mt-1 flex-wrap">
                        <span className="text-xs text-gray-500">{user.points || 0} pontos</span>
                        {user.subscription_plan && (
                          <span className={`text-xs px-2 py-0.5 rounded ${
                            user.subscription_plan === 'diamond' 
                              ? 'bg-cyan-500/20 text-cyan-500' 
                              : 'bg-gray-500/20 text-gray-400'
                          }`}>
                            {user.subscription_plan === 'diamond' ? '💎 Diamond' : 'Free'}
                          </span>
                        )}
                        {user.role && (
                          <span className="text-xs px-2 py-0.5 rounded bg-primary/20 text-primary">
                            {user.role}
                          </span>
                        )}
                        {user.is_banned && (
                          <span className="text-xs px-2 py-0.5 rounded bg-red-500/20 text-red-500">
                            Banido
                            {user.banned_until && ` até ${new Date(user.banned_until).toLocaleDateString('pt-BR')}`}
                          </span>
                        )}
                        {user.is_muted && (
                          <span className="text-xs px-2 py-0.5 rounded bg-orange-500/20 text-orange-500">
                            Mutado
                            {user.mute_until && ` até ${new Date(user.mute_until).toLocaleDateString('pt-BR')}`}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="sm" className="text-gray-400 hover:text-white">
                        <MoreVertical className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="bg-[#1a1a1a] border-[#2a2a2a]">
                      {!user.is_banned ? (
                        <AlertDialog>
                          <AlertDialogTrigger asChild>
                            <DropdownMenuItem onSelect={(e) => e.preventDefault()} className="text-red-400">
                              <Ban className="h-4 w-4 mr-2" />
                              Banir 3 dias
                            </DropdownMenuItem>
                          </AlertDialogTrigger>
                          <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                            <AlertDialogHeader>
                              <AlertDialogTitle className="text-white">Banir por 3 dias</AlertDialogTitle>
                              <AlertDialogDescription className="text-gray-400">
                                Tem certeza que deseja banir {user.username} por 3 dias?
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter>
                              <AlertDialogCancel className="bg-[#2a2a2a] text-white">Cancelar</AlertDialogCancel>
                              <AlertDialogAction
                                onClick={() => handleBan3Days(user.user_id, user.username)}
                                className="bg-red-500 hover:bg-red-600"
                              >
                                Banir
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      ) : (
                        <DropdownMenuItem onClick={() => handleUnban(user.user_id, user.username)} className="text-green-400">
                          <CheckCircle className="h-4 w-4 mr-2" />
                          Desbanir
                        </DropdownMenuItem>
                      )}
                      
                      {!user.is_muted ? (
                        <>
                          <AlertDialog>
                            <AlertDialogTrigger asChild>
                              <DropdownMenuItem onSelect={(e) => e.preventDefault()} className="text-orange-400">
                                <VolumeX className="h-4 w-4 mr-2" />
                                Mutar (7 dias)
                              </DropdownMenuItem>
                            </AlertDialogTrigger>
                            <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                              <AlertDialogHeader>
                                <AlertDialogTitle className="text-white">Mutar usuário</AlertDialogTitle>
                                <AlertDialogDescription className="text-gray-400">
                                  Mutar {user.username} por 7 dias na comunidade?
                                </AlertDialogDescription>
                              </AlertDialogHeader>
                              <AlertDialogFooter>
                                <AlertDialogCancel className="bg-[#2a2a2a] text-white">Cancelar</AlertDialogCancel>
                                <AlertDialogAction
                                  onClick={() => handleMute(user.user_id, user.username, 7)}
                                  className="bg-orange-500 hover:bg-orange-600"
                                >
                                  Mutar
                                </AlertDialogAction>
                              </AlertDialogFooter>
                            </AlertDialogContent>
                          </AlertDialog>
                        </>
                      ) : (
                        <DropdownMenuItem onClick={() => handleUnmute(user.user_id, user.username)} className="text-green-400">
                          <Volume2 className="h-4 w-4 mr-2" />
                          Desmutar
                        </DropdownMenuItem>
                      )}
                      
                      <DropdownMenuItem
                        onClick={() => {
                          setSelectedUser(user);
                          setNewPlan((user.subscription_plan as 'free' | 'diamond') || 'free');
                          setShowPlanDialog(true);
                        }}
                        className="text-blue-400"
                      >
                        <Crown className="h-4 w-4 mr-2" />
                        Mudar plano
                      </DropdownMenuItem>
                      
                      <DropdownMenuItem
                        onClick={() => {
                          setSelectedUser(user);
                          setNewPoints(String(user.points || 0));
                          setShowPointsDialog(true);
                        }}
                        className="text-yellow-400"
                      >
                        <Coins className="h-4 w-4 mr-2" />
                        Alterar pontuação
                      </DropdownMenuItem>
                      
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <DropdownMenuItem onSelect={(e) => e.preventDefault()} className="text-red-400">
                            <Trash2 className="h-4 w-4 mr-2" />
                            Excluir usuário
                          </DropdownMenuItem>
                        </AlertDialogTrigger>
                        <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                          <AlertDialogHeader>
                            <AlertDialogTitle className="text-white">Excluir usuário</AlertDialogTitle>
                            <AlertDialogDescription className="text-gray-400">
                              Tem certeza que deseja excluir {user.username}? Esta ação não pode ser desfeita.
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel className="bg-[#2a2a2a] text-white">Cancelar</AlertDialogCancel>
                            <AlertDialogAction
                              onClick={() => handleDelete(user.user_id, user.username)}
                              className="bg-red-500 hover:bg-red-600"
                            >
                              Excluir
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Dialog de mudança de plano */}
      <Dialog open={showPlanDialog} onOpenChange={setShowPlanDialog}>
        <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
          <DialogHeader>
            <DialogTitle className="text-white">Alterar Plano</DialogTitle>
            <DialogDescription className="text-gray-400">
              Alterar plano de {selectedUser?.username}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label className="text-white">Plano</Label>
              <Select value={newPlan} onValueChange={(value: 'free' | 'diamond') => setNewPlan(value)}>
                <SelectTrigger className="bg-[#2a2a2a] border-[#3a3a3a] text-white">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-[#2a2a2a] border-[#3a3a3a]">
                  <SelectItem value="free" className="text-white">Free</SelectItem>
                  <SelectItem value="diamond" className="text-white">💎 Diamond</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowPlanDialog(false)} className="border-[#3a3a3a] text-white">
              Cancelar
            </Button>
            <Button onClick={handleChangePlan} className="bg-primary">
              Salvar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Dialog de alteração de pontos */}
      <Dialog open={showPointsDialog} onOpenChange={setShowPointsDialog}>
        <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
          <DialogHeader>
            <DialogTitle className="text-white">Alterar Pontuação</DialogTitle>
            <DialogDescription className="text-gray-400">
              Alterar pontuação de {selectedUser?.username}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label className="text-white">Pontos</Label>
              <Input
                type="number"
                value={newPoints}
                onChange={(e) => setNewPoints(e.target.value)}
                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                min="0"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowPointsDialog(false)} className="border-[#3a3a3a] text-white">
              Cancelar
            </Button>
            <Button onClick={handleUpdatePoints} className="bg-primary">
              Salvar
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
