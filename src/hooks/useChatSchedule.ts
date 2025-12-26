import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useEffect } from 'react';
import { updateOperatingHours, updateFreeOperatingHours } from '@/lib/schedule';

/**
 * Hook para carregar e sincronizar as configurações de horário do chat
 */
export function useChatSchedule() {
    const { data: settings, isLoading } = useQuery({
        queryKey: ['chat-schedule-settings'],
        queryFn: async () => {
            const { data, error } = await (supabase
                .from('support_settings') as any)
                .select('*')
                .in('key', ['chat_start_hour', 'chat_end_hour', 'free_start_hour', 'free_end_hour']);

            if (error) throw error;

            const settingsMap: Record<string, string> = {};
            (data as any[])?.forEach((setting: any) => {
                settingsMap[setting.key] = setting.value;
            });

            return {
                chatStartHour: parseInt(settingsMap['chat_start_hour'] || '9'),
                chatEndHour: parseInt(settingsMap['chat_end_hour'] || '21'),
                freeStartHour: parseInt(settingsMap['free_start_hour'] || '10'),
                freeEndHour: parseInt(settingsMap['free_end_hour'] || '15'),
            };
        },
        staleTime: 60000, // 1 minuto
        gcTime: 300000, // 5 minutos
    });

    // Atualizar o cache do schedule.ts quando as configurações carregarem
    useEffect(() => {
        if (settings) {
            updateOperatingHours(settings.chatStartHour, settings.chatEndHour);
            updateFreeOperatingHours(settings.freeStartHour, settings.freeEndHour);
        }
    }, [settings]);

    return {
        settings,
        isLoading,
        chatStartHour: settings?.chatStartHour ?? 9,
        chatEndHour: settings?.chatEndHour ?? 21,
        freeStartHour: settings?.freeStartHour ?? 10,
        freeEndHour: settings?.freeEndHour ?? 15,
    };
}
