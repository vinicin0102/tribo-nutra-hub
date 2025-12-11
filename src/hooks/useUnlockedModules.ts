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

  const { data: unlockedModules = [], isLoading } = useQuery({
    queryKey: ['unlocked-modules', user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from('unlocked_modules' as any)
        .select('module_id')
        .eq('user_id', user.id);

      if (error) {
        console.error('Error fetching unlocked modules:', error);
        return [];
      }

      return (data as any[] || []).map((u: { module_id: string }) => u.module_id);
    },
    enabled: !!user,
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
  };
}
