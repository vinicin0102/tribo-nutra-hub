import { useEffect } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/integrations/supabase/client';
import { toast } from 'sonner';

export function useDailyLogin() {
  const { user } = useAuth();

  useEffect(() => {
    if (!user) return;

    const checkDailyLogin = async () => {
      try {
        // Chamar função do Supabase para verificar login diário
        const { data, error } = await supabase.rpc('check_daily_login', {
          user_uuid: user.id
        });

        if (error) {
          console.error('Erro ao verificar login diário:', error);
          return;
        }

        // Se data for true, significa que ganhou pontos hoje
        if (data === true) {
          toast.success('🎉 +100 pontos de login diário!', {
            description: 'Continue voltando todos os dias para manter sua sequência!'
          });
        }
      } catch (error) {
        console.error('Erro ao verificar login diário:', error);
      }
    };

    // Verificar após 2 segundos do login (para não poluir a tela inicial)
    const timer = setTimeout(() => {
      checkDailyLogin();
    }, 2000);

    return () => clearTimeout(timer);
  }, [user]);
}

