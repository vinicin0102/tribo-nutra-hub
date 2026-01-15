import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';

interface AppPopup {
    id: string;
    title: string;
    message: string | null;
    image_url: string | null;
    button_text: string | null;
    button_link: string | null;
    is_active: boolean;
    show_once_per_user: boolean;
}

// Helper para acessar tabelas de popup (não existem no schema ainda)
const getAppPopupsTable = () => {
    return (supabase as any).from('app_popups');
};

const getPopupViewsTable = () => {
    return (supabase as any).from('popup_views');
};

export function useAppPopup() {
    const { user } = useAuth();
    const queryClient = useQueryClient();

    // Buscar popup ativo
    const { data: popup, isLoading } = useQuery({
        queryKey: ['active-popup', user?.id],
        queryFn: async (): Promise<AppPopup | null> => {
            try {
                // Buscar popup ativo
                const { data: popups, error } = await getAppPopupsTable()
                    .select('*')
                    .eq('is_active', true)
                    .limit(1);

                if (error) {
                    // Tabela não existe ou outro erro - retornar null silenciosamente
                    if (error.code === 'PGRST205' || error.message?.includes('not exist')) {
                        console.warn('Sistema de popups não configurado ainda');
                        return null;
                    }
                    console.error('Erro ao buscar popup:', error);
                    return null;
                }

                if (!popups || popups.length === 0) {
                    return null;
                }

                const activePopup = popups[0] as AppPopup;

                // Se o popup deve ser mostrado apenas 1x, verificar se usuário já viu
                if (activePopup.show_once_per_user && user?.id) {
                    const { data: views } = await getPopupViewsTable()
                        .select('id')
                        .eq('popup_id', activePopup.id)
                        .eq('user_id', user.id)
                        .limit(1);

                    if (views && views.length > 0) {
                        return null; // Usuário já viu este popup
                    }
                }

                return activePopup;
            } catch (error) {
                // Tabela não existe, retornar null silenciosamente
                console.warn('Sistema de popups não configurado');
                return null;
            }
        },
        enabled: true,
        staleTime: 30000, // 30 segundos
        refetchInterval: 60000, // Verificar a cada minuto se há popup novo
    });

    // Marcar popup como visualizado
    const markAsViewedMutation = useMutation({
        mutationFn: async (popupId: string) => {
            if (!user?.id) return;

            try {
                const { error } = await getPopupViewsTable()
                    .insert({
                        popup_id: popupId,
                        user_id: user.id,
                    });

                // Ignorar erro de duplicata (usuário já viu)
                if (error && !error.message.includes('duplicate')) {
                    console.error('Erro ao marcar popup como visto:', error);
                }
            } catch (error) {
                console.warn('Não foi possível marcar popup como visto:', error);
            }
        },
        onSuccess: () => {
            // Invalidar cache para esconder o popup
            queryClient.invalidateQueries({ queryKey: ['active-popup'] });
        },
    });

    const markAsViewed = (popupId: string) => {
        markAsViewedMutation.mutate(popupId);
    };

    return {
        popup,
        isLoading,
        markAsViewed,
    };
}