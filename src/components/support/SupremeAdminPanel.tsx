import { useState } from 'react';
import { Crown, Users, Shield, Database, Bell, BookOpen, Trash2, Plus, Search, Ban, VolumeX, Volume2, Unlock, Eye, Download, CheckCircle, X, Clock, AlertTriangle } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { useIsSupremeAdmin } from '@/hooks/useSupremeAdmin';
import { useSupportUsers, useChangeUserRole, useChangeUserPlan, useBanUserTemporary, useUnbanUser, useMuteUser, useUnmuteUser, useUnlockMentoria } from '@/hooks/useSupport';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface UserProfile {
    user_id: string;
    username: string;
    full_name?: string;
    email?: string;
    avatar_url?: string;
    subscription_plan?: string;
    subscription_expires_at?: string;
    points?: number;
    role?: string;
    is_banned?: boolean;
    banned_until?: string;
    is_muted?: boolean;
    mute_until?: string;
    telefone?: string;
    created_at?: string;
}

export function SupremeAdminPanel() {
    const isSupreme = useIsSupremeAdmin();
    const { data: users } = useSupportUsers();
    const changeRole = useChangeUserRole();
    const changePlan = useChangeUserPlan();
    const banUser = useBanUserTemporary();
    const unbanUser = useUnbanUser();
    const muteUser = useMuteUser();
    const unmuteUser = useUnmuteUser();
    const unlockMentoria = useUnlockMentoria();

    const [searchTerm, setSearchTerm] = useState('');
    const [showAddAdminDialog, setShowAddAdminDialog] = useState(false);
    const [showUserDetailsDialog, setShowUserDetailsDialog] = useState(false);
    const [showPlanDialog, setShowPlanDialog] = useState(false);
    const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
    const [newAdminEmail, setNewAdminEmail] = useState('');
    const [newAdminRole, setNewAdminRole] = useState<'admin' | 'support'>('admin');
    const [newPlan, setNewPlan] = useState<'free' | 'diamond'>('free');
    const [showNotifyDialog, setShowNotifyDialog] = useState(false);
    const [notifyTitle, setNotifyTitle] = useState('');
    const [notifyMessage, setNotifyMessage] = useState('');
    const [notifyUrl, setNotifyUrl] = useState('');
    const [isSendingNotification, setIsSendingNotification] = useState(false);

    if (!isSupreme) {
        return (
            <div className="text-center py-12">
                <Crown className="h-16 w-16 text-yellow-500 mx-auto mb-4 opacity-50" />
                <p className="text-gray-400">Acesso restrito ao Admin Supremo</p>
            </div>
        );
    }

    // Estatísticas
    const totalUsers = users?.length || 0;
    const diamondUsers = users?.filter(u => u.subscription_plan === 'diamond').length || 0;
    const freeUsers = users?.filter(u => u.subscription_plan !== 'diamond').length || 0;
    const adminUsers = users?.filter(u => u.role === 'admin' || u.role === 'support').length || 0;
    const bannedUsers = users?.filter(u => u.is_banned).length || 0;
    const mutedUsers = users?.filter(u => u.is_muted).length || 0;

    // Filtrar usuários
    const filteredUsers = users?.filter(user =>
        user.username?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.full_name?.toLowerCase().includes(searchTerm.toLowerCase())
    ) || [];

    const handleAddAdmin = async () => {
        if (!newAdminEmail) {
            toast.error('Digite o email do novo admin');
            return;
        }

        const user = users?.find(u => u.email?.toLowerCase() === newAdminEmail.toLowerCase());
        if (!user) {
            toast.error('Usuário não encontrado');
            return;
        }

        try {
            await changeRole.mutateAsync({
                userId: user.user_id,
                email: user.email || '',
                role: newAdminRole,
            });
            toast.success(`${user.username} agora é ${newAdminRole === 'admin' ? 'Administrador' : 'Suporte'}!`);
            setShowAddAdminDialog(false);
            setNewAdminEmail('');
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleRemoveAdmin = async (userId: string, email: string, username: string) => {
        try {
            await changeRole.mutateAsync({ userId, email, role: 'user' });
            toast.success(`${username} não é mais admin`);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleChangePlan = async () => {
        if (!selectedUser) return;
        try {
            await changePlan.mutateAsync({
                userId: selectedUser.user_id,
                plan: newPlan,
                expiresAt: null
            });
            toast.success(`Plano de ${selectedUser.username} alterado para ${newPlan}`);
            setShowPlanDialog(false);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleBan = async (user: UserProfile, days: number | 'permanent') => {
        try {
            if (days === 'permanent') {
                await banUser.mutateAsync({ userId: user.user_id, days: 9999 });
                toast.success(`${user.username} banido permanentemente`);
            } else {
                await banUser.mutateAsync({ userId: user.user_id, days });
                toast.success(`${user.username} banido por ${days} dias`);
            }
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleUnban = async (user: UserProfile) => {
        try {
            await unbanUser.mutateAsync(user.user_id);
            toast.success(`${user.username} foi desbanido`);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleMute = async (user: UserProfile, hours: number) => {
        try {
            await muteUser.mutateAsync({ userId: user.user_id, days: Math.ceil(hours / 24) });
            toast.success(`${user.username} mutado por ${hours}h`);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleUnmute = async (user: UserProfile) => {
        try {
            await unmuteUser.mutateAsync(user.user_id);
            toast.success(`${user.username} foi desmutado`);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleUnlockContent = async (user: UserProfile) => {
        try {
            await unlockMentoria.mutateAsync(user.user_id);
            toast.success(`Conteúdo liberado para ${user.username}`);
        } catch (error: any) {
            toast.error(`Erro: ${error?.message}`);
        }
    };

    const handleExportData = () => {
        if (!users) return;

        const csvContent = [
            ['ID', 'Username', 'Nome', 'Email', 'Telefone', 'Plano', 'Pontos', 'Role', 'Banido', 'Mutado', 'Data Cadastro'].join(','),
            ...users.map(u => [
                u.user_id,
                u.username,
                u.full_name || '',
                u.email || '',
                u.telefone || '',
                u.subscription_plan || 'free',
                u.points || 0,
                u.role || 'user',
                u.is_banned ? 'Sim' : 'Não',
                u.is_muted ? 'Sim' : 'Não',
                u.created_at ? new Date(u.created_at).toLocaleDateString('pt-BR') : ''
            ].join(','))
        ].join('\n');

        const blob = new Blob([csvContent], { type: 'text/csv' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `usuarios-${new Date().toISOString().split('T')[0]}.csv`;
        a.click();
        toast.success('Dados exportados com sucesso!');
    };

    const exportUserData = (user: UserProfile) => {
        const data = JSON.stringify(user, null, 2);
        const blob = new Blob([data], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `usuario-${user.username}-${new Date().toISOString().split('T')[0]}.json`;
        a.click();
        toast.success('Dados do usuário exportados!');
    };

    const handleNotifyAll = async () => {
        if (!notifyTitle.trim()) {
            toast.error('Digite o título da notificação');
            return;
        }
        if (!notifyMessage.trim()) {
            toast.error('Digite a mensagem da notificação');
            return;
        }

        setIsSendingNotification(true);

        try {
            const { data, error } = await supabase.functions.invoke('send-push-notification-onesignal', {
                body: {
                    title: notifyTitle.trim(),
                    body: notifyMessage.trim(),
                    url: notifyUrl.trim() || undefined,
                },
            });

            if (error) {
                console.error('Erro ao enviar notificação:', error);
                toast.error('Erro ao enviar notificação: ' + error.message);
                return;
            }

            if (data?.success) {
                toast.success(`Notificação enviada com sucesso! ${data.success_count} usuário(s) notificado(s).`);
                setShowNotifyDialog(false);
                setNotifyTitle('');
                setNotifyMessage('');
                setNotifyUrl('');
            } else {
                toast.error('Erro ao enviar notificação: ' + (data?.error || 'Erro desconhecido'));
            }
        } catch (error: any) {
            console.error('Erro ao enviar notificação:', error);
            toast.error('Erro ao enviar notificação: ' + (error.message || 'Erro desconhecido'));
        } finally {
            setIsSendingNotification(false);
        }
    };

    return (
        <div className="space-y-6">
            {/* Header exclusivo */}
            <div className="bg-gradient-to-r from-yellow-600/20 to-orange-600/20 border border-yellow-500/30 rounded-lg p-6">
                <div className="flex items-center gap-4">
                    <div className="p-3 bg-yellow-500/20 rounded-full">
                        <Crown className="h-8 w-8 text-yellow-400" />
                    </div>
                    <div>
                        <h2 className="text-2xl font-bold text-yellow-400">Painel Admin Supremo</h2>
                        <p className="text-yellow-200/70">Controle total do sistema</p>
                    </div>
                </div>
            </div>

            {/* Estatísticas Rápidas */}
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-white">{totalUsers}</p>
                        <p className="text-xs text-gray-400">Total Usuários</p>
                    </CardContent>
                </Card>
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-cyan-400">{diamondUsers}</p>
                        <p className="text-xs text-gray-400">Diamond</p>
                    </CardContent>
                </Card>
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-gray-400">{freeUsers}</p>
                        <p className="text-xs text-gray-400">Free</p>
                    </CardContent>
                </Card>
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-purple-400">{adminUsers}</p>
                        <p className="text-xs text-gray-400">Admins</p>
                    </CardContent>
                </Card>
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-red-400">{bannedUsers}</p>
                        <p className="text-xs text-gray-400">Banidos</p>
                    </CardContent>
                </Card>
                <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <CardContent className="p-4 text-center">
                        <p className="text-2xl font-bold text-orange-400">{mutedUsers}</p>
                        <p className="text-xs text-gray-400">Mutados</p>
                    </CardContent>
                </Card>
            </div>

            {/* Ações Rápidas */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                        <Shield className="h-5 w-5 text-yellow-400" />
                        Ações do Admin Supremo
                    </CardTitle>
                </CardHeader>
                <CardContent className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <Button
                        onClick={() => setShowAddAdminDialog(true)}
                        className="bg-purple-600 hover:bg-purple-700"
                    >
                        <Plus className="h-4 w-4 mr-2" />
                        Adicionar Admin
                    </Button>
                    <Button
                        onClick={handleExportData}
                        variant="outline"
                        className="border-cyan-500 text-cyan-400 hover:bg-cyan-500/10"
                    >
                        <Database className="h-4 w-4 mr-2" />
                        Exportar Todos
                    </Button>
                    <Button
                        variant="outline"
                        className="border-yellow-500 text-yellow-400 hover:bg-yellow-500/10"
                        onClick={() => setShowNotifyDialog(true)}
                    >
                        <Bell className="h-4 w-4 mr-2" />
                        Notificar Todos
                    </Button>
                    <Button
                        variant="outline"
                        className="border-green-500 text-green-400 hover:bg-green-500/10"
                        onClick={() => toast.info('Em breve: Gerenciar cursos')}
                    >
                        <BookOpen className="h-4 w-4 mr-2" />
                        Gerenciar Cursos
                    </Button>
                </CardContent>
            </Card>

            {/* Gestão Completa de Usuários */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                        <Users className="h-5 w-5 text-yellow-400" />
                        Gestão Completa de Usuários
                    </CardTitle>
                    <CardDescription className="text-gray-400">
                        Clique em um usuário para ver todas as opções
                    </CardDescription>
                    <div className="relative mt-2">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            placeholder="Buscar por nome, email ou username..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="pl-10 bg-[#2a2a2a] border-[#3a3a3a] text-white"
                        />
                    </div>
                </CardHeader>
                <CardContent>
                    <div className="space-y-2 max-h-[500px] overflow-y-auto">
                        {filteredUsers.slice(0, 50).map(user => (
                            <div key={user.user_id} className="flex items-center justify-between p-3 bg-[#2a2a2a] rounded-lg hover:bg-[#333] transition-colors">
                                <div className="flex items-center gap-3">
                                    <Avatar className="h-10 w-10">
                                        <AvatarImage src={user.avatar_url} />
                                        <AvatarFallback className="bg-gradient-to-r from-orange-500 to-pink-500 text-white">
                                            {user.username?.charAt(0)?.toUpperCase()}
                                        </AvatarFallback>
                                    </Avatar>
                                    <div>
                                        <div className="flex items-center gap-2">
                                            <p className="text-white font-medium">{user.username}</p>
                                            {user.subscription_plan === 'diamond' && (
                                                <Badge className="bg-cyan-600 text-xs">Diamond</Badge>
                                            )}
                                            {user.is_banned && (
                                                <Badge className="bg-red-600 text-xs">Banido</Badge>
                                            )}
                                            {user.is_muted && (
                                                <Badge className="bg-orange-600 text-xs">Mutado</Badge>
                                            )}
                                            {(user.role === 'admin' || user.role === 'support') && (
                                                <Badge className="bg-purple-600 text-xs">{user.role}</Badge>
                                            )}
                                        </div>
                                        <p className="text-xs text-gray-400">{user.email}</p>
                                    </div>
                                </div>

                                <DropdownMenu>
                                    <DropdownMenuTrigger asChild>
                                        <Button variant="ghost" size="sm" className="text-yellow-400 hover:text-yellow-300 hover:bg-yellow-500/10">
                                            Ações ▼
                                        </Button>
                                    </DropdownMenuTrigger>
                                    <DropdownMenuContent align="end" className="bg-[#1a1a1a] border-[#2a2a2a] w-56">
                                        {/* Ver Detalhes */}
                                        <DropdownMenuItem
                                            onClick={() => { setSelectedUser(user); setShowUserDetailsDialog(true); }}
                                            className="text-cyan-400"
                                        >
                                            <Eye className="h-4 w-4 mr-2" />
                                            Ver Detalhes
                                        </DropdownMenuItem>

                                        <DropdownMenuSeparator className="bg-[#3a3a3a]" />

                                        {/* Mudar Plano */}
                                        <DropdownMenuItem
                                            onClick={() => {
                                                setSelectedUser(user);
                                                setNewPlan((user.subscription_plan as 'free' | 'diamond') || 'free');
                                                setShowPlanDialog(true);
                                            }}
                                            className="text-blue-400"
                                        >
                                            <Crown className="h-4 w-4 mr-2" />
                                            Mudar Plano
                                        </DropdownMenuItem>

                                        {/* Liberar Conteúdo */}
                                        <DropdownMenuItem
                                            onClick={() => handleUnlockContent(user)}
                                            className="text-green-400"
                                        >
                                            <Unlock className="h-4 w-4 mr-2" />
                                            Liberar Conteúdo
                                        </DropdownMenuItem>

                                        <DropdownMenuSeparator className="bg-[#3a3a3a]" />

                                        {/* Banir */}
                                        {!user.is_banned ? (
                                            <>
                                                <DropdownMenuItem onClick={() => handleBan(user, 1)} className="text-orange-400">
                                                    <Clock className="h-4 w-4 mr-2" />
                                                    Banir 24 horas
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleBan(user, 3)} className="text-orange-400">
                                                    <Clock className="h-4 w-4 mr-2" />
                                                    Banir 3 dias
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleBan(user, 'permanent')} className="text-red-400">
                                                    <Ban className="h-4 w-4 mr-2" />
                                                    Banir Permanente
                                                </DropdownMenuItem>
                                            </>
                                        ) : (
                                            <DropdownMenuItem onClick={() => handleUnban(user)} className="text-green-400">
                                                <CheckCircle className="h-4 w-4 mr-2" />
                                                Desbanir
                                            </DropdownMenuItem>
                                        )}

                                        <DropdownMenuSeparator className="bg-[#3a3a3a]" />

                                        {/* Mutar */}
                                        {!user.is_muted ? (
                                            <>
                                                <DropdownMenuItem onClick={() => handleMute(user, 24)} className="text-yellow-400">
                                                    <VolumeX className="h-4 w-4 mr-2" />
                                                    Mutar 24 horas
                                                </DropdownMenuItem>
                                                <DropdownMenuItem onClick={() => handleMute(user, 168)} className="text-yellow-400">
                                                    <VolumeX className="h-4 w-4 mr-2" />
                                                    Mutar 7 dias
                                                </DropdownMenuItem>
                                            </>
                                        ) : (
                                            <DropdownMenuItem onClick={() => handleUnmute(user)} className="text-green-400">
                                                <Volume2 className="h-4 w-4 mr-2" />
                                                Desmutar
                                            </DropdownMenuItem>
                                        )}

                                        <DropdownMenuSeparator className="bg-[#3a3a3a]" />

                                        {/* Exportar */}
                                        <DropdownMenuItem onClick={() => exportUserData(user)} className="text-gray-400">
                                            <Download className="h-4 w-4 mr-2" />
                                            Exportar Dados
                                        </DropdownMenuItem>
                                    </DropdownMenuContent>
                                </DropdownMenu>
                            </div>
                        ))}
                        {filteredUsers.length === 0 && (
                            <p className="text-center text-gray-400 py-8">Nenhum usuário encontrado</p>
                        )}
                        {filteredUsers.length > 50 && (
                            <p className="text-center text-gray-400 py-2 text-sm">Mostrando 50 de {filteredUsers.length} resultados. Refine sua busca.</p>
                        )}
                    </div>
                </CardContent>
            </Card>

            {/* Lista de Admins */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                        <Shield className="h-5 w-5 text-purple-400" />
                        Administradores e Suporte
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-3">
                        {users?.filter(u => u.role === 'admin' || u.role === 'support').map(admin => (
                            <div key={admin.user_id} className="flex items-center justify-between p-3 bg-[#2a2a2a] rounded-lg">
                                <div className="flex items-center gap-3">
                                    <Avatar className="h-10 w-10">
                                        <AvatarImage src={admin.avatar_url} />
                                        <AvatarFallback className="bg-gradient-to-r from-purple-600 to-pink-600 text-white">
                                            {admin.username?.charAt(0)?.toUpperCase()}
                                        </AvatarFallback>
                                    </Avatar>
                                    <div>
                                        <p className="text-white font-medium">{admin.username}</p>
                                        <p className="text-xs text-gray-400">{admin.email}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-3">
                                    <Badge className={admin.role === 'admin' ? 'bg-purple-600' : 'bg-blue-600'}>
                                        {admin.role === 'admin' ? 'Admin' : 'Suporte'}
                                    </Badge>
                                    {admin.email !== 'auxiliodp1@gmail.com' && (
                                        <Button
                                            size="sm"
                                            variant="ghost"
                                            className="text-red-400 hover:text-red-300 hover:bg-red-500/10"
                                            onClick={() => handleRemoveAdmin(admin.user_id, admin.email || '', admin.username)}
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>

            {/* Dialog Adicionar Admin */}
            <Dialog open={showAddAdminDialog} onOpenChange={setShowAddAdminDialog}>
                <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <DialogHeader>
                        <DialogTitle className="text-white">Adicionar Novo Admin</DialogTitle>
                        <DialogDescription className="text-gray-400">
                            Digite o email de um usuário existente para torná-lo admin
                        </DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="space-y-2">
                            <Label className="text-white">Email do usuário</Label>
                            <Input
                                value={newAdminEmail}
                                onChange={(e) => setNewAdminEmail(e.target.value)}
                                placeholder="email@exemplo.com"
                                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label className="text-white">Nível de acesso</Label>
                            <Select value={newAdminRole} onValueChange={(v: 'admin' | 'support') => setNewAdminRole(v)}>
                                <SelectTrigger className="bg-[#2a2a2a] border-[#3a3a3a] text-white">
                                    <SelectValue />
                                </SelectTrigger>
                                <SelectContent className="bg-[#2a2a2a] border-[#3a3a3a]">
                                    <SelectItem value="admin" className="text-white">Administrador (controle total)</SelectItem>
                                    <SelectItem value="support" className="text-white">Suporte (acesso limitado)</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setShowAddAdminDialog(false)} className="border-[#3a3a3a] text-white">
                            Cancelar
                        </Button>
                        <Button onClick={handleAddAdmin} className="bg-purple-600 hover:bg-purple-700" disabled={changeRole.isPending}>
                            {changeRole.isPending ? 'Adicionando...' : 'Adicionar Admin'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Dialog Mudar Plano */}
            <Dialog open={showPlanDialog} onOpenChange={setShowPlanDialog}>
                <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <DialogHeader>
                        <DialogTitle className="text-white">Alterar Plano</DialogTitle>
                        <DialogDescription className="text-gray-400">
                            Alterar plano de {selectedUser?.username}
                        </DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <Select value={newPlan} onValueChange={(v: 'free' | 'diamond') => setNewPlan(v)}>
                            <SelectTrigger className="bg-[#2a2a2a] border-[#3a3a3a] text-white">
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent className="bg-[#2a2a2a] border-[#3a3a3a]">
                                <SelectItem value="free" className="text-white">Free</SelectItem>
                                <SelectItem value="diamond" className="text-cyan-400">💎 Diamond</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setShowPlanDialog(false)} className="border-[#3a3a3a] text-white">
                            Cancelar
                        </Button>
                        <Button onClick={handleChangePlan} className="bg-cyan-600 hover:bg-cyan-700" disabled={changePlan.isPending}>
                            {changePlan.isPending ? 'Alterando...' : 'Salvar'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Dialog Ver Detalhes do Usuário */}
            <Dialog open={showUserDetailsDialog} onOpenChange={setShowUserDetailsDialog}>
                <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a] max-w-lg">
                    <DialogHeader>
                        <DialogTitle className="text-white flex items-center gap-3">
                            <Avatar className="h-12 w-12">
                                <AvatarImage src={selectedUser?.avatar_url} />
                                <AvatarFallback className="bg-gradient-to-r from-orange-500 to-pink-500 text-white text-lg">
                                    {selectedUser?.username?.charAt(0)?.toUpperCase()}
                                </AvatarFallback>
                            </Avatar>
                            <div>
                                <p>{selectedUser?.username}</p>
                                <p className="text-sm font-normal text-gray-400">{selectedUser?.full_name}</p>
                            </div>
                        </DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div>
                                <p className="text-gray-400">Email</p>
                                <p className="text-white">{selectedUser?.email || '-'}</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Telefone</p>
                                <p className="text-white">{selectedUser?.telefone || '-'}</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Plano</p>
                                <p className={selectedUser?.subscription_plan === 'diamond' ? 'text-cyan-400' : 'text-white'}>
                                    {selectedUser?.subscription_plan === 'diamond' ? '💎 Diamond' : 'Free'}
                                </p>
                            </div>
                            <div>
                                <p className="text-gray-400">Pontos</p>
                                <p className="text-white">{selectedUser?.points || 0}</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Role</p>
                                <p className="text-white">{selectedUser?.role || 'user'}</p>
                            </div>
                            <div>
                                <p className="text-gray-400">Status</p>
                                <div className="flex gap-2">
                                    {selectedUser?.is_banned ? <Badge className="bg-red-600">Banido</Badge> : <Badge className="bg-green-600">Ativo</Badge>}
                                    {selectedUser?.is_muted && <Badge className="bg-orange-600">Mutado</Badge>}
                                </div>
                            </div>
                            <div className="col-span-2">
                                <p className="text-gray-400">Data de Cadastro</p>
                                <p className="text-white">{selectedUser?.created_at ? new Date(selectedUser.created_at).toLocaleString('pt-BR') : '-'}</p>
                            </div>
                            <div className="col-span-2">
                                <p className="text-gray-400">ID do Usuário</p>
                                <p className="text-white text-xs font-mono">{selectedUser?.user_id}</p>
                            </div>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => { if (selectedUser) exportUserData(selectedUser); }} className="border-cyan-500 text-cyan-400">
                            <Download className="h-4 w-4 mr-2" />
                            Exportar
                        </Button>
                        <Button onClick={() => setShowUserDetailsDialog(false)} className="bg-gray-700 hover:bg-gray-600">
                            Fechar
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Dialog Notificar Todos */}
            <Dialog open={showNotifyDialog} onOpenChange={setShowNotifyDialog}>
                <DialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                    <DialogHeader>
                        <DialogTitle className="text-white flex items-center gap-2">
                            <Bell className="h-5 w-5 text-yellow-400" />
                            Enviar Notificação para Todos
                        </DialogTitle>
                        <DialogDescription className="text-gray-400">
                            A notificação será enviada para todos os usuários que habilitaram push notifications
                        </DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="space-y-2">
                            <Label className="text-white">Título da Notificação *</Label>
                            <Input
                                value={notifyTitle}
                                onChange={(e) => setNotifyTitle(e.target.value)}
                                placeholder="Ex: Nova aula disponível!"
                                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                maxLength={50}
                            />
                            <p className="text-xs text-gray-500">{notifyTitle.length}/50 caracteres</p>
                        </div>
                        <div className="space-y-2">
                            <Label className="text-white">Mensagem *</Label>
                            <Input
                                value={notifyMessage}
                                onChange={(e) => setNotifyMessage(e.target.value)}
                                placeholder="Ex: Confira o novo conteúdo exclusivo que acabou de sair!"
                                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                maxLength={200}
                            />
                            <p className="text-xs text-gray-500">{notifyMessage.length}/200 caracteres</p>
                        </div>
                        <div className="space-y-2">
                            <Label className="text-white">URL de Destino (opcional)</Label>
                            <Input
                                value={notifyUrl}
                                onChange={(e) => setNotifyUrl(e.target.value)}
                                placeholder="https://sociedadenutra.com/aula"
                                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                            />
                            <p className="text-xs text-gray-500">Quando o usuário clicar na notificação, será redirecionado para esta URL</p>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setShowNotifyDialog(false)} className="border-[#3a3a3a] text-white">
                            Cancelar
                        </Button>
                        <Button
                            onClick={handleNotifyAll}
                            className="bg-yellow-600 hover:bg-yellow-700"
                            disabled={isSendingNotification}
                        >
                            {isSendingNotification ? 'Enviando...' : 'Enviar Notificação'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
