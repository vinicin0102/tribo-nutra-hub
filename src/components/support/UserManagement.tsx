import { useState } from 'react';
import { Ban, CheckCircle, Trash2, Search } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useSupportUsers, useBanUser, useUnbanUser } from '@/hooks/useSupport';
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

export function UserManagement() {
  const { data: users = [], isLoading } = useSupportUsers();
  const banUser = useBanUser();
  const unbanUser = useUnbanUser();
  const [searchTerm, setSearchTerm] = useState('');

  const filteredUsers = users.filter(
    (user) =>
      user.username?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleBan = async (userId: string, username: string) => {
    try {
      await banUser.mutateAsync(userId);
      toast.success(`Usuário ${username} foi banido`);
    } catch (error) {
      toast.error('Erro ao banir usuário');
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

  if (isLoading) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardContent className="pt-6">
          <p className="text-gray-400 text-center">Carregando usuários...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
      <CardHeader>
        <CardTitle className="text-white">Gerenciar Usuários</CardTitle>
        <div className="mt-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Buscar por nome, username ou email..."
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
                    <div className="flex items-center gap-2 mt-1">
                      <span className="text-xs text-gray-500">{user.points || 0} pontos</span>
                      {user.role && (
                        <span className="text-xs px-2 py-0.5 rounded bg-primary/20 text-primary">
                          {user.role}
                        </span>
                      )}
                      {user.is_banned && (
                        <span className="text-xs px-2 py-0.5 rounded bg-red-500/20 text-red-500">
                          Banido
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {user.is_banned ? (
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-green-400 hover:text-green-300"
                        >
                          <CheckCircle className="h-4 w-4 mr-2" />
                          Desbanir
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                        <AlertDialogHeader>
                          <AlertDialogTitle className="text-white">
                            Desbanir usuário
                          </AlertDialogTitle>
                          <AlertDialogDescription className="text-gray-400">
                            Tem certeza que deseja desbanir {user.username}? Ele terá acesso
                            novamente à plataforma.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                            Cancelar
                          </AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() => handleUnban(user.user_id, user.username)}
                            className="bg-primary hover:bg-primary/90"
                          >
                            Desbanir
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  ) : (
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button
                          variant="ghost"
                          size="sm"
                          className="text-red-400 hover:text-red-300"
                        >
                          <Ban className="h-4 w-4 mr-2" />
                          Banir
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                        <AlertDialogHeader>
                          <AlertDialogTitle className="text-white">
                            Banir usuário
                          </AlertDialogTitle>
                          <AlertDialogDescription className="text-gray-400">
                            Tem certeza que deseja banir {user.username}? Ele perderá acesso
                            à plataforma.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                            Cancelar
                          </AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() => handleBan(user.user_id, user.username)}
                            className="bg-red-500 hover:bg-red-600"
                          >
                            Banir
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </CardContent>
    </Card>
  );
}

