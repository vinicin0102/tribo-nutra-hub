import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { updateOperatingHours } from '@/lib/schedule';

export interface SupportSettings {
  chatStartHour: number;
  chatEndHour: number;
  autoReplyEnabled: boolean;
  autoReplyMessage: string;
}

export function useSupportSettings() {
  return useQuery({
    queryKey: ['support-settings'],
    queryFn: async (): Promise<SupportSettings> => {
      const { data, error } = await (supabase
        .from('support_settings') as any)
        .select('key, value')
        .in('key', ['chat_start_hour', 'chat_end_hour', 'auto_reply_enabled', 'auto_reply_message']);

      if (error) throw error;

      const settingsMap: Record<string, string> = {};
      (data as any[])?.forEach((setting: any) => {
        settingsMap[setting.key] = setting.value;
      });

      const chatStartHour = parseInt(settingsMap['chat_start_hour'] || '9', 10);
      const chatEndHour = parseInt(settingsMap['chat_end_hour'] || '21', 10);
      const autoReplyEnabled = settingsMap['auto_reply_enabled'] === 'true';
      const autoReplyMessage = settingsMap['auto_reply_message'] || 'Olá! Recebemos sua mensagem. Nossa equipe de suporte responderá em até 10 minutos. Obrigado pela paciência! 🙏';

      // Atualizar cache do schedule.ts
      updateOperatingHours(chatStartHour, chatEndHour);

      return {
        chatStartHour,
        chatEndHour,
        autoReplyEnabled,
        autoReplyMessage,
      };
    },
    staleTime: 30000, // 30 segundos
    refetchInterval: 60000, // Atualizar a cada minuto
  });
}

