import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useEffect } from 'react';

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
    const channel = supabase
      .channel('chat-messages')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'chat_messages' },
        () => {
          queryClient.invalidateQueries({ queryKey: ['chat_messages'] });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [queryClient]);

  return useQuery({
    queryKey: ['chat_messages'],
    queryFn: async () => {
      const { data: messages, error: messagesError } = await supabase
        .from('chat_messages')
        .select('*')
        .order('created_at', { ascending: true })
        .limit(100);
      
      if (messagesError) throw messagesError;
      
      // Get unique user IDs
      const userIds = [...new Set(messages.map(m => m.user_id))];
      
      // Fetch profiles separately
      const { data: profiles } = await supabase
        .from('profiles')
        .select('user_id, username, avatar_url')
        .in('user_id', userIds);
      
      // Create a map for quick lookup
      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);
      
      // Combine messages with profiles
      return messages.map(message => ({
        ...message,
        profiles: profileMap.get(message.user_id) || null
      })) as ChatMessage[];
    },
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
      
      const { data, error } = await supabase
        .from('chat_messages')
        .insert({
          user_id: user.id,
          content,
        })
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chat_messages'] });
    },
  });
}
