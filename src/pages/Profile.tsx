import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Camera, LogOut, Save } from 'lucide-react';
import { MainLayout } from '@/components/layout/MainLayout';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useProfile, useUpdateProfile } from '@/hooks/useProfile';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';

export default function Profile() {
  const navigate = useNavigate();
  const { user, signOut } = useAuth();
  const { data: profile, isLoading } = useProfile();
  const updateProfile = useUpdateProfile();
  
  const [formData, setFormData] = useState({
    username: '',
    full_name: '',
    bio: '',
    avatar_url: '',
  });
  const [hasChanges, setHasChanges] = useState(false);

  // Initialize form data when profile loads
  useState(() => {
    if (profile) {
      setFormData({
        username: profile.username || '',
        full_name: profile.full_name || '',
        bio: profile.bio || '',
        avatar_url: profile.avatar_url || '',
      });
    }
  });

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    setHasChanges(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.username.trim()) {
      toast.error('O nome de usuário é obrigatório');
      return;
    }

    try {
      await updateProfile.mutateAsync({
        username: formData.username,
        full_name: formData.full_name || null,
        bio: formData.bio || null,
        avatar_url: formData.avatar_url || null,
      });
      toast.success('Perfil atualizado!');
      setHasChanges(false);
    } catch (error) {
      toast.error('Erro ao atualizar perfil');
    }
  };

  const handleSignOut = async () => {
    await signOut();
    navigate('/auth');
  };

  if (isLoading) {
    return (
      <MainLayout>
        <div className="max-w-2xl mx-auto">
          <div className="animate-pulse space-y-4">
            <div className="h-40 bg-muted rounded-lg" />
            <div className="h-64 bg-muted rounded-lg" />
          </div>
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto space-y-6">
        {/* Profile Header */}
        <Card className="overflow-hidden">
          <div className="gradient-primary h-24" />
          <CardContent className="relative pt-0 pb-6">
            <div className="flex flex-col items-center -mt-12">
              <div className="relative">
                <Avatar className="h-24 w-24 border-4 border-card">
                  <AvatarImage src={formData.avatar_url || profile?.avatar_url || ''} />
                  <AvatarFallback className="gradient-primary text-primary-foreground text-2xl font-bold">
                    {(formData.username || profile?.username)?.charAt(0).toUpperCase() || 'U'}
                  </AvatarFallback>
                </Avatar>
                <div className="absolute bottom-0 right-0 rounded-full bg-secondary p-2 text-secondary-foreground">
                  <Camera className="h-4 w-4" />
                </div>
              </div>
              <h2 className="font-display text-xl font-bold mt-4">
                {formData.username || profile?.username || 'Usuário'}
              </h2>
              <p className="text-muted-foreground text-sm">{user?.email}</p>
              <div className="flex items-center gap-2 mt-2">
                <span className="text-2xl font-display font-bold text-primary">
                  {profile?.points || 0}
                </span>
                <span className="text-sm text-muted-foreground">pontos</span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Edit Profile */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <User className="h-5 w-5 text-primary" />
              Editar Perfil
            </CardTitle>
            <CardDescription>
              Atualize suas informações pessoais
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="username">Nome de usuário</Label>
                <Input
                  id="username"
                  placeholder="Seu nome de usuário"
                  value={formData.username || profile?.username || ''}
                  onChange={(e) => handleChange('username', e.target.value)}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="full_name">Nome completo</Label>
                <Input
                  id="full_name"
                  placeholder="Seu nome completo"
                  value={formData.full_name || profile?.full_name || ''}
                  onChange={(e) => handleChange('full_name', e.target.value)}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="avatar_url">URL do avatar</Label>
                <Input
                  id="avatar_url"
                  type="url"
                  placeholder="https://exemplo.com/sua-foto.jpg"
                  value={formData.avatar_url || profile?.avatar_url || ''}
                  onChange={(e) => handleChange('avatar_url', e.target.value)}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="bio">Bio</Label>
                <Textarea
                  id="bio"
                  placeholder="Conte um pouco sobre você..."
                  className="resize-none"
                  value={formData.bio || profile?.bio || ''}
                  onChange={(e) => handleChange('bio', e.target.value)}
                />
              </div>

              <Button 
                type="submit" 
                className="w-full"
                disabled={updateProfile.isPending || !hasChanges}
              >
                <Save className="h-4 w-4 mr-2" />
                {updateProfile.isPending ? 'Salvando...' : 'Salvar Alterações'}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Logout */}
        <Card className="border-destructive/20">
          <CardContent className="pt-6">
            <Button 
              variant="destructive" 
              className="w-full"
              onClick={handleSignOut}
            >
              <LogOut className="h-4 w-4 mr-2" />
              Sair da Conta
            </Button>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}
