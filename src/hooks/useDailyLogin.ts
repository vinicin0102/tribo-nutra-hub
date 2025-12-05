import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

export function useDailyLogin() {
  const { user } = useAuth();
  const [hasCheckedToday, setHasCheckedToday] = useState(false);

  useEffect(() => {
    if (!user) return;
    
    // Verificar se já checou hoje (usando localStorage)
    const today = new Date().toISOString().split('T')[0];
    const lastCheckKey = `daily_login_${user.id}_${today}`;
    const alreadyChecked = localStorage.getItem(lastCheckKey);

    if (alreadyChecked || hasCheckedToday) {
      return; // Já checou hoje, não fazer nada
    }

    const recordDailyLogin = async () => {
      try {
        // Chamar função do Supabase para registrar login diário
        const { data, error } = await supabase.rpc('record_daily_login', {
          p_user_id: user.id
        });

        if (error) {
          console.error('Erro ao registrar login diário:', error);
          return;
        }

        // Marcar como checado hoje
        localStorage.setItem(lastCheckKey, 'true');
        setHasCheckedToday(true);

        // Verificar resultado da função
        if (data) {
          const result = data as any;
          
          if (result.success && result.points_result?.success) {
            // Mostrar notificação apenas se ganhou pontos
            toast.success('🎉 +8 pontos por login diário!', {
              description: `Você ganhou ${result.points_result.points_added || 8} pontos! Continue voltando todos os dias!`
            });
          } else if (result.already_logged) {
            // Já ganhou pontos hoje, não mostrar notificação
            console.log('Login já registrado hoje');
          }

          // Mostrar notificação de dias consecutivos
          if (result.consecutive_days === 7) {
            toast.success('🏆 7 dias consecutivos!', {
              description: 'Você ganhou a medalha Ativo!'
            });
          }
        }

        // Buscar pontos ganhos hoje para exibir
        const { data: dailyPoints } = await supabase
          .from('daily_points')
          .select('points_earned')
          .eq('user_id', user.id)
          .eq('points_date', today)
          .single();

        if (dailyPoints) {
          console.log(`Pontos ganhos hoje: ${dailyPoints.points_earned}/100`);
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
  }, [user, hasCheckedToday]);
}

