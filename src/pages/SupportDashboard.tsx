import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, Users, MessageSquare, LogOut, Home, Gift, BookOpen, Trophy } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useIsSupport } from '@/hooks/useSupport';
import { useIsAdmin } from '@/hooks/useAdmin';
import { useAuth } from '@/contexts/AuthContext';
import { SupportChat } from '@/components/support/SupportChat';
import { UserManagement } from '@/components/support/UserManagement';
import { RewardManagement } from '@/components/support/RewardManagement';
import { ContentManagement } from '@/components/support/ContentManagement';
import { BadgeManagement } from '@/components/support/BadgeManagement';
import { cn } from '@/lib/utils';

export default function SupportDashboard() {
  const navigate = useNavigate();
  const { signOut } = useAuth();
  const isSupport = useIsSupport();
  const isAdmin = useIsAdmin();
  const [activeTab, setActiveTab] = useState('chat');

  // Apenas admin@gmail.com pode acessar o painel admin (aba Usuários)
  // Suporte normal pode acessar Chat e Resgates
  const canAccessAdminPanel = isAdmin;

  if (!isSupport) {
    return (
      <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center">
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
          <CardContent className="pt-6">
            <p className="text-white text-center">Acesso negado. Apenas suporte pode acessar esta área.</p>
            <Button onClick={() => navigate('/')} className="w-full mt-4">
              Voltar
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const handleSignOut = async () => {
    try {
      console.log('🔄 Iniciando logout...');
      
      // Fazer logout do Supabase
      await signOut();
      
      console.log('✅ Logout concluído, redirecionando...');
      
      // Limpar localStorage e sessionStorage
      localStorage.clear();
      sessionStorage.clear();
      
      // Aguardar um pouco para garantir que tudo foi limpo
      await new Promise(resolve => setTimeout(resolve, 200));
      
      // Forçar navegação completa
      window.location.replace('/support/login');
    } catch (error) {
      console.error('❌ Erro ao fazer logout:', error);
      
      // Mesmo com erro, limpar tudo e forçar navegação
      localStorage.clear();
      sessionStorage.clear();
      window.location.replace('/support/login');
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      {/* Header */}
      <header className="border-b border-[#2a2a2a] bg-[#1a1a1a]">
        <div className="container flex h-16 items-center justify-between">
          <div className="flex items-center gap-4">
            <Shield className="h-6 w-6 text-primary" />
            <div>
              <h1 className="text-xl font-bold text-white">Painel de Suporte</h1>
              <p className="text-xs text-gray-400">Sociedade Nutra</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate('/')}
              className="text-gray-400 hover:text-white"
            >
              <Home className="h-4 w-4 mr-2" />
              App
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={handleSignOut}
              className="text-gray-400 hover:text-white"
            >
              <LogOut className="h-4 w-4 mr-2" />
              Sair
            </Button>
          </div>
        </div>
      </header>

      <div className="container py-6 px-4">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
          <TabsList className={cn(
            "bg-[#1a1a1a] border border-[#2a2a2a] w-full grid",
            canAccessAdminPanel ? "grid-cols-5" : "grid-cols-4"
          )}>
            <TabsTrigger value="chat" className="data-[state=active]:bg-primary text-xs">
              <MessageSquare className="h-4 w-4 sm:mr-2" />
              <span className="hidden sm:inline">Chat</span>
            </TabsTrigger>
            <TabsTrigger value="rewards" className="data-[state=active]:bg-primary text-xs">
              <Gift className="h-4 w-4 sm:mr-2" />
              <span className="hidden sm:inline">Resgates</span>
            </TabsTrigger>
            <TabsTrigger value="badges" className="data-[state=active]:bg-primary text-xs">
              <Trophy className="h-4 w-4 sm:mr-2" />
              <span className="hidden sm:inline">Conquistas</span>
            </TabsTrigger>
            <TabsTrigger value="content" className="data-[state=active]:bg-primary text-xs">
              <BookOpen className="h-4 w-4 sm:mr-2" />
              <span className="hidden sm:inline">Conteúdo</span>
            </TabsTrigger>
            {canAccessAdminPanel && (
              <TabsTrigger value="users" className="data-[state=active]:bg-primary text-xs">
                <Users className="h-4 w-4 sm:mr-2" />
                <span className="hidden sm:inline">Usuários</span>
              </TabsTrigger>
            )}
          </TabsList>

          <TabsContent value="chat" className="space-y-4">
            <SupportChat />
          </TabsContent>

          <TabsContent value="rewards" className="space-y-4">
            <RewardManagement />
          </TabsContent>

          <TabsContent value="badges" className="space-y-4">
            <BadgeManagement />
          </TabsContent>

          <TabsContent value="content" className="space-y-4">
            <ContentManagement />
          </TabsContent>

          {canAccessAdminPanel && (
            <TabsContent value="users" className="space-y-4">
              <UserManagement />
            </TabsContent>
          )}
        </Tabs>
      </div>
    </div>
  );
}

