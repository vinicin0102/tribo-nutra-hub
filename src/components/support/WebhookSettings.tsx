import { useState, useEffect } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Globe, Copy, Check, ExternalLink, Zap, Info } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";

export function WebhookSettings() {
  const [projectId, setProjectId] = useState<string>("");
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    // Tentar extrair o project ID da URL do Supabase configurada
    const fetchProjectInfo = async () => {
      // @ts-ignore - acessando propriedade privada para facilitar a vida do admin
      const supabaseUrl = supabase.supabaseUrl;
      if (supabaseUrl) {
        const match = supabaseUrl.match(/(?:https:\/\/)?([^.]+)/);
        if (match && match[1]) {
          setProjectId(match[1]);
        }
      }
    };
    fetchProjectInfo();
  }, []);

  const webhookUrl = projectId 
    ? `https://${projectId}.supabase.co/functions/v1/payment-webhook`
    : "https://[SEU-ID-PROJETO].supabase.co/functions/v1/payment-webhook";

  const copyToClipboard = () => {
    navigator.clipboard.writeText(webhookUrl);
    setCopied(true);
    toast.success("URL do Webhook copiada!");
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <Card className="border-[#2a2a2a] bg-[#1a1a1a] text-white overflow-hidden">
        <div className="absolute top-0 left-0 w-1 h-full bg-primary"></div>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="p-2 bg-primary/10 rounded-lg">
              <Zap className="h-5 w-5 text-primary" />
            </div>
            <div>
              <CardTitle className="text-xl">Integração de Pagamento</CardTitle>
              <CardDescription className="text-gray-400">
                Conecte qualquer gateway de pagamento (Kiwify, Hotmart, Doppus, etc.)
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="p-4 rounded-lg bg-blue-500/5 border border-blue-500/20 flex gap-3 text-sm text-blue-200">
            <Info className="h-5 w-5 flex-shrink-0" />
            <p>
              Ao configurar este webhook no seu gateway, o sistema irá identificar automaticamente o usuário pelo 
              <strong> email</strong> e ativar o <strong>Plano Diamond</strong> imediatamente após a aprovação do pagamento.
            </p>
          </div>

          <div className="space-y-3">
            <Label htmlFor="webhook-url" className="text-gray-300">URL do Webhook (Postback)</Label>
            <div className="flex gap-2">
              <div className="relative flex-1">
                <Globe className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-500" />
                <Input
                  id="webhook-url"
                  value={webhookUrl}
                  readOnly
                  className="bg-[#0a0a0a] border-[#333] pl-10 text-gray-300 focus-visible:ring-primary h-11"
                />
              </div>
              <Button 
                onClick={copyToClipboard}
                variant="outline"
                className="border-[#333] hover:bg-primary hover:text-white transition-all h-11 px-4"
              >
                {copied ? <Check className="h-4 w-4" /> : <Copy className="h-4 w-4" />}
              </Button>
            </div>
            <p className="text-[10px] text-gray-500 italic">
              * Certifique-se de que a Edge Function 'payment-webhook' esteja publicada (deployed).
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
            <div className="p-4 rounded-xl border border-[#2a2a2a] bg-[#0a0a0a]/50 space-y-2">
              <h4 className="font-semibold flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-green-500"></span>
                Gateways Compatíveis
              </h4>
              <ul className="text-xs text-gray-400 grid grid-cols-2 gap-1">
                <li>• Kiwify</li>
                <li>• Hotmart</li>
                <li>• Doppus</li>
                <li>• Perfect Pay</li>
                <li>• Kirvano</li>
                <li>• Eduzz</li>
                <li>• Braip</li>
                <li>• Entre outros...</li>
              </ul>
            </div>
            <div className="p-4 rounded-xl border border-[#2a2a2a] bg-[#0a0a0a]/50 space-y-2">
              <h4 className="font-semibold flex items-center gap-2 text-primary">
                Ações Realizadas
              </h4>
              <ul className="text-xs text-gray-400 space-y-1">
                <li>• Identifica usuário por email</li>
                <li>• Ativa plano Diamond por 30 dias</li>
                <li>• Registra transação no histórico</li>
                <li>• Limpa cache de perfil</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card className="border-[#2a2a2a] bg-[#1a1a1a] text-white">
        <CardHeader>
          <CardTitle className="text-lg">Instruções de Configuração</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4 text-sm text-gray-400">
          <div className="flex gap-4">
            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-[#333] flex items-center justify-center text-white font-bold text-xs">1</div>
            <p>Copie a URL acima.</p>
          </div>
          <div className="flex gap-4">
            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-[#333] flex items-center justify-center text-white font-bold text-xs">2</div>
            <p>Vá ao painel do seu gateway de pagamento (ex: Kiwify) &rarr; Webhooks.</p>
          </div>
          <div className="flex gap-4">
            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-[#333] flex items-center justify-center text-white font-bold text-xs">3</div>
            <p>Adicione um novo Webhook e cole a URL. Selecione o evento "Venda Aprovada" ou "Pagamento Confirmado".</p>
          </div>
          <div className="flex gap-4">
            <div className="flex-shrink-0 w-6 h-6 rounded-full bg-[#333] flex items-center justify-center text-white font-bold text-xs">4</div>
            <p>O sistema processará as vendas automaticamente a partir de agora.</p>
          </div>
          
          <div className="pt-4">
            <Button 
              variant="link" 
              className="p-0 text-primary h-auto flex items-center gap-2"
              onClick={() => window.open(`https://supabase.com/dashboard/project/${projectId}/functions/payment-webhook/logs`, '_blank')}
            >
              Ver logs de integração <ExternalLink className="h-3 w-3" />
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
