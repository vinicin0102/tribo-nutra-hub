import { User, LogOut, Settings, Shield, HelpCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from '@/hooks/useProfile';
import { useIsAdmin } from '@/hooks/useAdmin';
import { useHasDiamondAccess } from '@/hooks/useSubscription';

export function Navbar() {
  const navigate = useNavigate();
  const { user, signOut } = useAuth();
  const { data: profile } = useProfile();
  const isAdmin = useIsAdmin();
  const hasDiamondAccess = useHasDiamondAccess();

  const handleSignOut = async () => {
    try {
      await signOut();
      localStorage.clear();
      sessionStorage.clear();
      window.location.replace('/auth');
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
      localStorage.clear();
      sessionStorage.clear();
      window.location.replace('/auth');
    }
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-50 border-b border-[#2a2a2a] bg-[#1a1a1a]/95 backdrop-blur-md" style={{ paddingTop: 'max(0px, env(safe-area-inset-top))' }}>
      <div className="container flex h-16 items-center justify-between">
        <div 
          className="flex items-center gap-2 cursor-pointer" 
          onClick={() => navigate('/')}
        >
          <span className="font-display text-lg font-semibold">
            <span className="text-white">Comunidade dos</span>
            <span className="text-primary"> Sócios</span>
          </span>
        </div>

        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="relative h-10 w-10 rounded-full p-0">
                <Avatar className="h-10 w-10 border-2 border-primary/20">
                  <AvatarImage 
                    src={profile?.avatar_url || ''} 
                    alt={profile?.username}
                    className="object-cover object-center"
                  />
                  <AvatarFallback className="gradient-primary text-primary-foreground font-semibold">
                    {profile?.username?.charAt(0).toUpperCase() || user?.email?.charAt(0).toUpperCase() || 'U'}
                  </AvatarFallback>
                </Avatar>
                {!hasDiamondAccess && (
                  <div 
                    className="absolute -bottom-1 -right-1 bg-gradient-to-r from-cyan-500 to-blue-500 text-white text-[8px] font-bold px-1.5 py-0.5 rounded-full border-2 border-[#1a1a1a] cursor-pointer hover:scale-110 transition-transform shadow-lg"
                    onClick={(e) => {
                      e.stopPropagation();
                      navigate('/upgrade');
                    }}
                    title="Assine o Plano Diamond"
                  >
                    💎
                  </div>
                )}
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-56" align="end" forceMount>
              <div className="flex items-center gap-2 p-2">
                <Avatar className="h-10 w-10">
                  <AvatarImage 
                    src={profile?.avatar_url || ''} 
                    className="object-cover object-center"
                  />
                  <AvatarFallback className="gradient-primary text-primary-foreground">
                    {profile?.username?.charAt(0).toUpperCase() || 'U'}
                  </AvatarFallback>
                </Avatar>
                <div className="flex flex-col">
                  <span className="text-sm font-semibold">{profile?.username || 'Usuário'}</span>
                  <span className="text-xs text-muted-foreground">{profile?.points || 0} pontos</span>
                </div>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={() => navigate('/profile')}>
                <User className="mr-2 h-4 w-4" />
                Meu Perfil
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => navigate('/profile')}>
                <Settings className="mr-2 h-4 w-4" />
                Configurações
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => navigate('/support')}>
                <HelpCircle className="mr-2 h-4 w-4" />
                Suporte
              </DropdownMenuItem>
              {isAdmin && (
                <>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem 
                    onClick={() => navigate('/support/dashboard')}
                    className="text-primary focus:text-primary"
                  >
                    <Shield className="mr-2 h-4 w-4" />
                    Painel Admin
                  </DropdownMenuItem>
                </>
              )}
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleSignOut} className="text-destructive focus:text-destructive">
                <LogOut className="mr-2 h-4 w-4" />
                Sair
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}
