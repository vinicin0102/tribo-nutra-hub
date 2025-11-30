import { useState } from 'react';
import { Heart, MessageCircle, MoreHorizontal } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Post, useLikePost, useUserLikes } from '@/hooks/usePosts';
import { CommentsSection } from './CommentsSection';
import { cn } from '@/lib/utils';

interface PostCardProps {
  post: Post;
}

export function PostCard({ post }: PostCardProps) {
  const [showComments, setShowComments] = useState(false);
  const likePost = useLikePost();
  const { data: userLikes = [] } = useUserLikes();
  
  const isLiked = userLikes.includes(post.id);
  const profile = post.profiles;

  const handleLike = async () => {
    try {
      await likePost.mutateAsync(post.id);
    } catch (error) {
      console.error('Error liking post:', error);
    }
  };

  return (
    <Card className="mb-4 animate-slide-up overflow-hidden">
      <CardHeader className="flex-row items-center gap-3 space-y-0 pb-3">
        <Avatar className="h-10 w-10">
          <AvatarImage src={profile?.avatar_url || ''} />
          <AvatarFallback className="gradient-primary text-primary-foreground font-semibold">
            {profile?.username?.charAt(0).toUpperCase() || 'U'}
          </AvatarFallback>
        </Avatar>
        <div className="flex-1">
          <p className="font-semibold text-sm">{profile?.username || 'Usuário'}</p>
          <p className="text-xs text-muted-foreground">
            {formatDistanceToNow(new Date(post.created_at), { 
              addSuffix: true, 
              locale: ptBR 
            })}
          </p>
        </div>
        <Button variant="ghost" size="icon" className="h-8 w-8">
          <MoreHorizontal className="h-4 w-4" />
        </Button>
      </CardHeader>

      <CardContent className="pb-3">
        <p className="text-sm whitespace-pre-wrap">{post.content}</p>
        
        {post.image_url && (
          <div className="mt-3 rounded-lg overflow-hidden bg-muted">
            <img 
              src={post.image_url} 
              alt="Post" 
              className="w-full max-h-96 object-cover"
            />
          </div>
        )}
      </CardContent>

      <CardFooter className="flex-col gap-3 pt-0">
        <div className="flex items-center justify-between w-full border-t border-border pt-3">
          <Button
            variant="ghost"
            size="sm"
            onClick={handleLike}
            disabled={likePost.isPending}
            className={cn(
              'gap-2 transition-all',
              isLiked && 'text-destructive hover:text-destructive'
            )}
          >
            <Heart className={cn('h-4 w-4', isLiked && 'fill-current')} />
            <span>{post.likes_count}</span>
          </Button>

          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowComments(!showComments)}
            className="gap-2"
          >
            <MessageCircle className="h-4 w-4" />
            <span>{post.comments_count}</span>
          </Button>
        </div>

        {showComments && (
          <div className="w-full border-t border-border pt-3">
            <CommentsSection postId={post.id} />
          </div>
        )}
      </CardFooter>
    </Card>
  );
}
