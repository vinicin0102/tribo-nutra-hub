import { useState } from 'react';
import { ImagePlus, Send, X } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useProfile } from '@/hooks/useProfile';
import { useCreatePost } from '@/hooks/usePosts';
import { toast } from 'sonner';

export function CreatePostCard() {
  const { data: profile } = useProfile();
  const createPost = useCreatePost();
  const [content, setContent] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [showImageInput, setShowImageInput] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!content.trim()) {
      toast.error('Escreva algo para publicar');
      return;
    }

    try {
      await createPost.mutateAsync({ content, imageUrl: imageUrl || undefined });
      setContent('');
      setImageUrl('');
      setShowImageInput(false);
      toast.success('Publicação criada!');
    } catch (error) {
      toast.error('Erro ao criar publicação');
    }
  };

  return (
    <Card className="mb-4 animate-fade-in">
      <CardContent className="pt-4">
        <form onSubmit={handleSubmit}>
          <div className="flex gap-3">
            <Avatar className="h-10 w-10 flex-shrink-0">
              <AvatarImage src={profile?.avatar_url || ''} />
              <AvatarFallback className="gradient-primary text-primary-foreground font-semibold">
                {profile?.username?.charAt(0).toUpperCase() || 'U'}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 space-y-3">
              <Textarea
                placeholder="Compartilhe sua evolução com a tribo..."
                value={content}
                onChange={(e) => setContent(e.target.value)}
                className="min-h-[80px] resize-none border-0 bg-muted/50 focus-visible:ring-1"
              />
              
              {showImageInput && (
                <div className="relative">
                  <input
                    type="url"
                    placeholder="Cole o link da imagem aqui..."
                    value={imageUrl}
                    onChange={(e) => setImageUrl(e.target.value)}
                    className="w-full rounded-lg border border-input bg-background px-3 py-2 text-sm"
                  />
                  <button
                    type="button"
                    onClick={() => {
                      setImageUrl('');
                      setShowImageInput(false);
                    }}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
              )}

              {imageUrl && (
                <div className="relative rounded-lg overflow-hidden bg-muted">
                  <img 
                    src={imageUrl} 
                    alt="Preview" 
                    className="max-h-48 w-full object-cover"
                    onError={() => toast.error('Imagem inválida')}
                  />
                </div>
              )}

              <div className="flex items-center justify-between">
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => setShowImageInput(!showImageInput)}
                  className="text-muted-foreground"
                >
                  <ImagePlus className="h-4 w-4 mr-2" />
                  Imagem
                </Button>
                <Button 
                  type="submit" 
                  size="sm"
                  disabled={createPost.isPending || !content.trim()}
                >
                  <Send className="h-4 w-4 mr-2" />
                  Publicar
                </Button>
              </div>
            </div>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
