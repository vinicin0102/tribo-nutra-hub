import { useState, useRef } from 'react';
import { Send, X, Camera, FolderOpen } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useProfile } from '@/hooks/useProfile';
import { useCreatePost } from '@/hooks/usePosts';
import { useAuth } from '@/contexts/AuthContext';
import { useIsSupport } from '@/hooks/useSupport';
import { uploadImage } from '@/lib/upload';
import { toast } from 'sonner';

export function CreatePostCard() {
  const { data: profile } = useProfile();
  const { user } = useAuth();
  const createPost = useCreatePost();
  const isSupport = useIsSupport();
  const [content, setContent] = useState('');
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      // Validar tipo
      if (!file.type.startsWith('image/')) {
        toast.error('Por favor, selecione uma imagem');
        return;
      }

      // Validar tamanho (5MB)
      if (file.size > 5 * 1024 * 1024) {
        toast.error('Imagem muito grande. Tamanho máximo: 5MB');
        return;
      }

      setSelectedImage(file);
      
      // Criar preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveImage = () => {
    setSelectedImage(null);
    setImagePreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleFileButtonClick = () => {
    fileInputRef.current?.click();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Permitir publicar se tiver conteúdo OU imagem
    if (!content.trim() && !selectedImage) {
      toast.error('Escreva algo ou adicione uma imagem para publicar');
      return;
    }

    if (!user) {
      toast.error('Você precisa estar logado');
      return;
    }

    try {
      setIsUploading(true);
      let imageUrl: string | undefined;

      // Fazer upload da imagem se houver
      if (selectedImage) {
        try {
          imageUrl = await uploadImage(selectedImage, 'posts', user.id);
        } catch (uploadError: any) {
          // Se o bucket não existir, usar base64 como fallback temporário
          if (uploadError?.message?.includes('Bucket not found') || 
              uploadError?.message?.includes('não configurado') ||
              uploadError?.message?.includes('not found')) {
            toast.warning('Bucket de imagens não configurado. Usando imagem temporária (base64).');
            // Converter para base64 como fallback
            imageUrl = await new Promise<string>((resolve, reject) => {
              const reader = new FileReader();
              reader.onloadend = () => {
                resolve(reader.result as string);
              };
              reader.onerror = reject;
              reader.readAsDataURL(selectedImage);
            });
          } else {
            // Outros erros de upload
            console.error('Erro no upload:', uploadError);
            throw new Error(uploadError?.message || 'Erro ao fazer upload da imagem');
          }
        }
      }

      // Se não houver conteúdo mas houver imagem, usar texto padrão
      const finalContent = content.trim() || (selectedImage ? '📷' : '');
      
      await createPost.mutateAsync({ 
        content: finalContent, 
        imageUrl,
        isSupport: isSupport
      });
      
      setContent('');
      setSelectedImage(null);
      setImagePreview(null);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
      toast.success('Publicação criada!');
    } catch (error: any) {
      console.error('Erro ao criar publicação:', error);
      const errorMessage = error?.message || 'Erro ao criar publicação';
      toast.error(errorMessage);
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <Card className="mb-4 animate-fade-in border border-[#2a2a2a] bg-[#1a1a1a] shadow-sm">
      <CardContent className="pt-4 pb-4">
        <form onSubmit={handleSubmit}>
          <div className="flex gap-3">
            <Avatar className="h-12 w-12 flex-shrink-0 border-2 border-card">
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
                className="min-h-[80px] resize-none border-0 bg-[#2a2a2a] text-white placeholder:text-gray-500 focus-visible:ring-1 focus-visible:ring-primary"
              />
              
              {/* Input de arquivo oculto */}
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                capture="environment"
                onChange={handleImageSelect}
                className="hidden"
              />

              {imagePreview && (
                <div className="relative rounded-lg overflow-hidden bg-muted">
                  <img 
                    src={imagePreview} 
                    alt="Preview" 
                    className="max-h-48 w-full object-cover"
                  />
                  <button
                    type="button"
                    onClick={handleRemoveImage}
                    className="absolute top-2 right-2 bg-black/50 hover:bg-black/70 text-white rounded-full p-1.5 transition-colors"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
              )}

              <div className="flex items-center justify-between">
                <div className="flex gap-2">
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={handleFileButtonClick}
                    className="text-gray-400 hover:text-white"
                    disabled={isUploading}
                  >
                    <FolderOpen className="h-4 w-4 mr-2" />
                    Fototeca
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      if (fileInputRef.current) {
                        fileInputRef.current.setAttribute('capture', 'environment');
                        fileInputRef.current.click();
                      }
                    }}
                    className="text-gray-400 hover:text-white"
                    disabled={isUploading}
                  >
                    <Camera className="h-4 w-4 mr-2" />
                    Tirar Foto
                  </Button>
                </div>
                <Button 
                  type="submit" 
                  size="sm"
                  disabled={createPost.isPending || isUploading || (!content.trim() && !selectedImage)}
                >
                  <Send className="h-4 w-4 mr-2" />
                  {isUploading ? 'Enviando...' : 'Publicar'}
                </Button>
              </div>
            </div>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
