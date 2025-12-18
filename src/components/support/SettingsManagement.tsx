import { useState, useEffect } from 'react';
import { Clock, MessageSquare, Save, Power, PowerOff } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';
import { useIsSupport } from '@/hooks/useSupport';

export function SettingsManagement() {
  const queryClient = useQueryClient();
  const isSupport = useIsSupport();
  
  // Estados locais
  const [chatStartHour, setChatStartHour] = useState('9');
  const [chatEndHour, setChatEndHour] = useState('21');
  const [autoReplyEnabled, setAutoReplyEnabled] = useState(true);
  const [autoReplyMessage, setAutoReplyMessage] = useState('');
  const [loading, setLoading] = useState(false);

  // Buscar configurações
  const { data: settings, isLoading } = useQuery({
    queryKey: ['support-settings'],
    queryFn: async () => {
      const { data, error } = await (supabase
        .from('support_settings') as any)
        .select('*')
        .order('key');

      if (error) throw error;

      const settingsMap: Record<string, string> = {};
      (data as any[])?.forEach((setting: any) => {
        settingsMap[setting.key] = setting.value;
      });

      return settingsMap;
    },
    enabled: !!isSupport,
  });

  // Atualizar configurações quando carregadas
  useEffect(() => {
    if (settings) {
      setChatStartHour(settings['chat_start_hour'] || '9');
      setChatEndHour(settings['chat_end_hour'] || '21');
      setAutoReplyEnabled(settings['auto_reply_enabled'] === 'true');
      setAutoReplyMessage(settings['auto_reply_message'] || 'Olá! Recebemos sua mensagem. Nossa equipe de suporte responderá em até 10 minutos. Obrigado pela paciência! 🙏');
    }
  }, [settings]);

  // Mutation para salvar configurações
  const saveSettings = useMutation({
    mutationFn: async (updates: Record<string, string>) => {
      const updatesArray = Object.entries(updates).map(([key, value]) => ({
        key,
        value: String(value),
      }));

      // Usar upsert para cada configuração
      const promises = updatesArray.map(({ key, value }) =>
        (supabase
          .from('support_settings') as any)
          .upsert({ key, value }, { onConflict: 'key' })
      );

      const results = await Promise.all(promises);
      
      const errors = results.filter(r => r.error);
      if (errors.length > 0) {
        throw errors[0].error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-settings'] });
      toast.success('Configurações salvas com sucesso!');
    },
    onError: (error: any) => {
      toast.error(`Erro ao salvar: ${error.message || 'Erro desconhecido'}`);
    },
  });

  const handleSave = async () => {
    setLoading(true);
    try {
      const updates: Record<string, string> = {
        chat_start_hour: chatStartHour,
        chat_end_hour: chatEndHour,
        auto_reply_enabled: String(autoReplyEnabled),
        auto_reply_message: autoReplyMessage,
      };

      await saveSettings.mutateAsync(updates);
    } catch (error) {
      console.error('Erro ao salvar configurações:', error);
    } finally {
      setLoading(false);
    }
  };

  if (isLoading) {
    return (
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardContent className="p-8">
          <p className="text-gray-400 text-center">Carregando configurações...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      {/* Configurações de Horário do Chat */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <div className="flex items-center gap-2">
            <Clock className="h-5 w-5 text-primary" />
            <CardTitle className="text-white">Horário de Funcionamento do Chat</CardTitle>
          </div>
          <CardDescription className="text-gray-400">
            Configure em que horário o chat da comunidade estará disponível (horário de Brasília)
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="startHour" className="text-white">
                Horário de Abertura
              </Label>
              <Input
                id="startHour"
                type="number"
                min="0"
                max="23"
                value={chatStartHour}
                onChange={(e) => setChatStartHour(e.target.value)}
                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                placeholder="9"
              />
              <p className="text-xs text-gray-400">Horas (0-23). Exemplo: 9 para 9h</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="endHour" className="text-white">
                Horário de Fechamento
              </Label>
              <Input
                id="endHour"
                type="number"
                min="0"
                max="23"
                value={chatEndHour}
                onChange={(e) => setChatEndHour(e.target.value)}
                className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                placeholder="21"
              />
              <p className="text-xs text-gray-400">Horas (0-23). Exemplo: 21 para 21h</p>
            </div>
          </div>
          <div className="p-3 bg-blue-500/10 border border-blue-500/20 rounded-lg">
            <p className="text-sm text-blue-400">
              <strong>Horário atual configurado:</strong> {chatStartHour}h às {chatEndHour}h (horário de Brasília)
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Configurações de Mensagem Automática */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <div className="flex items-center gap-2">
            <MessageSquare className="h-5 w-5 text-primary" />
            <CardTitle className="text-white">Mensagem Automática de Suporte</CardTitle>
          </div>
          <CardDescription className="text-gray-400">
            Configure a mensagem automática enviada quando um aluno entra em contato com o suporte
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-[#2a2a2a] rounded-lg">
            <div className="flex items-center gap-3">
              {autoReplyEnabled ? (
                <Power className="h-5 w-5 text-green-500" />
              ) : (
                <PowerOff className="h-5 w-5 text-gray-500" />
              )}
              <div>
                <Label htmlFor="autoReplyToggle" className="text-white cursor-pointer">
                  Mensagem Automática
                </Label>
                <p className="text-xs text-gray-400">
                  {autoReplyEnabled ? 'Ativada' : 'Desativada'}
                </p>
              </div>
            </div>
            <Switch
              id="autoReplyToggle"
              checked={autoReplyEnabled}
              onCheckedChange={setAutoReplyEnabled}
            />
          </div>

          {autoReplyEnabled && (
            <div className="space-y-2">
              <Label htmlFor="autoReplyMessage" className="text-white">
                Conteúdo da Mensagem
              </Label>
              <Textarea
                id="autoReplyMessage"
                value={autoReplyMessage}
                onChange={(e) => setAutoReplyMessage(e.target.value)}
                className="bg-[#2a2a2a] border-[#3a3a3a] text-white min-h-[120px]"
                placeholder="Digite a mensagem automática..."
              />
              <p className="text-xs text-gray-400">
                Esta mensagem será enviada automaticamente quando um aluno enviar a primeira mensagem no suporte
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Botão de Salvar */}
      <div className="flex justify-end">
        <Button
          onClick={handleSave}
          disabled={loading || saveSettings.isPending}
          className="bg-primary hover:bg-primary/90 text-white"
        >
          <Save className="h-4 w-4 mr-2" />
          {loading || saveSettings.isPending ? 'Salvando...' : 'Salvar Configurações'}
        </Button>
      </div>
    </div>
  );
}

