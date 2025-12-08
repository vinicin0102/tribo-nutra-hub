import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';

export interface Subscription {
  subscription_plan: 'free' | 'diamond';
  subscription_expires_at: string | null;
}

export function useSubscription() {
  const { user } = useAuth();

  return useQuery({
    queryKey: ['subscription', user?.id],
    queryFn: async () => {
      if (!user) return null;

      const { data, error } = await supabase
        .from('profiles')
        .select('subscription_plan, subscription_expires_at')
        .eq('user_id', user.id)
        .maybeSingle();

      if (error) {
        console.error('Erro ao carregar assinatura:', error);
        throw error;
      }
      
      if (!data) {
        console.warn('Perfil não encontrado para verificar assinatura');
        return null;
      }
      
      return data as Subscription;
    },
    enabled: !!user,
    retry: 2,
    refetchOnWindowFocus: true,
    staleTime: 30000, // 30 segundos
  });
}

export function useHasDiamondAccess() {
  const { data: subscription } = useSubscription();

  if (!subscription) return false;
  
  if (subscription.subscription_plan === 'diamond') {
    // Se não tem data de expiração ou ainda não expirou
    if (!subscription.subscription_expires_at) return true;
    return new Date(subscription.subscription_expires_at) > new Date();
  }

  return false;
}

