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
