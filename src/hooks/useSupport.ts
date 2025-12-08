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
  const { data: profile } = useProfile();
  const profileData = profile as { role?: string } | undefined;
  const isAdmin = user?.email === ADMIN_EMAIL || profileData?.role === 'admin';

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
      if (!isAdmin) {
        console.error('Acesso negado - não é admin:', { userEmail: user?.email, role: profileData?.role });
        throw new Error('Sem permissão. Apenas admins podem executar esta ação.');
      }

      console.log('Alterando plano:', { userId, plan, expiresAt, isAdmin, userEmail: user?.email });

      if (!userId || userId === '') {
        throw new Error('ID do usuário inválido');
      }

      if (plan !== 'free' && plan !== 'diamond') {
        throw new Error('Plano inválido. Use "free" ou "diamond".');
      }

      // Usar função RPC com SECURITY DEFINER para ignorar RLS
      // Se expiresAt for null, não passar o parâmetro (usa DEFAULT)
      const rpcParams: any = {
        p_user_id: userId,
        p_plan: plan
      };
      
      // Só adicionar expires_at se não for null
      if (expiresAt !== null && expiresAt !== undefined) {
        rpcParams.p_expires_at = expiresAt;
      }

      const { data: rpcData, error: rpcError } = await (supabase.rpc as any)(
        'change_user_plan_admin',
        rpcParams
      );

      console.log('=== RESPOSTA DA ALTERAÇÃO DE PLANO (RPC) ===');
      console.log('RPC Data retornada:', rpcData);
      console.log('RPC Erro retornado:', rpcError);

      if (rpcError) {
        console.error('❌ ERRO AO ALTERAR PLANO (RPC):', rpcError);
        throw new Error(rpcError.message || 'Erro ao alterar plano via RPC');
      }

      // Verificar se a função retornou sucesso
      if (rpcData && typeof rpcData === 'object') {
        if (rpcData.success === false) {
          console.error('❌ Função RPC retornou erro:', rpcData.error);
          throw new Error(rpcData.error || 'Erro ao alterar plano');
        }
        
        if (rpcData.success === true) {
          console.log('✅ Plano alterado com sucesso via RPC:', rpcData);
          return rpcData;
        }
      }

      // Se chegou aqui, a função RPC não retornou o formato esperado
      console.error('❌ Resposta inesperada da função RPC:', rpcData);
      throw new Error('Resposta inesperada da função de alteração de plano');
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

      console.log('=== INÍCIO ATUALIZAÇÃO DE PONTOS ===');
      console.log('Dados recebidos:', { userId, points, isAdmin, userEmail: user?.email, userRole: profileData?.role });

      // Primeiro, verificar se o usuário existe
      const { data: existingProfile, error: checkError } = await supabase
        .from('profiles')
        .select('user_id, points, username, email, role')
        .eq('user_id', userId)
        .maybeSingle();

      console.log('Perfil existente:', { existingProfile, checkError });

      if (checkError) {
        console.error('❌ Erro ao verificar perfil:', checkError);
        throw new Error(`Erro ao verificar perfil: ${checkError.message} (Código: ${checkError.code})`);
      }

      if (!existingProfile) {
        console.error('❌ Usuário não encontrado:', userId);
        throw new Error('Usuário não encontrado');
      }

      console.log('✅ Perfil encontrado:', existingProfile);
      console.log('Atualizando pontos de', existingProfile.points, 'para', points);

      // Usar função RPC com SECURITY DEFINER para ignorar RLS
      const { data: rpcData, error: rpcError } = await (supabase.rpc as any)(
        'update_user_points_admin',
        {
          p_user_id: userId,
          p_points: points
        }
      );

      console.log('=== RESPOSTA DA ATUALIZAÇÃO (RPC) ===');
      console.log('RPC Data retornada:', rpcData);
      console.log('RPC Erro retornado:', rpcError);

      if (rpcError) {
        console.error('❌ ERRO AO ATUALIZAR PONTOS (RPC):', rpcError);
        console.error('Detalhes completos do erro:', {
          code: rpcError.code,
          message: rpcError.message,
          details: rpcError.details,
          hint: rpcError.hint
        });
        throw new Error(rpcError.message || 'Erro ao atualizar pontos via RPC');
      }

      // Verificar se a função retornou sucesso
      if (rpcData && typeof rpcData === 'object') {
        if (rpcData.success === false) {
          console.error('❌ Função RPC retornou erro:', rpcData.error);
          throw new Error(rpcData.error || 'Erro ao atualizar pontos');
        }
        
        if (rpcData.success === true) {
          console.log('✅ Pontos atualizados com sucesso via RPC:', rpcData);
          // Buscar o perfil atualizado para retornar
          const { data: updatedProfile, error: fetchError } = await supabase
            .from('profiles')
            .select('user_id, username, points, email, role')
            .eq('user_id', userId)
            .single();
          
          if (fetchError) {
            console.error('Erro ao buscar perfil atualizado:', fetchError);
            // Mesmo assim retornar sucesso, pois os pontos foram atualizados
            return { user_id: userId, points: points };
          }
          
          return updatedProfile;
        }
      }

      // Fallback: tentar UPDATE direto se RPC não estiver disponível
      console.warn('⚠️ RPC não retornou resultado esperado, tentando UPDATE direto...');
      const { data, error } = await supabase
        .from('profiles')
        .update({ 
          points: points,
          updated_at: new Date().toISOString() 
        })
        .eq('user_id', userId)
        .select('user_id, username, points, email, role');

      console.log('=== RESPOSTA DA ATUALIZAÇÃO (FALLBACK) ===');
      console.log('Data retornada:', data);
      console.log('Erro retornado:', error);

      if (error) {
        console.error('❌ ERRO AO ATUALIZAR PONTOS (FALLBACK):', error);
        console.error('Detalhes completos do erro:', {
          code: error.code,
          message: error.message,
          details: error.details,
          hint: error.hint,
          status: (error as any).status
        });
        
        // Mensagem de erro mais específica
        let errorMessage = `Erro ao atualizar pontos: ${error.message}`;
        if (error.code === '42501' || error.message?.includes('permission') || error.message?.includes('policy')) {
          errorMessage = 'Erro de permissão. Verifique se a policy RLS foi criada. Execute o script criar-policy-admin-update-profiles.sql no Supabase.';
        }
        
        throw new Error(`${errorMessage} (Código: ${error.code})`);
      }

      if (!data || data.length === 0) {
        console.error('❌ Nenhum dado retornado após atualização');
        console.error('Isso geralmente indica problema de RLS policy');
        throw new Error('Nenhum dado retornado. Verifique se a policy RLS "Admins can update any profile" foi criada no Supabase.');
      }

      console.log('✅ Pontos atualizados com sucesso!');
      console.log('Dados atualizados:', data[0]);
      console.log('=== FIM ATUALIZAÇÃO DE PONTOS ===');
      
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
