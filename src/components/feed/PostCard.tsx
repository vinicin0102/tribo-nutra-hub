import { useState } from 'react';
import { Heart, MessageCircle, MoreHorizontal, Trash2, Shield } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Post, useLikePost, useUserLikes } from '@/hooks/usePosts';
import { CommentsSection } from './CommentsSection';
import { useDeletePost, useIsSupport } from '@/hooks/useSupport';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

interface PostCardProps {
  post: Post;
}

export function PostCard({ post }: PostCardProps) {
  const [showComments, setShowComments] = useState(false);
  const likePost = useLikePost();
  const { data: userLikes = [] } = useUserLikes();
  const deletePost = useDeletePost();
  const isSupport = useIsSupport();
  
  const isLiked = userLikes.includes(post.id);
  const profile = post.profiles;
  const isSupportPost = post.is_support_post || profile?.role === 'support' || profile?.role === 'admin';

  const handleDelete = async () => {
    try {
      await deletePost.mutateAsync(post.id);
      toast.success('Publicação removida');
    } catch (error) {
      toast.error('Erro ao remover publicação');
    }
  };

  const handleLike = async () => {
    try {
      await likePost.mutateAsync(post.id);
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  return (
    <Card className={cn(
      "mb-4 animate-slide-up overflow-hidden border shadow-sm",
      isSupportPost 
        ? "border-primary/50 bg-[#1a1a1a] ring-2 ring-primary/20" 
        : "border-[#2a2a2a] bg-[#1a1a1a]"
    )}>
      <CardHeader className="flex-row items-center gap-3 space-y-0 pb-4 pt-4">
        <Avatar className="h-12 w-12 border-2 border-card">
          <AvatarImage src={profile?.avatar_url || ''} />
          <AvatarFallback className="gradient-primary text-primary-foreground font-semibold text-base">
            {profile?.username?.charAt(0).toUpperCase() || 'U'}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <p className="font-semibold text-base leading-tight truncate text-white">
              {profile?.full_name || profile?.username || 'Usuário'}
            </p>
            {isSupportPost && (
              <Badge className="bg-primary text-white text-xs px-2 py-0.5">
                <Shield className="h-3 w-3 mr-1" />
                Suporte
              </Badge>
            )}
          </div>
          {profile?.username && profile?.full_name && (
            <p className="text-xs text-gray-400 truncate">
              {profile.username}
            </p>
          )}
          <p className="text-xs text-gray-400 mt-0.5">
            {new Date(post.created_at).toLocaleDateString('pt-BR', {
              day: '2-digit',
              month: '2-digit',
              year: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            })}
          </p>
        </div>
        <div className="flex items-center gap-1">
          {isSupport && (
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button 
                  variant="ghost" 
                  size="icon" 
                  className="h-8 w-8 flex-shrink-0 text-red-400 hover:text-red-300"
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                <AlertDialogHeader>
                  <AlertDialogTitle className="text-white">
                    Remover publicação
                  </AlertDialogTitle>
                  <AlertDialogDescription className="text-gray-400">
                    Tem certeza que deseja remover esta publicação? Esta ação não pode ser desfeita.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                    Cancelar
                  </AlertDialogCancel>
                  <AlertDialogAction
                    onClick={handleDelete}
                    className="bg-red-500 hover:bg-red-600"
                  >
                    Remover
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          )}
          <Button variant="ghost" size="icon" className="h-8 w-8 flex-shrink-0 text-gray-400 hover:text-white">
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </div>
      </CardHeader>

      <CardContent className="pb-4 px-4">
        {/* Mostrar conteúdo apenas se não for apenas emoji ou espaço */}
        {post.content && post.content.trim() && post.content.trim() !== '📷' && (
          <p className="text-sm leading-relaxed whitespace-pre-wrap mb-3 text-white">{post.content}</p>
        )}
        
        {post.image_url && (
          <div className={cn(
            "rounded-lg overflow-hidden bg-[#2a2a2a]",
            post.content && post.content.trim() && post.content.trim() !== '📷' ? "mt-3" : ""
          )}>
            <img 
              src={post.image_url} 
              alt="Post" 
              className="w-full max-h-[600px] object-cover"
            />
          </div>
        )}
      </CardContent>

      <CardFooter className="flex-col gap-3 pt-0">
        <div className="flex items-center justify-between w-full border-t border-[#2a2a2a] pt-3">
          <Button
            variant="ghost"
            size="sm"
            onClick={handleLike}
            disabled={likePost.isPending}
            className={cn(
              'gap-2 transition-all text-gray-400 hover:text-white',
              isLiked && 'text-red-500 hover:text-red-500'
            )}
          >
            <Heart className={cn('h-4 w-4', isLiked && 'fill-current')} />
            <span className="text-white">{post.likes_count}</span>
          </Button>

          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowComments(!showComments)}
            className="gap-2 text-gray-400 hover:text-white"
          >
            <MessageCircle className="h-4 w-4" />
            <span className="text-white">{post.comments_count}</span>
          </Button>
        </div>

        {showComments && (
          <div className="w-full border-t border-[#2a2a2a] pt-3">
            <CommentsSection postId={post.id} />
          </div>
        )}
      </CardFooter>
    </Card>
  );
}
