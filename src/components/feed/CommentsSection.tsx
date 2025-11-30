import { useState } from 'react';
import { Send } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useComments, useCreateComment } from '@/hooks/usePosts';
import { Skeleton } from '@/components/ui/skeleton';

interface CommentsSectionProps {
  postId: string;
}

export function CommentsSection({ postId }: CommentsSectionProps) {
  const { data: comments, isLoading } = useComments(postId);
  const createComment = useCreateComment();
  const [newComment, setNewComment] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim()) return;

    try {
      await createComment.mutateAsync({ postId, content: newComment });
      setNewComment('');
    } catch (error) {
      console.error('Error creating comment:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-3">
        {[1, 2].map((i) => (
          <div key={i} className="flex gap-2">
            <Skeleton className="h-8 w-8 rounded-full" />
            <Skeleton className="h-16 flex-1 rounded-lg" />
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {comments && comments.length > 0 && (
        <div className="space-y-3 max-h-60 overflow-y-auto">
          {comments.map((comment) => (
            <div key={comment.id} className="flex gap-2 animate-fade-in">
              <Avatar className="h-8 w-8 flex-shrink-0">
                <AvatarImage src={comment.profiles?.avatar_url || ''} />
                <AvatarFallback className="text-xs gradient-primary text-primary-foreground">
                  {comment.profiles?.username?.charAt(0).toUpperCase() || 'U'}
                </AvatarFallback>
              </Avatar>
              <div className="flex-1 rounded-lg bg-muted p-2">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-semibold">
                    {comment.profiles?.username || 'Usuário'}
                  </span>
                  <span className="text-[10px] text-muted-foreground">
                    {formatDistanceToNow(new Date(comment.created_at), { 
                      addSuffix: true, 
                      locale: ptBR 
                    })}
                  </span>
                </div>
                <p className="text-sm mt-0.5">{comment.content}</p>
              </div>
            </div>
          ))}
        </div>
      )}

      <form onSubmit={handleSubmit} className="flex gap-2">
        <Input
          placeholder="Escreva um comentário..."
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          className="flex-1"
        />
        <Button 
          type="submit" 
          size="icon"
          disabled={createComment.isPending || !newComment.trim()}
        >
          <Send className="h-4 w-4" />
        </Button>
      </form>
    </div>
  );
}
