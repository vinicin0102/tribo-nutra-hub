import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { Badge } from './useRanking';
import { toast } from 'sonner';

export function useCreateBadge() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: Omit<Badge, 'id'>) => {
      const { data: badge, error } = await supabase
        .from('badges')
        .insert(data)
        .select()
        .single();

      if (error) throw error;
      return badge;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['badges'] });
      toast.success('Conquista criada com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao criar conquista: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

export function useUpdateBadge() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Badge> & { id: string }) => {
      const { data: badge, error } = await supabase
        .from('badges')
        .update(data)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return badge;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['badges'] });
      queryClient.invalidateQueries({ queryKey: ['user_badges'] });
      toast.success('Conquista atualizada com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao atualizar conquista: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

export function useDeleteBadge() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      // Primeiro, deletar todas as referências em user_badges
      const { error: userBadgesError } = await supabase
        .from('user_badges')
        .delete()
        .eq('badge_id', id);

      if (userBadgesError) throw userBadgesError;

      // Depois, deletar o badge
      const { error } = await supabase
        .from('badges')
        .delete()
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['badges'] });
      queryClient.invalidateQueries({ queryKey: ['user_badges'] });
      toast.success('Conquista excluída com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao excluir conquista: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

