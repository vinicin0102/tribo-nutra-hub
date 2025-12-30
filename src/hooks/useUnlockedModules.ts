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
  unlock_date?: string | null; // Data fixa de liberação
}

/**
 * Calcula quantos dias faltam para um módulo ser liberado
 * Agora usa unlock_date (data fixa definida pelo admin)
 * Retorna 0 se já está liberado, ou número de dias restantes
 */
export function getDaysUntilUnlock(
  module: ModuleForTimeCheck
): number {
  // Se módulo não está bloqueado, já está liberado
  if (!module.is_locked) {
    return 0;
  }

  // Se tem data fixa de liberação (unlock_date), usar ela
  if (module.unlock_date) {
    const unlockDate = new Date(module.unlock_date);
    const now = new Date();
    const diffTime = unlockDate.getTime() - now.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays > 0 ? diffDays : 0;
  }

  // Se não tem data de liberação definida, está bloqueado indefinidamente
  return -1;
}

/**
 * Verifica se um módulo está disponível considerando tempo
 */
export function isModuleAvailableByTime(
  module: ModuleForTimeCheck,
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

  // Verifica se já passou a data de liberação
  const daysRemaining = getDaysUntilUnlock(module);
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

  // Dados do perfil para verificação
  const hasDiamondPlan = profile?.subscription_plan === 'diamond';

  /**
   * Verifica se um módulo está completamente disponível
   * Considera: desbloqueio manual, desbloqueio por plano, e data de liberação
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

    // Verifica disponibilidade por data
    return isModuleAvailableByTime(module, hasDiamondPlan);
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
    return getDaysUntilUnlock(module);
  };

  /**
   * Retorna a data de liberação formatada
   */
  const getUnlockDateFormatted = (module: ModuleForTimeCheck): string | null => {
    if (!module.unlock_date) return null;
    const date = new Date(module.unlock_date);
    return date.toLocaleDateString('pt-BR');
  };

  return {
    unlockedModules,
    isLoading,
    isUnlocked,
    isModuleFullyAvailable,
    getDaysRemaining,
    getUnlockDateFormatted,
    hasDiamondPlan,
    unlockModule: unlockModule.mutate,
    lockModule: lockModule.mutate,
    refetch,
  };
}

