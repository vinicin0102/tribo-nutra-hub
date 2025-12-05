import { useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

export function useDailyLogin() {
  const { user } = useAuth();

  useEffect(() => {
    if (!user) return;

    const recordDailyLogin = async () => {
      try {
        // Chamar função do Supabase para registrar login diário
        const { error } = await supabase.rpc('record_daily_login', {
          p_user_id: user.id
        });

        if (error) {
          console.error('Erro ao registrar login diário:', error);
          return;
        }

        // Buscar perfil atualizado para verificar dias consecutivos
        const { data: profile } = await supabase
          .from('profiles')
          .select('consecutive_days')
          .eq('user_id', user.id)
          .single();

        if (profile && profile.consecutive_days) {
          // Mostrar notificação apenas se for um novo dia
          if (profile.consecutive_days === 1) {
            toast.success('🎉 Login diário registrado!', {
              description: 'Continue voltando todos os dias para ganhar a medalha Ativo!'
            });
          } else if (profile.consecutive_days === 7) {
            toast.success('🏆 7 dias consecutivos!', {
              description: 'Você ganhou a medalha Ativo!'
            });
          }
        }
      } catch (error) {
        console.error('Erro ao registrar login diário:', error);
      }
    };

    // Registrar após 2 segundos do login (para não poluir a tela inicial)
    const timer = setTimeout(() => {
      recordDailyLogin();
    }, 2000);

    return () => clearTimeout(timer);
  }, [user]);
}

