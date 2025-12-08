import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';

const ADMIN_EMAIL = 'admin@gmail.com';

export function useIsSupport() {
  const { data: profile } = useProfile();
  const { user } = useAuth();
  
  // Se for admin@gmail.com, sempre retorna true
  if (user?.email === ADMIN_EMAIL) {
    return true;
  }
  
  // Se o perfil não carregou ainda, retorna false temporariamente
  if (!profile) {
    return false;
  }
  
  const profileData = profile as { role?: string } | undefined;
  return profileData?.role === 'support' || profileData?.role === 'admin';
}

export function useSupportUsers() {
  const { data: profile } = useProfile();
  const { user } = useAuth();
  const profileData = profile as { role?: string } | undefined;
  const isSupport = profileData?.role === 'support' || profileData?.role === 'admin';
  const isAdmin = user?.email === ADMIN_EMAIL;
  const canAccess = isSupport || isAdmin;

  return useQuery({
    queryKey: ['support-users', user?.email],
    queryFn: async () => {
      if (!canAccess && user?.email !== ADMIN_EMAIL) {
        console.log('Acesso negado - não é suporte nem admin');
        return [];
      }

      console.log('Buscando usuários...', { isSupport, isAdmin, canAccess, userEmail: user?.email });

      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Erro ao buscar usuários:', error);
        throw error;
      }
      
      console.log('Usuários encontrados:', data?.length || 0);
      return data || [];
    },
    enabled: !!user && (canAccess || user?.email === ADMIN_EMAIL),
    retry: 1,
  });
}

export function useBanUser() {
  return useBanUserTemporary();
}

export function useUnbanUser() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async (userId: string) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      const { error } = await (supabase.from('profiles') as any)
        .update({ is_banned: false })
        .eq('user_id', userId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useDeletePost() {
  const queryClient = useQueryClient();
  const { data: profile } = useProfile();
  const profileData = profile as { role?: string } | undefined;
  const isSupport = profileData?.role === 'support' || profileData?.role === 'admin';

  return useMutation({
    mutationFn: async (postId: string) => {
      if (!isSupport) throw new Error('Sem permissão');

      const { error } = await supabase
        .from('posts')
        .delete()
        .eq('id', postId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] });
    },
  });
}

export function useDeleteComment() {
  const queryClient = useQueryClient();
  const { data: profile } = useProfile();
  const profileData = profile as { role?: string } | undefined;
  const isSupport = profileData?.role === 'support' || profileData?.role === 'admin';

  return useMutation({
    mutationFn: async (commentId: string) => {
      if (!isSupport) throw new Error('Sem permissão');

      const { error } = await supabase
        .from('comments')
        .delete()
        .eq('id', commentId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['comments'] });
      queryClient.invalidateQueries({ queryKey: ['posts'] });
    },
  });
}

export function useDeleteChatMessage() {
  const queryClient = useQueryClient();
  const { data: profile } = useProfile();
  const profileData = profile as { role?: string } | undefined;
  const isSupport = profileData?.role === 'support' || profileData?.role === 'admin';

  return useMutation({
    mutationFn: async (messageId: string) => {
      if (!isSupport) throw new Error('Sem permissão');

      const { error } = await supabase
        .from('chat_messages')
        .delete()
        .eq('id', messageId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chat-messages'] });
    },
  });
}

export function useBanUserTemporary() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async ({ userId, days = 3 }: { userId: string; days?: number }) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      console.log('Banindo usuário:', { userId, days, isAdmin, userEmail: user?.email });

      if (!userId || userId === '') {
        throw new Error('ID do usuário inválido');
      }

      const { data, error } = await (supabase.rpc as any)('ban_user_temporary', {
        p_user_id: userId,
        p_days: days,
      });

      console.log('Resposta do RPC ban_user_temporary:', { data, error });

      if (error) {
        console.error('Erro ao banir usuário:', error);
        throw new Error(error.message || 'Erro ao banir usuário.');
      }

      console.log('Usuário banido com sucesso:', data);
      
      if (data && Array.isArray(data) && data.length > 0) {
        const result = data[0] as { success?: boolean; error?: string };
        if (result.success === false) {
          throw new Error(result.error || 'Erro ao banir usuário');
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useMuteUser() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async ({ userId, days }: { userId: string; days?: number }) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      console.log('Mutando usuário:', { userId, days, isAdmin, userEmail: user?.email });

      if (!userId || userId === '') {
        throw new Error('ID do usuário inválido');
      }

      const { data, error } = await (supabase.rpc as any)('mute_user', {
        p_user_id: userId,
        p_hours: days ? days * 24 : null,
      });

      console.log('Resposta do RPC mute_user:', { data, error });

      if (error) {
        console.error('Erro ao mutar usuário:', error);
        throw new Error(error.message || 'Erro ao mutar usuário.');
      }

      console.log('Usuário mutado com sucesso:', data);
      
      if (data && Array.isArray(data) && data.length > 0) {
        const result = data[0] as { success?: boolean; error?: string };
        if (result.success === false) {
          throw new Error(result.error || 'Erro ao mutar usuário');
        }
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useUnmuteUser() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async (userId: string) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      const { error } = await (supabase.from('profiles') as any)
        .update({ is_muted: false, mute_until: null })
        .eq('user_id', userId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useDeleteUser() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async (userId: string) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      // Delete user profile (cascade will handle related records)
      const { error } = await supabase
        .from('profiles')
        .delete()
        .eq('user_id', userId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useChangeUserPlan() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const isAdmin = user?.email === ADMIN_EMAIL;

  return useMutation({
    mutationFn: async ({ 
      userId, 
      plan, 
      expiresAt 
    }: { 
      userId: string; 
      plan: 'free' | 'diamond'; 
      expiresAt?: string | null;
    }) => {
      if (!isAdmin) throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');

      const { error } = await (supabase.from('profiles') as any)
        .update({
          subscription_plan: plan,
          subscription_expires_at: expiresAt || null,
        })
        .eq('user_id', userId);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
    },
  });
}

export function useUpdateUserPoints() {
  const queryClient = useQueryClient();
  const { user } = useAuth();
  const { data: profile } = useProfile();
  const profileData = profile as { role?: string } | undefined;
  const isAdmin = user?.email === ADMIN_EMAIL || profileData?.role === 'admin';

  return useMutation({
    mutationFn: async ({ 
      userId, 
      points, 
    }: { 
      userId: string; 
      points: number; 
      reason?: string;
    }) => {
      if (!isAdmin) {
        console.error('Acesso negado - não é admin:', { userEmail: user?.email, role: profileData?.role });
        throw new Error('Sem permissão. Apenas admin@gmail.com pode executar esta ação.');
      }

      console.log('Atualizando pontos:', { userId, points, isAdmin, userEmail: user?.email });

      if (!userId || userId === '') {
        throw new Error('ID do usuário inválido');
      }

      if (isNaN(points) || points < 0) {
        throw new Error('Pontos inválidos');
      }

      // Primeiro, verificar se o usuário existe
      const { data: existingProfile, error: checkError } = await supabase
        .from('profiles')
        .select('user_id, points, username')
        .eq('user_id', userId)
        .single();

      console.log('Perfil existente:', { existingProfile, checkError });

      if (checkError) {
        console.error('Erro ao verificar perfil:', checkError);
        throw new Error(`Erro ao verificar perfil: ${checkError.message}`);
      }

      if (!existingProfile) {
        throw new Error('Usuário não encontrado');
      }

      // Agora atualizar
      const { data, error } = await supabase
        .from('profiles')
        .update({ points, updated_at: new Date().toISOString() })
        .eq('user_id', userId)
        .select();

      console.log('Resposta da atualização de pontos:', { data, error, userId, points });

      if (error) {
        console.error('Erro ao atualizar pontos:', error);
        console.error('Detalhes do erro:', {
          code: error.code,
          message: error.message,
          details: error.details,
          hint: error.hint
        });
        throw new Error(`Erro ao atualizar pontos: ${error.message} (Código: ${error.code})`);
      }

      if (!data || data.length === 0) {
        console.error('Nenhum dado retornado após atualização');
        throw new Error('Usuário não encontrado ou não foi possível atualizar. Verifique as permissões RLS.');
      }

      console.log('Pontos atualizados com sucesso:', data[0]);
      return data[0];
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['support-users'] });
      queryClient.invalidateQueries({ queryKey: ['profiles'] });
      queryClient.invalidateQueries({ queryKey: ['profile'] });
    },
    onError: (error: any) => {
      console.error('Erro na mutation de atualização de pontos:', error);
    },
  });
}
