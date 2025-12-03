import { Gem, Check, Zap, Lock } from 'lucide-react';
import { MainLayout } from '@/components/layout/MainLayout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';

const benefits = [
  'Acesso ao Chat da Comunidade',
  'Visualizar Ranking completo',
  'Resgatar Prêmios exclusivos',
  'Participar de sorteios',
  'Badge Diamond exclusivo',
  'Suporte prioritário',
];

export default function Upgrade() {
  const navigate = useNavigate();

  const handleUpgrade = () => {
    toast.info('Sistema de pagamento em desenvolvimento. Entre em contato com o suporte.');
    // TODO: Integrar com sistema de pagamento (Stripe, MercadoPago, etc)
  };

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto px-4 pb-20 pt-4">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center bg-gradient-to-r from-cyan-500 to-blue-500 rounded-2xl p-4 mb-4 shadow-glow">
            <Gem className="h-10 w-10 text-white" />
          </div>
          <h1 className="font-display text-3xl font-bold text-white mb-2">
            Plano Diamond
          </h1>
          <p className="text-gray-400">
            Desbloqueie todo o potencial da comunidade
          </p>
        </div>

        {/* Pricing Card */}
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a] overflow-hidden mb-6">
          <div className="bg-gradient-to-r from-cyan-500/20 to-blue-500/20 border-b border-cyan-500/30 p-6 text-center">
            <Badge className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white mb-3">
              <Zap className="h-3 w-3 mr-1" />
              Mais popular
            </Badge>
            <div className="mb-2">
              <span className="text-5xl font-bold text-white">R$ 197</span>
              <span className="text-gray-400 ml-2">/mês</span>
            </div>
            <p className="text-sm text-gray-400">
              Cancele quando quiser
            </p>
          </div>

          <CardContent className="p-6 space-y-4">
            {benefits.map((benefit, index) => (
              <div key={index} className="flex items-start gap-3">
                <div className="bg-primary/20 rounded-full p-1 mt-0.5">
                  <Check className="h-4 w-4 text-primary" />
                </div>
                <span className="text-white">{benefit}</span>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* CTA Buttons */}
        <div className="space-y-3">
          <Button
            onClick={handleUpgrade}
            className="w-full h-14 text-lg font-semibold bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-600 hover:to-blue-600"
          >
            <Gem className="h-5 w-5 mr-2" />
            Assinar Plano Diamond
          </Button>
          <Button
            onClick={() => navigate('/')}
            variant="outline"
            className="w-full border-[#2a2a2a] text-gray-400 hover:text-white hover:bg-[#2a2a2a]"
          >
            Voltar ao Feed
          </Button>
        </div>

        {/* Free Plan Info */}
        <Card className="border border-[#2a2a2a] bg-[#1a1a1a] mt-6">
          <CardHeader>
            <CardTitle className="text-white text-base flex items-center gap-2">
              <Lock className="h-4 w-4 text-gray-400" />
              Plano Gratuito
            </CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-gray-400 space-y-2">
            <p>✓ Acesso ao Feed da comunidade</p>
            <p>✓ Suporte via chat</p>
            <p className="text-primary mt-4">
              Faça upgrade para Diamond e desbloqueie tudo!
            </p>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}

