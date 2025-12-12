import { useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { Reward } from './useRewards';
import { toast } from 'sonner';

export function useCreateReward() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: Omit<Reward, 'id' | 'created_at'>) => {
      const rewardData = {
        name: data.name,
        description: data.description || null,
        image_url: data.image_url || null,
        points_required: data.points_required,
        is_active: data.is_active !== false,
      };

      const { data: reward, error } = await supabase
        .from('rewards')
        .insert(rewardData)
        .select()
        .single();

      if (error) throw error;
      return reward;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rewards'] });
      toast.success('Prêmio criado com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao criar prêmio: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

export function useUpdateReward() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, ...data }: Partial<Reward> & { id: string }) => {
      const updateData: Record<string, unknown> = {};
      
      if (data.name !== undefined) updateData.name = data.name;
      if (data.description !== undefined) updateData.description = data.description;
      if (data.image_url !== undefined) updateData.image_url = data.image_url;
      if (data.points_required !== undefined) updateData.points_required = data.points_required;
      if (data.is_active !== undefined) updateData.is_active = data.is_active;

      const { data: reward, error } = await supabase
        .from('rewards')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return reward;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rewards'] });
      queryClient.invalidateQueries({ queryKey: ['redemptions'] });
      toast.success('Prêmio atualizado com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao atualizar prêmio: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

export function useDeleteReward() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      // Primeiro, verificar se há resgates pendentes
      const { data: redemptions } = await supabase
        .from('redemptions')
        .select('id')
        .eq('reward_id', id)
        .in('status', ['pending', 'approved']);

      if (redemptions && redemptions.length > 0) {
        throw new Error('Não é possível excluir um prêmio com resgates pendentes ou aprovados. Cancele ou entregue os resgates primeiro.');
      }

      // Deletar resgates cancelados ou entregues relacionados
      await supabase
        .from('redemptions')
        .delete()
        .eq('reward_id', id)
        .in('status', ['cancelled', 'delivered']);

      // Deletar o prêmio
      const { error } = await supabase
        .from('rewards')
        .delete()
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['rewards'] });
      queryClient.invalidateQueries({ queryKey: ['redemptions'] });
      toast.success('Prêmio excluído com sucesso!');
    },
    onError: (error: any) => {
      toast.error('Erro ao excluir prêmio: ' + (error.message || 'Erro desconhecido'));
    },
  });
}

