import { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { supabase } from '@/integrations/supabase/client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import { Eye, EyeOff, Lock, Mail, ArrowLeft } from 'lucide-react';

export default function ResetPassword() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [verifying, setVerifying] = useState(true);

  useEffect(() => {
    // Verificar se há um hash de recuperação na URL
    // O Supabase coloca os parâmetros no hash da URL, não na query string
    const hash = window.location.hash;
    const urlParams = new URLSearchParams(hash.substring(1)); // Remove o #
    const accessToken = urlParams.get('access_token');
    const type = urlParams.get('type');

    // Também verificar query params (caso o Supabase use)
    const queryAccessToken = searchParams.get('access_token');
    const queryType = searchParams.get('type');

    if ((!accessToken && !queryAccessToken) || (type !== 'recovery' && queryType !== 'recovery')) {
      // Se não tiver o token, pode ser que o usuário já tenha feito login ou está acessando diretamente
      // Nesse caso, verificar se há uma sessão ativa
      supabase.auth.getSession().then(({ data: { session } }) => {
        if (session) {
          // Já tem sessão, pode prosseguir
          setVerifying(false);
        } else {
          toast.error('Link inválido ou expirado. Por favor, solicite um novo link de recuperação.');
          navigate('/auth');
        }
      });
      return;
    }

    setVerifying(false);
  }, [searchParams, navigate]);

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!password.trim()) {
      toast.error('Por favor, insira uma senha');
      return;
    }

    if (password.length < 6) {
      toast.error('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (password !== confirmPassword) {
      toast.error('As senhas não coincidem');
      return;
    }

    setLoading(true);

    try {
      const { error } = await supabase.auth.updateUser({
        password: password,
      });

      if (error) {
        toast.error('Erro ao atualizar senha: ' + error.message);
      } else {
        toast.success('Senha atualizada com sucesso!');
        navigate('/auth');
      }
    } catch (err: any) {
      toast.error('Erro ao atualizar senha. Tente novamente.');
      console.error('Erro ao resetar senha:', err);
    } finally {
      setLoading(false);
    }
  };

  if (verifying) {
    return (
      <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center p-4">
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a] shadow-lg w-full max-w-md">
          <CardContent className="pt-6">
            <p className="text-white text-center">Verificando link de recuperação...</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center p-4">
      <div className="w-full max-w-md animate-fade-in">
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a] shadow-lg">
          <CardHeader className="space-y-1 pb-4">
            <CardTitle className="text-2xl font-display text-center text-white">
              Redefinir senha
            </CardTitle>
            <CardDescription className="text-center text-gray-400">
              Digite sua nova senha abaixo
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleResetPassword} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="password" className="text-white">Nova senha</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="pl-10 pr-10 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
                <p className="text-xs text-gray-400">Mínimo de 6 caracteres</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword" className="text-white">Confirmar senha</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                  <Input
                    id="confirmPassword"
                    type={showConfirmPassword ? 'text' : 'password'}
                    placeholder="••••••••"
                    className="pl-10 pr-10 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-white transition-colors"
                  >
                    {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <Button 
                type="submit" 
                className="w-full bg-primary hover:bg-primary/90 text-white" 
                disabled={loading}
              >
                {loading ? 'Atualizando...' : 'Atualizar senha'}
              </Button>

              <div className="mt-4 text-center">
                <button
                  type="button"
                  onClick={() => navigate('/auth')}
                  className="text-sm text-gray-400 hover:text-primary transition-colors flex items-center justify-center gap-2 mx-auto"
                >
                  <ArrowLeft className="h-4 w-4" />
                  Voltar para login
                </button>
              </div>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

