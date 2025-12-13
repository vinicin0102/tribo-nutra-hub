import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';

interface UnlockedModule {
  id: string;
  user_id: string;
  module_id: string;
  created_at: string;
}

export function useUnlockedModules() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: unlockedModules = [], isLoading, refetch } = useQuery({
    queryKey: ['unlocked-modules', user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      console.log('🔍 [useUnlockedModules] Buscando módulos desbloqueados para:', user.id);
      
      const { data, error } = await supabase
        .from('unlocked_modules' as any)
        .select('module_id')
        .eq('user_id', user.id);

      if (error) {
        console.error('❌ [useUnlockedModules] Erro ao buscar módulos desbloqueados:', error);
        return [];
      }

      const modules = (data as any[] || []).map((u: { module_id: string }) => u.module_id);
      console.log('✅ [useUnlockedModules] Módulos desbloqueados encontrados:', modules.length, modules);
      return modules;
    },
    enabled: !!user,
    staleTime: 0, // Sempre considerar stale para buscar dados atualizados
    cacheTime: 0, // Não manter cache por muito tempo
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

  const isUnlocked = (moduleId: string) => unlockedModules.includes(moduleId);

  return {
    unlockedModules,
    isLoading,
    isUnlocked,
    unlockModule: unlockModule.mutate,
    lockModule: lockModule.mutate,
    refetch,
  };
}
