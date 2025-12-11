import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';

export function useUnlockedModules() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: unlockedModules = [], isLoading } = useQuery({
    queryKey: ['unlocked-modules', user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      // Try to get from database first, fallback to localStorage
      try {
        const { data, error } = await supabase
          .from('unlocked_modules')
          .select('module_id')
          .eq('user_id', user.id);

        if (error && error.code !== 'PGRST116') { // PGRST116 = table doesn't exist
          throw error;
        }

        if (data) {
          return data.map((u: { module_id: string }) => u.module_id);
        }
      } catch (e) {
        // Table doesn't exist, use localStorage
        console.log('Using localStorage for unlocked modules');
      }

      // Fallback to localStorage
      try {
        const stored = localStorage.getItem(`unlocked_modules_${user.id}`);
        if (stored) {
          return JSON.parse(stored);
        }
      } catch (e) {
        console.error('Error reading unlocked modules from localStorage:', e);
      }

      return [];
    },
    enabled: !!user,
  });

  const unlockModule = useMutation({
    mutationFn: async (moduleId: string) => {
      if (!user) throw new Error('Usuário não autenticado');

      // Try to save to database first
      try {
        const { error } = await supabase
          .from('unlocked_modules')
          .insert({
            user_id: user.id,
            module_id: moduleId,
          });

        if (error && error.code !== 'PGRST116') {
          throw error;
        }
      } catch (e) {
        // Table doesn't exist, use localStorage
        try {
          const stored = localStorage.getItem(`unlocked_modules_${user.id}`);
          const current = stored ? JSON.parse(stored) : [];
          if (!current.includes(moduleId)) {
            const updated = [...current, moduleId];
            localStorage.setItem(`unlocked_modules_${user.id}`, JSON.stringify(updated));
          }
        } catch (localError) {
          console.error('Error saving to localStorage:', localError);
        }
      }
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

      // Try to delete from database first
      try {
        const { error } = await supabase
          .from('unlocked_modules')
          .delete()
          .eq('user_id', user.id)
          .eq('module_id', moduleId);

        if (error && error.code !== 'PGRST116') {
          throw error;
        }
      } catch (e) {
        // Table doesn't exist, use localStorage
        try {
          const stored = localStorage.getItem(`unlocked_modules_${user.id}`);
          const current = stored ? JSON.parse(stored) : [];
          const updated = current.filter((id: string) => id !== moduleId);
          localStorage.setItem(`unlocked_modules_${user.id}`, JSON.stringify(updated));
        } catch (localError) {
          console.error('Error saving to localStorage:', localError);
        }
      }
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

