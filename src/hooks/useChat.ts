import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useEffect } from 'react';
import { toast } from 'sonner';

export interface ChatMessage {
  id: string;
  user_id: string;
  content: string;
  created_at: string;
  profiles?: {
    username: string;
    avatar_url: string | null;
  } | null;
}

export function useChatMessages() {
  const queryClient = useQueryClient();

  useEffect(() => {
    console.log('🔔 Configurando subscription realtime para chat_messages...');
    
    const channel = supabase
      .channel('chat-messages')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'chat_messages' },
        (payload) => {
          console.log('🔔 Evento realtime recebido:', payload);
          queryClient.invalidateQueries({ queryKey: ['chat_messages'] });
          queryClient.refetchQueries({ queryKey: ['chat_messages'] });
        }
      )
      .subscribe((status) => {
        console.log('📡 Status da subscription:', status);
        if (status === 'SUBSCRIBED') {
          console.log('✅ Subscription ativa!');
        } else if (status === 'CHANNEL_ERROR') {
          console.error('❌ Erro na subscription!');
        }
      });

    return () => {
      console.log('🔌 Removendo subscription...');
      supabase.removeChannel(channel);
    };
  }, [queryClient]);

  return useQuery({
    queryKey: ['chat_messages'],
    queryFn: async () => {
      console.log('📥 Buscando mensagens do chat...');
      
      const { data: messages, error: messagesError } = await supabase
        .from('chat_messages')
        .select('*')
        .order('created_at', { ascending: true })
        .limit(100);
      
      if (messagesError) {
        console.error('❌ Erro ao buscar mensagens:', messagesError);
        throw messagesError;
      }
      
      console.log(`✅ ${messages?.length || 0} mensagens encontradas`);
      console.log('📋 Primeiras 3 mensagens:', messages?.slice(0, 3));
      
      if (!messages || messages.length === 0) {
        console.warn('⚠️ Nenhuma mensagem encontrada no banco!');
        return [];
      }
      
      // Get unique user IDs
      const userIds = [...new Set(messages.map(m => m.user_id))];
      console.log(`👥 Buscando perfis para ${userIds.length} usuários:`, userIds);
      
      // Fetch profiles separately
      const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('user_id, username, avatar_url')
        .in('user_id', userIds);
      
      if (profilesError) {
        console.error('❌ Erro ao buscar perfis:', profilesError);
        // Continuar mesmo sem perfis
      }
      
      console.log(`👥 ${profiles?.length || 0} perfis encontrados`);
      
      // Create a map for quick lookup
      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);
      
      // Combine messages with profiles
      const result = messages.map(message => ({
        ...message,
        profiles: profileMap.get(message.user_id) || null
      })) as ChatMessage[];
      
      console.log('✅ Mensagens processadas:', result.length);
      return result;
    },
    refetchInterval: 2000, // Refetch a cada 2 segundos como fallback
    staleTime: 0, // Sempre considerar stale para forçar refetch
  });
}

export function useSendMessage() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async (content: string) => {
      if (!user) throw new Error('Not authenticated');
      
      // Verificar se está mutado
      const { data: profileData } = await supabase
        .from('profiles')
        .select('*')
        .eq('user_id', user.id)
        .single();
      
      const profile = profileData as { is_muted?: boolean; mute_until?: string | null } | null;
      
      if (profile?.is_muted) {
        const muteUntil = profile.mute_until ? new Date(profile.mute_until) : null;
        const now = new Date();
        
        // Se tem data de expiração e já passou, não está mais mutado
        if (muteUntil && muteUntil < now) {
          // Atualizar status no banco
          await (supabase.from('profiles') as any)
            .update({ is_muted: false, mute_until: null })
            .eq('user_id', user.id);
        } else {
          // Está mutado
          const daysLeft = muteUntil 
            ? Math.ceil((muteUntil.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
            : null;
          throw new Error(
            muteUntil 
              ? `Você está mutado por mais ${daysLeft} dia(s). Você não pode enviar mensagens no chat.`
              : 'Você está mutado permanentemente. Você não pode enviar mensagens no chat.'
          );
        }
      }
      
      console.log('📤 Enviando mensagem:', { user_id: user.id, content });
      
      const { data, error } = await supabase
        .from('chat_messages')
        .insert({
          user_id: user.id,
          content,
        })
        .select()
        .single();
      
      if (error) {
        console.error('❌ Erro ao enviar mensagem:', error);
        throw error;
      }
      
      console.log('✅ Mensagem enviada com sucesso:', data);
      return data;
    },
    onSuccess: async (data) => {
      console.log('✅ onSuccess chamado, mensagem:', data);
      
      // Invalidar e refetch imediatamente
      await queryClient.invalidateQueries({ queryKey: ['chat_messages'] });
      await queryClient.refetchQueries({ queryKey: ['chat_messages'] });
      
      // Forçar atualização imediata do perfil
      await queryClient.refetchQueries({ queryKey: ['profile'] });
      
      // Mostrar notificação imediata (fallback caso banco não crie)
      setTimeout(() => {
        toast.success('Pontos Ganhos!', {
          description: '+1 ponto por participar do chat!',
          duration: 4000,
        });
      }, 500);
    },
    onError: (error: any) => {
      console.error('❌ Erro no onError:', error);
      toast.error('Erro ao enviar mensagem', {
        description: error?.message || 'Tente novamente',
        duration: 5000,
      });
    },
  });
}
