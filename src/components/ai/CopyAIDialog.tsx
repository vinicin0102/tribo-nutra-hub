import { useState } from 'react';
import { Zap } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

interface CopyAIDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function CopyAIDialog({ open, onOpenChange }: CopyAIDialogProps) {
  const [productName, setProductName] = useState('');
  const [targetAudience, setTargetAudience] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerate = async () => {
    if (!productName.trim()) {
      toast.error('Por favor, informe o nome do produto');
      return;
    }

    setIsGenerating(true);
    
    // Simular geração (aqui você pode integrar com a API real)
    setTimeout(() => {
      setIsGenerating(false);
      toast.success('Copy gerada com sucesso!');
      // Aqui você pode abrir um modal com o resultado ou copiar para área de transferência
    }, 2000);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl w-full mx-4 bg-[#1a1a1a] border-[#2a2a2a] text-white p-0 overflow-hidden max-h-[90vh] overflow-y-auto">
        <div className="p-6 space-y-6">
          {/* Tag IA de Copy no topo */}
          <div className="flex justify-center -mt-2">
            <div className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-gradient-to-r from-[#D97706] to-[#92400E] shadow-lg">
              <Zap className="h-4 w-4 text-white fill-white" />
              <span className="text-white font-semibold text-sm">IA de Copy</span>
            </div>
          </div>

          {/* Título e Subtítulo */}
          <DialogHeader className="text-center space-y-2">
            <h2 className="text-3xl font-bold text-white">
              Gerador de Copy Inteligente
            </h2>
            <p className="text-gray-400 text-base">
              Crie copies persuasivas para seus anúncios em segundos
            </p>
          </DialogHeader>

          {/* Card do Formulário */}
          <div className="bg-[#2a2a2a] rounded-lg p-6 space-y-6">
            {/* Campo Nome do Produto */}
            <div className="space-y-2">
              <Label htmlFor="product-name" className="text-white">
                Nome do Produto *
              </Label>
              <Input
                id="product-name"
                placeholder="Ex: Cápsula Detox Pro"
                value={productName}
                onChange={(e) => setProductName(e.target.value)}
                className="bg-[#1a1a1a] border-[#3a3a3a] text-white placeholder:text-gray-500 focus:border-primary"
              />
            </div>

            {/* Campo Público-alvo */}
            <div className="space-y-2">
              <Label htmlFor="target-audience" className="text-white">
                Público-alvo <span className="text-gray-400">(opcional)</span>
              </Label>
              <Input
                id="target-audience"
                placeholder="Ex: Mulheres 30-50 anos"
                value={targetAudience}
                onChange={(e) => setTargetAudience(e.target.value)}
                className="bg-[#1a1a1a] border-[#3a3a3a] text-white placeholder:text-gray-500 focus:border-primary"
              />
            </div>

            {/* Botão Gerar Copy Completa */}
            <Button
              onClick={handleGenerate}
              disabled={isGenerating || !productName.trim()}
              className="w-full h-12 rounded-lg bg-gradient-to-r from-[#D97706] to-[#92400E] hover:from-[#D97706]/90 hover:to-[#92400E]/90 text-white font-semibold text-base shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Zap className="h-5 w-5 mr-2 fill-white" />
              {isGenerating ? 'Gerando Copy...' : 'Gerar Copy Completa'}
            </Button>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
