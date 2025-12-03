import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, Users, MessageSquare, Trash2, Ban, CheckCircle, LogOut, Home, Gift } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useSupportUsers, useBanUser, useUnbanUser, useIsSupport } from '@/hooks/useSupport';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { SupportChat } from '@/components/support/SupportChat';
import { UserManagement } from '@/components/support/UserManagement';
import { RewardManagement } from '@/components/support/RewardManagement';

export default function SupportDashboard() {
  const navigate = useNavigate();
  const { signOut } = useAuth();
  const isSupport = useIsSupport();
  const [activeTab, setActiveTab] = useState('chat');

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
    await signOut();
    navigate('/support/login');
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
              <p className="text-xs text-gray-400">Nutra Elite</p>
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

      <div className="container py-6">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
          <TabsList className="bg-[#1a1a1a] border border-[#2a2a2a]">
            <TabsTrigger value="chat" className="data-[state=active]:bg-primary">
              <MessageSquare className="h-4 w-4 mr-2" />
              Chat de Suporte
            </TabsTrigger>
            <TabsTrigger value="rewards" className="data-[state=active]:bg-primary">
              <Gift className="h-4 w-4 mr-2" />
              Resgates de Prêmios
            </TabsTrigger>
            <TabsTrigger value="users" className="data-[state=active]:bg-primary">
              <Users className="h-4 w-4 mr-2" />
              Gerenciar Usuários
            </TabsTrigger>
          </TabsList>

          <TabsContent value="chat" className="space-y-4">
            <SupportChat />
          </TabsContent>

          <TabsContent value="rewards" className="space-y-4">
            <RewardManagement />
          </TabsContent>

          <TabsContent value="users" className="space-y-4">
            <UserManagement />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}

