import { useState } from 'react';
import { Crown, Users, Shield, BarChart3, Database, Bell, BookOpen, Trash2, Plus, Settings } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useIsSupremeAdmin } from '@/hooks/useSupremeAdmin';
import { useSupportUsers, useChangeUserRole } from '@/hooks/useSupport';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export function SupremeAdminPanel() {
    const isSupreme = useIsSupremeAdmin();
    const { data: users } = useSupportUsers();
    const changeRole = useChangeUserRole();
    const [activeSection, setActiveSection] = useState('overview');
    const [showAddAdminDialog, setShowAddAdminDialog] = useState(false);
    const [newAdminEmail, setNewAdminEmail] = useState('');
    const [newAdminRole, setNewAdminRole] = useState<'admin' | 'support'>('admin');

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

    const handleExportData = () => {
        if (!users) return;

        const csvContent = [
            ['ID', 'Username', 'Email', 'Plano', 'Pontos', 'Role', 'Banido', 'Mutado'].join(','),
            ...users.map(u => [
                u.user_id,
                u.username,
                u.email || '',
                u.subscription_plan || 'free',
                u.points || 0,
                u.role || 'user',
                u.is_banned ? 'Sim' : 'Não',
                u.is_muted ? 'Sim' : 'Não'
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
                        Exportar Dados
                    </Button>
                    <Button
                        variant="outline"
                        className="border-yellow-500 text-yellow-400 hover:bg-yellow-500/10"
                        onClick={() => toast.info('Em breve: Enviar notificação para todos')}
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

            {/* Lista de Admins */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                        <Users className="h-5 w-5 text-purple-400" />
                        Administradores e Suporte
                    </CardTitle>
                    <CardDescription className="text-gray-400">
                        Gerencie quem tem acesso ao painel administrativo
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-3">
                        {users?.filter(u => u.role === 'admin' || u.role === 'support').map(admin => (
                            <div key={admin.user_id} className="flex items-center justify-between p-3 bg-[#2a2a2a] rounded-lg">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-gradient-to-r from-purple-600 to-pink-600 flex items-center justify-center">
                                        <span className="text-white font-bold">{admin.username?.charAt(0)?.toUpperCase()}</span>
                                    </div>
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
                        {users?.filter(u => u.role === 'admin' || u.role === 'support').length === 0 && (
                            <p className="text-center text-gray-400 py-4">Nenhum admin cadastrado</p>
                        )}
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
        </div>
    );
}
