import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useEffect } from 'react';
import { updateOperatingHours, updateFreeOperatingHours } from '@/lib/schedule';

/**
 * Hook para carregar e sincronizar as configurações de horário do chat
 */
export function useChatSchedule() {
    const { data: settings, isLoading, refetch } = useQuery({
        queryKey: ['chat-schedule-settings'],
        queryFn: async () => {
            console.log('🕐 Carregando configurações de horário do chat...');
            const { data, error } = await (supabase
                .from('support_settings') as any)
                .select('*')
                .in('key', ['chat_start_hour', 'chat_end_hour', 'free_start_hour', 'free_end_hour']);

            if (error) {
                console.error('❌ Erro ao carregar configurações de horário:', error);
                throw error;
            }

            const settingsMap: Record<string, string> = {};
            (data as any[])?.forEach((setting: any) => {
                settingsMap[setting.key] = setting.value;
            });

            const result = {
                chatStartHour: parseInt(settingsMap['chat_start_hour'] || '9'),
                chatEndHour: parseInt(settingsMap['chat_end_hour'] || '21'),
                freeStartHour: parseInt(settingsMap['free_start_hour'] || '10'),
                freeEndHour: parseInt(settingsMap['free_end_hour'] || '15'),
            };

            console.log('✅ Configurações de horário carregadas:', result);
            return result;
        },
        staleTime: 30000, // 30 segundos - mais frequente
        gcTime: 300000, // 5 minutos
        refetchInterval: 60000, // Refetch a cada 1 minuto
        refetchOnWindowFocus: true, // Refetch ao focar na janela
    });

    // Atualizar o cache do schedule.ts quando as configurações carregarem
    useEffect(() => {
        if (settings) {
            console.log('🔄 Atualizando cache de horário:', settings);
            updateOperatingHours(settings.chatStartHour, settings.chatEndHour);
            updateFreeOperatingHours(settings.freeStartHour, settings.freeEndHour);
        }
    }, [settings]);

    return {
        settings,
        isLoading,
        refetch,
        chatStartHour: settings?.chatStartHour ?? 9,
        chatEndHour: settings?.chatEndHour ?? 21,
        freeStartHour: settings?.freeStartHour ?? 10,
        freeEndHour: settings?.freeEndHour ?? 15,
    };
}
