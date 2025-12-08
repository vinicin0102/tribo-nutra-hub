import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useEffect } from 'react';

export interface Post {
  id: string;
  user_id: string;
  content: string;
  image_url: string | null;
  video_url: string | null;
  likes_count: number;
  comments_count: number;
  is_support_post?: boolean;
  created_at: string;
  updated_at: string;
  profiles?: {
    username: string;
    avatar_url: string | null;
    full_name: string | null;
    role?: 'user' | 'support' | 'admin';
    subscription_plan?: string;
    tier?: string;
  } | null;
}

export interface Comment {
  id: string;
  user_id: string;
  post_id: string;
  content: string;
  created_at: string;
  profiles?: {
    username: string;
    avatar_url: string | null;
  } | null;
}

export function usePosts() {
  const queryClient = useQueryClient();

  useEffect(() => {
    const channel = supabase
      .channel('posts-changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'posts' },
        () => {
          queryClient.invalidateQueries({ queryKey: ['posts'] });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [queryClient]);

  return useQuery({
    queryKey: ['posts'],
    queryFn: async () => {
      try {
        // Buscar todos os posts ordenados por data
        const { data: posts, error: postsError } = await supabase
          .from('posts')
          .select('*')
          .order('created_at', { ascending: false })
          .limit(100);
        
        if (postsError) {
          console.error('Erro ao carregar posts:', postsError);
          throw postsError;
        }
        
        if (!posts || posts.length === 0) {
          console.log('Nenhum post encontrado');
          return [];
        }
        
        // Filtrar apenas posts com conteúdo válido
        const validPosts = (posts as any[]).filter(p => 
          p.user_id && 
          p.content && 
          typeof p.content === 'string' &&
          p.content.trim() !== ''
        );
        
        if (validPosts.length === 0) {
          console.log('Nenhum post válido encontrado');
          return [];
        }
        
        // Get unique user IDs
        const userIds = [...new Set(validPosts.map(p => p.user_id))];
        
        if (userIds.length === 0) {
          return [];
        }
        
        // Fetch profiles separately
        const { data: profiles, error: profilesError } = await supabase
          .from('profiles')
          .select('*')
          .in('user_id', userIds);
        
        if (profilesError) {
          console.error('Erro ao carregar perfis:', profilesError);
          // Continuar mesmo sem perfis
        }
        
        // Create a map for quick lookup
        const profileMap = new Map((profiles as any[] || []).map(p => [p.user_id, p]));
        
        // Combine posts with profiles
        const combinedPosts = validPosts.map(post => ({
          ...post,
          profiles: profileMap.get(post.user_id) || null
        })) as Post[];
        
        return combinedPosts;
      } catch (error) {
        console.error('Erro ao carregar posts:', error);
        throw error;
      }
    },
    retry: 2,
    refetchOnWindowFocus: true,
    staleTime: 30000,
  });
}

export function useCreatePost() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async ({ content, imageUrl, isSupport }: { content: string; imageUrl?: string; isSupport?: boolean }) => {
      if (!user) throw new Error('Not authenticated');
      
      // Verificar se está mutado
      const { data: profileData } = await supabase
        .from('profiles')
        .select('*')
        .eq('user_id', user.id)
        .single();
      
      const profile = profileData as { is_muted?: boolean; mute_until?: string | null; role?: string } | null;
      
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
              ? `Você está mutado por mais ${daysLeft} dia(s). Você não pode criar publicações.`
              : 'Você está mutado permanentemente. Você não pode criar publicações.'
          );
        }
      }
      
      // Verificar se é suporte
      let isSupportPost = isSupport || false;
      if (!isSupportPost) {
        isSupportPost = profile?.role === 'support' || profile?.role === 'admin';
      }
      
      // Garantir que content não seja null (usar espaço se vazio, pois o banco exige NOT NULL)
      const postContent = content?.trim() || ' ';
      
      const { data, error } = await (supabase.from('posts') as any)
        .insert({
          user_id: user.id,
          content: postContent,
          image_url: imageUrl || null,
          is_support_post: isSupportPost,
        })
        .select()
        .single();
      
      if (error) {
        console.error('Erro ao criar post:', error);
        throw new Error(error.message || 'Erro ao criar publicação');
      }
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      queryClient.invalidateQueries({ queryKey: ['profile'] });
    },
  });
}

export function useLikePost() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async (postId: string) => {
      if (!user) throw new Error('Not authenticated');
      
      const { data: existingLike } = await supabase
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id)
        .maybeSingle();
      
      if (existingLike) {
        const { error } = await supabase
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
        
        if (error) throw error;
        return { liked: false };
      } else {
        const { error } = await supabase
          .from('likes')
          .insert({ post_id: postId, user_id: user.id });
        
        if (error) throw error;
        return { liked: true };
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      queryClient.invalidateQueries({ queryKey: ['likes'] });
      queryClient.invalidateQueries({ queryKey: ['user_likes'] });
      queryClient.invalidateQueries({ queryKey: ['profile'] });
    },
  });
}

export function useUserLikes() {
  const { user } = useAuth();

  return useQuery({
    queryKey: ['likes', user?.id],
    queryFn: async () => {
      if (!user) return [];
      
      const { data, error } = await supabase
        .from('likes')
        .select('post_id')
        .eq('user_id', user.id);
      
      if (error) throw error;
      return data.map(like => like.post_id);
    },
    enabled: !!user,
  });
}

export function useComments(postId: string) {
  const queryClient = useQueryClient();

  useEffect(() => {
    const channel = supabase
      .channel(`comments-${postId}`)
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'comments', filter: `post_id=eq.${postId}` },
        () => {
          queryClient.invalidateQueries({ queryKey: ['comments', postId] });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [postId, queryClient]);

  return useQuery({
    queryKey: ['comments', postId],
    queryFn: async () => {
      const { data: comments, error: commentsError } = await supabase
        .from('comments')
        .select('*')
        .eq('post_id', postId)
        .order('created_at', { ascending: true });
      
      if (commentsError) throw commentsError;
      
      // Get unique user IDs
      const userIds = [...new Set(comments.map(c => c.user_id))];
      
      // Fetch profiles separately
      const { data: profiles } = await supabase
        .from('profiles')
        .select('user_id, username, avatar_url')
        .in('user_id', userIds);
      
      // Create a map for quick lookup
      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);
      
      // Combine comments with profiles
      return comments.map(comment => ({
        ...comment,
        profiles: profileMap.get(comment.user_id) || null
      })) as Comment[];
    },
  });
}

export function useCreateComment() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async ({ postId, content }: { postId: string; content: string }) => {
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
              ? `Você está mutado por mais ${daysLeft} dia(s). Você não pode comentar.`
              : 'Você está mutado permanentemente. Você não pode comentar.'
          );
        }
      }
      
      const { data, error } = await supabase
        .from('comments')
        .insert({
          user_id: user.id,
          post_id: postId,
          content,
        })
        .select()
        .single();
      
      if (error) throw error;
      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['comments', variables.postId] });
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      queryClient.invalidateQueries({ queryKey: ['profile'] });
    },
  });
}
