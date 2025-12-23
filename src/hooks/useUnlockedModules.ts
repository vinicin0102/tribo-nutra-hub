import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';
import { toast } from 'sonner';

interface UnlockedModule {
  id: string;
  user_id: string;
  module_id: string;
  created_at: string;
}

// Interface simplificada do módulo para verificação de tempo
interface ModuleForTimeCheck {
  id: string;
  is_locked: boolean;
  unlock_after_days?: number;
}

/**
 * Calcula quantos dias faltam para um módulo ser liberado
 * Retorna 0 se já está liberado, ou número de dias restantes
 */
export function getDaysUntilUnlock(
  module: ModuleForTimeCheck,
  subscriptionStartDate: string | null | undefined
): number {
  // Se módulo não está bloqueado ou não tem dias configurados, já está liberado
  if (!module.is_locked || !module.unlock_after_days || module.unlock_after_days === 0) {
    return 0;
  }

  // Se não tem data de início de assinatura, está bloqueado indefinidamente
  if (!subscriptionStartDate) {
    return -1; // -1 indica bloqueado permanentemente
  }

  const startDate = new Date(subscriptionStartDate);
  const unlockDate = new Date(startDate);
  unlockDate.setDate(unlockDate.getDate() + module.unlock_after_days);

  const now = new Date();
  const diffTime = unlockDate.getTime() - now.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  return diffDays > 0 ? diffDays : 0;
}

/**
 * Verifica se um módulo está disponível considerando tempo
 */
export function isModuleAvailableByTime(
  module: ModuleForTimeCheck,
  subscriptionStartDate: string | null | undefined,
  hasDiamondPlan: boolean
): boolean {
  // Se módulo não está bloqueado, sempre disponível
  if (!module.is_locked) {
    return true;
  }

  // Se não tem plano Diamond, não está disponível
  if (!hasDiamondPlan) {
    return false;
  }

  // Verifica se já passou tempo suficiente
  const daysRemaining = getDaysUntilUnlock(module, subscriptionStartDate);
  return daysRemaining === 0;
}

export function useUnlockedModules() {
  const { user } = useAuth();
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();

  const { data: unlockedModules = [], isLoading, refetch } = useQuery<string[]>({
    queryKey: ['unlocked-modules', user?.id],
    queryFn: async (): Promise<string[]> => {
      if (!user) return [];

      console.log('🔍 [useUnlockedModules] Buscando módulos desbloqueados para:', user.id);

      const { data, error } = await supabase
        .from('unlocked_modules')
        .select('module_id')
        .eq('user_id', user.id);

      if (error) {
        console.error('❌ [useUnlockedModules] Erro ao buscar módulos desbloqueados:', error);
        return [];
      }

      const modules = ((data as unknown) as Array<{ module_id: string }> || []).map((u) => u.module_id);
      console.log('✅ [useUnlockedModules] Módulos desbloqueados encontrados:', modules.length, modules);
      return modules;
    },
    enabled: !!user,
    staleTime: 0,
    gcTime: 0,
  });

  const unlockModule = useMutation({
    mutationFn: async (moduleId: string) => {
      if (!user) throw new Error('Usuário não autenticado');

      const { error } = await supabase
        .from('unlocked_modules' as any)
        .insert({
          user_id: user.id,
          module_id: moduleId,
        } as any);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['unlocked-modules'] });
      toast.success('Módulo desbloqueado!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao desbloquear módulo: ' + error.message);
    },
  });

  const lockModule = useMutation({
    mutationFn: async (moduleId: string) => {
      if (!user) throw new Error('Usuário não autenticado');

      const { error } = await supabase
        .from('unlocked_modules' as any)
        .delete()
        .eq('user_id', user.id)
        .eq('module_id', moduleId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['unlocked-modules'] });
      toast.success('Módulo bloqueado!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao bloquear módulo: ' + error.message);
    },
  });

  const isUnlocked = (moduleId: string): boolean => (unlockedModules as string[]).includes(moduleId);

  // Dados do perfil para verificação de tempo
  const hasDiamondPlan = profile?.subscription_plan === 'diamond';
  // Usamos updated_at do profile como data de ativação do plano Diamond
  // Isso funciona porque updated_at é atualizado quando o plano muda
  const subscriptionStartDate = profile?.updated_at || profile?.created_at;

  /**
   * Verifica se um módulo está completamente disponível
   * Considera: desbloqueio manual, desbloqueio por plano, e desbloqueio por tempo
   */
  const isModuleFullyAvailable = (module: ModuleForTimeCheck): boolean => {
    // Se já está na lista de desbloqueados manualmente
    if (isUnlocked(module.id)) {
      return true;
    }

    // Se não está bloqueado
    if (!module.is_locked) {
      return true;
    }

    // Verifica disponibilidade por tempo
    return isModuleAvailableByTime(module, subscriptionStartDate, hasDiamondPlan);
  };

  /**
   * Retorna dias restantes para um módulo específico
   */
  const getDaysRemaining = (module: ModuleForTimeCheck): number => {
    if (!module.is_locked || isUnlocked(module.id)) {
      return 0;
    }
    if (!hasDiamondPlan) {
      return -1; // Bloqueado permanentemente (sem plano)
    }
    return getDaysUntilUnlock(module, subscriptionStartDate);
  };

  return {
    unlockedModules,
    isLoading,
    isUnlocked,
    isModuleFullyAvailable,
    getDaysRemaining,
    hasDiamondPlan,
    unlockModule: unlockModule.mutate,
    lockModule: lockModule.mutate,
    refetch,
  };
}

