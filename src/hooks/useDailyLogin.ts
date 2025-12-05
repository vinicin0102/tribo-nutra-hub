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

        // Buscar perfil atualizado e pontos diários
        const { data: profile } = await supabase
          .from('profiles')
          .select('consecutive_days, points')
          .eq('user_id', user.id)
          .single();

        // Buscar pontos ganhos hoje
        const { data: dailyPoints } = await supabase
          .from('daily_points')
          .select('points_earned')
          .eq('user_id', user.id)
          .eq('points_date', new Date().toISOString().split('T')[0])
          .single();

        if (profile) {
          // Mostrar notificação de pontos ganhos
          toast.success('🎉 +8 pontos por login diário!', {
            description: dailyPoints 
              ? `Você já ganhou ${dailyPoints.points_earned}/100 pontos hoje!`
              : 'Continue ganhando pontos todos os dias!'
          });

          // Mostrar notificação de dias consecutivos
          if (profile.consecutive_days === 7) {
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

