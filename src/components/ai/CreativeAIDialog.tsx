import { useState } from 'react';
import { Zap, Copy, Check } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

interface CreativeAIDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

type Platform = 'instagram' | 'facebook' | 'tiktok';

export function CreativeAIDialog({ open, onOpenChange }: CreativeAIDialogProps) {
  const [productName, setProductName] = useState('');
  const [platform, setPlatform] = useState<Platform>('instagram');
  const [isGenerating, setIsGenerating] = useState(false);
  const [generatedScript, setGeneratedScript] = useState('');
  const [copied, setCopied] = useState(false);

  const handleGenerate = async () => {
    if (!productName.trim()) {
      toast.error('Por favor, informe o nome do produto');
      return;
    }

    setIsGenerating(true);
    setGeneratedScript('');
    
    // Simular geração de script (aqui você pode integrar com uma API de IA real)
    setTimeout(() => {
      const scripts = {
        instagram: `🎬 ROTEIRO DE VÍDEO PARA INSTAGRAM - ${productName.toUpperCase()}
Duração: 30-60 segundos

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 CENA 1 - GANCHO (0-3s)
[CLOSE no rosto, olhar direto para câmera]
"Você está DESPERDIÇANDO seu dinheiro com produtos que não funcionam?"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 CENA 2 - PROBLEMA (3-10s)
[Mostra frustração, produtos antigos]
"Eu também já passei por isso... Gastei MUITO dinheiro e ZERO resultados."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ CENA 3 - SOLUÇÃO (10-25s)
[Mostra o produto com entusiasmo]
"Até que descobri ${productName}! E olha só o que aconteceu..."

[Mostra resultados, before/after]
"Em apenas [X] dias, os resultados começaram a aparecer!"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💪 CENA 4 - BENEFÍCIOS (25-45s)
[Mostra o produto em uso]
"${productName} é diferente porque:
✅ Fórmula exclusiva
✅ Resultados comprovados
✅ Milhares de clientes satisfeitos"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔥 CENA 5 - CALL TO ACTION (45-60s)
[Olha para câmera, energia alta]
"E o melhor? Tem DESCONTO ESPECIAL hoje!"

[Texto na tela: "LINK NA BIO"]
"Clica no link da bio AGORA e garante o seu!"

[Mostra satisfação/felicidade]
"Você merece os melhores resultados! 💪"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 DICAS DE GRAVAÇÃO:
• Use luz natural ou ring light
• Grave na vertical (9:16)
• Seja autêntico e energético
• Mostre o produto claramente
• Use música trending do Instagram

🎵 SUGESTÃO DE MÚSICA:
Sons trending de motivação/transformação

#${productName.replace(/\s+/g, '')} #Transformação #Resultados`,

        facebook: `🎬 ROTEIRO DE VÍDEO PARA FACEBOOK - ${productName.toUpperCase()}
Duração: 60-90 segundos

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 ABERTURA (0-5s)
[Texto na tela: "ATENÇÃO!"]
[Pessoa aparece animada]
"Você precisa ver isso antes que acabe!"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ PROBLEMA (5-20s)
[Tom mais sério, conectando com a dor]
"Quantas vezes você já tentou [problema] e não conseguiu?"

[Mostra situações do dia a dia]
"Eu sei como é frustrante gastar dinheiro e não ver resultado..."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 APRESENTAÇÃO (20-40s)
[Mostra o produto com destaque]
"Foi por isso que eu comecei a usar ${productName}!"

[Depoimento pessoal]
"E olha, eu estava MUITO cético no começo..."

[Mostra resultados]
"Mas em [X] semanas, tudo mudou!"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ BENEFÍCIOS (40-60s)
[Lista os benefícios com entusiasmo]
"${productName} funciona porque:

✅ Ingredientes naturais e comprovados
✅ Aprovado por especialistas
✅ Garantia de satisfação
✅ Milhares de clientes satisfeitos"

[Mostra prova social - fotos de clientes]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎁 OFERTA (60-75s)
[Cria urgência]
"E hoje tem uma OFERTA ESPECIAL!"

[Texto na tela: "DESCONTO EXCLUSIVO"]
"Mas é só por tempo limitado..."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👉 CALL TO ACTION (75-90s)
[Olha direto para câmera]
"Clica no botão SAIBA MAIS aqui embaixo"

[Aponta para baixo]
"Garante o seu ${productName} com desconto!"

[Sorri e acena]
"Você não vai se arrepender! 😊"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 DICAS PARA FACEBOOK:
• Grave em HD (mínimo 720p)
• Use legendas (muitos assistem sem som)
• Primeiros 3 segundos são CRUCIAIS
• Formato quadrado (1:1) ou vertical (4:5)
• Adicione CTA no primeiro comentário

#${productName.replace(/\s+/g, '')} #FacebookAds #Transformação`,

        tiktok: `🎬 ROTEIRO DE VÍDEO PARA TIKTOK - ${productName.toUpperCase()}
Duração: 15-30 segundos (máximo 60s)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ HOOK - PRIMEIRO SEGUNDO (0-1s)
[JUMP CUT agressivo, olhar direto]
"PARA DE ROLAR! 🛑"
ou
"Você está fazendo TUDO ERRADO! ❌"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 PROBLEMA RÁPIDO (1-5s)
[Transição rápida, energia alta]
"Se você ainda não conhece ${productName}..."

[Texto na tela: "VOCÊ ESTÁ PERDENDO"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💥 TRANSFORMAÇÃO (5-15s)
[Mostra o produto de forma criativa]
"Olha só o que acontece quando você usa!"

[Before/After rápido com transição]
[Texto: "ANTES ➡️ DEPOIS"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ PROVA SOCIAL (15-25s)
[Mostra depoimentos ou resultados]
"Mais de [X] pessoas já transformaram suas vidas!"

[Texto na tela: "RESULTADOS REAIS"]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔥 CTA FINAL (25-30s)
[Olha para câmera, aponta]
"Link na bio! CORRE! ⚡"

[Texto grande na tela: "LINK NA BIO"]
[Emoji de fogo e seta para baixo]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎬 FORMATO TIKTOK:
• Vertical 9:16 (OBRIGATÓRIO)
• Cortes rápidos a cada 2-3 segundos
• Texto grande e legível
• Transições dinâmicas
• Música trending (ESSENCIAL)

🎵 MÚSICA:
Use sons trending do momento
Busque: "trending sounds" no TikTok

⚡ EFEITOS:
• Zoom in/out rápido
• Green screen
• Transições de corte
• Text to speech (opcional)

📱 HASHTAGS:
#${productName.replace(/\s+/g, '')} #FYP #Viral #Transformação #Resultado #TikTokBrasil

💡 DICA PRO:
Poste entre 18h-22h para maior alcance!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 VARIAÇÕES DE HOOK:
1. "Isso mudou minha vida! 🤯"
2. "POV: Você descobriu ${productName}"
3. "Ninguém te conta isso... 🤫"
4. "Eu testei por [X] dias e..."
5. "ATENÇÃO: Isso é SÉRIO! ⚠️"`
      };

      setGeneratedScript(scripts[platform]);
      setIsGenerating(false);
      toast.success('Script gerado com sucesso!');
    }, 2000);
  };

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(generatedScript);
      setCopied(true);
      toast.success('Script copiado para a área de transferência!');
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      toast.error('Erro ao copiar script');
    }
  };

  const handleReset = () => {
    setProductName('');
    setGeneratedScript('');
    setCopied(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl w-full mx-4 bg-[#1a1a1a] border-[#2a2a2a] text-white p-0 overflow-hidden max-h-[90vh] overflow-y-auto">
        <div className="p-6 space-y-6">
          {/* Tag IA de Criativo no topo */}
          <div className="flex justify-center -mt-2">
            <div className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-gradient-to-r from-[#FF6B35] via-[#FF8C42] to-[#FFD23F] shadow-lg">
              <Zap className="h-4 w-4 text-white fill-white" />
              <span className="text-white font-semibold text-sm">IA de Criativo</span>
            </div>
          </div>

          {/* Título e Subtítulo */}
          <DialogHeader className="text-center space-y-2">
            <h2 className="text-3xl font-bold text-white">
              Gerador de Scripts de Vídeo
            </h2>
            <p className="text-gray-400 text-base">
              Crie roteiros completos para seus criativos
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

            {/* Seleção de Plataforma */}
            <div className="space-y-2">
              <Label className="text-white">Plataforma</Label>
              <div className="flex gap-3">
                <Button
                  type="button"
                  variant="ghost"
                  onClick={() => setPlatform('instagram')}
                  className={cn(
                    'flex-1 rounded-full h-10',
                    platform === 'instagram'
                      ? 'bg-primary text-white hover:bg-primary/90'
                      : 'bg-[#1a1a1a] text-white border border-[#3a3a3a] hover:bg-[#2a2a2a]'
                  )}
                >
                  Instagram
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  onClick={() => setPlatform('facebook')}
                  className={cn(
                    'flex-1 rounded-full h-10',
                    platform === 'facebook'
                      ? 'bg-primary text-white hover:bg-primary/90'
                      : 'bg-[#1a1a1a] text-white border border-[#3a3a3a] hover:bg-[#2a2a2a]'
                  )}
                >
                  Facebook
                </Button>
                <Button
                  type="button"
                  variant="ghost"
                  onClick={() => setPlatform('tiktok')}
                  className={cn(
                    'flex-1 rounded-full h-10',
                    platform === 'tiktok'
                      ? 'bg-primary text-white hover:bg-primary/90'
                      : 'bg-[#1a1a1a] text-white border border-[#3a3a3a] hover:bg-[#2a2a2a]'
                  )}
                >
                  TikTok
                </Button>
              </div>
            </div>

            {/* Botão Gerar Script */}
            <Button
              onClick={handleGenerate}
              disabled={isGenerating || !productName.trim()}
              className="w-full h-12 rounded-lg bg-gradient-to-r from-[#FF6B35] via-[#FF8C42] to-[#FFD23F] hover:from-[#FF6B35]/90 hover:via-[#FF8C42]/90 hover:to-[#FFD23F]/90 text-white font-semibold text-base shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <Zap className="h-5 w-5 mr-2 fill-white" />
              {isGenerating ? 'Gerando Script...' : 'Gerar Script Completo'}
            </Button>
          </div>

          {/* Resultado do Script Gerado */}
          {generatedScript && (
            <div className="bg-[#2a2a2a] rounded-lg p-6 space-y-4 animate-fade-in">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-white">
                  Script para {platform === 'instagram' ? 'Instagram' : platform === 'facebook' ? 'Facebook' : 'TikTok'}
                </h3>
                <Button
                  onClick={handleCopy}
                  variant="outline"
                  size="sm"
                  className="border-primary text-primary hover:bg-primary hover:text-white"
                >
                  {copied ? (
                    <>
                      <Check className="h-4 w-4 mr-2" />
                      Copiado!
                    </>
                  ) : (
                    <>
                      <Copy className="h-4 w-4 mr-2" />
                      Copiar Script
                    </>
                  )}
                </Button>
              </div>
              
              <Textarea
                value={generatedScript}
                readOnly
                className="min-h-[500px] bg-[#1a1a1a] border-[#3a3a3a] text-white font-mono text-sm resize-none"
              />

              <div className="flex gap-3">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="flex-1 border-[#3a3a3a] text-white hover:bg-[#3a3a3a]"
                >
                  Gerar Novo Script
                </Button>
                <Button
                  onClick={() => onOpenChange(false)}
                  className="flex-1 bg-gradient-to-r from-[#FF6B35] via-[#FF8C42] to-[#FFD23F] hover:from-[#FF6B35]/90 hover:via-[#FF8C42]/90 hover:to-[#FFD23F]/90"
                >
                  Fechar
                </Button>
              </div>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
