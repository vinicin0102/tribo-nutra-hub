import { useState, useEffect, useRef } from 'react';
import { Send, Trash2 } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { MainLayout } from '@/components/layout/MainLayout';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useChatMessages, useSendMessage } from '@/hooks/useChat';
import { useDeleteChatMessage, useIsSupport } from '@/hooks/useSupport';
import { useAuth } from '@/contexts/AuthContext';
import { Skeleton } from '@/components/ui/skeleton';
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

export default function Chat() {
  const { user } = useAuth();
  const { data: messages, isLoading } = useChatMessages();
  const sendMessage = useSendMessage();
  const deleteMessage = useDeleteChatMessage();
  const isSupport = useIsSupport();
  const [newMessage, setNewMessage] = useState('');
  const [viewportHeight, setViewportHeight] = useState(
    window.visualViewport?.height || window.innerHeight
  );
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const chatContainerRef = useRef<HTMLDivElement>(null);

  const handleDelete = async (messageId: string) => {
    try {
      await deleteMessage.mutateAsync(messageId);
      toast.success('Mensagem removida');
    } catch (error) {
      toast.error('Erro ao remover mensagem');
    }
  };

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Detectar mudanças na altura do viewport quando o teclado aparece/desaparece
  useEffect(() => {
    const handleResize = () => {
      // Usar visualViewport.height diretamente quando disponível (melhor para mobile)
      if (window.visualViewport) {
        setViewportHeight(window.visualViewport.height);
      } else {
        setViewportHeight(window.innerHeight);
      }
    };

    // Usar visualViewport se disponível (melhor para mobile)
    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', handleResize);
      // Atualizar imediatamente
      handleResize();
      return () => window.visualViewport?.removeEventListener('resize', handleResize);
    } else {
      window.addEventListener('resize', handleResize);
      handleResize();
      return () => window.removeEventListener('resize', handleResize);
    }
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim()) return;

    try {
      await sendMessage.mutateAsync(newMessage);
      setNewMessage('');
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  // Calcular altura disponível - usar visualViewport diretamente quando disponível
  // Isso garante que quando o teclado aparecer, a altura seja ajustada imediatamente
  // Subtrair apenas a navbar (64px), o bottom nav será coberto pelo teclado
  const availableHeight = (window.visualViewport?.height || viewportHeight) - 64;

  return (
    <MainLayout>
      <div 
        ref={chatContainerRef}
        className="fixed inset-x-0 top-16 flex flex-col bg-[#0a0a0a] overflow-hidden"
        style={{ 
          height: `${availableHeight}px`,
          maxHeight: `${availableHeight}px`,
          bottom: 0
        }}
      >
        <div className="max-w-2xl mx-auto w-full h-full flex flex-col px-2 sm:px-0">
          <Card className="flex-1 flex flex-col border border-[#2a2a2a] bg-[#1a1a1a] min-h-0 overflow-hidden h-full">
          <CardHeader className="border-b border-[#2a2a2a] pb-4 flex-shrink-0">
            <CardTitle className="flex items-center gap-2 text-white">
              <div className="bg-primary rounded-lg p-2">
                <span className="text-lg">💬</span>
              </div>
              Chat da Tribo
            </CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col flex-1 min-h-0 p-0 overflow-hidden">
            <div className="flex-1 overflow-y-auto p-4 space-y-3 min-h-0">
              {isLoading ? (
                <div className="space-y-3">
                  {[1, 2, 3, 4, 5].map((i) => (
                    <div key={i} className={cn('flex gap-2', i % 2 === 0 && 'flex-row-reverse')}>
                      <Skeleton className="h-8 w-8 rounded-full flex-shrink-0" />
                      <Skeleton className="h-16 w-3/4 rounded-lg" />
                    </div>
                  ))}
                </div>
              ) : messages && messages.length > 0 ? (
                <>
                  {messages.map((message) => {
                    const isOwn = message.user_id === user?.id;
                    
                    return (
                      <div
                        key={message.id}
                        className={cn(
                          'flex gap-2 animate-fade-in',
                          isOwn && 'flex-row-reverse'
                        )}
                      >
                        <Avatar className="h-8 w-8 flex-shrink-0">
                          <AvatarImage 
                            src={message.profiles?.avatar_url || ''} 
                            className="object-cover object-center"
                          />
                          <AvatarFallback className="text-xs gradient-primary text-primary-foreground">
                            {message.profiles?.username?.charAt(0).toUpperCase() || 'U'}
                          </AvatarFallback>
                        </Avatar>
                        <div
                          className={cn(
                            'max-w-[70%] rounded-2xl px-4 py-2 relative group',
                            isOwn 
                              ? 'gradient-primary text-primary-foreground rounded-tr-sm' 
                              : 'bg-[#2a2a2a] text-white rounded-tl-sm'
                          )}
                        >
                          {isSupport && (
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="absolute -top-2 -right-2 h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity bg-red-500/80 hover:bg-red-500 text-white"
                                >
                                  <Trash2 className="h-3 w-3" />
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent className="bg-[#1a1a1a] border-[#2a2a2a]">
                                <AlertDialogHeader>
                                  <AlertDialogTitle className="text-white">
                                    Remover mensagem
                                  </AlertDialogTitle>
                                  <AlertDialogDescription className="text-gray-400">
                                    Tem certeza que deseja remover esta mensagem?
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel className="bg-[#2a2a2a] text-white border-[#3a3a3a]">
                                    Cancelar
                                  </AlertDialogCancel>
                                  <AlertDialogAction
                                    onClick={() => handleDelete(message.id)}
                                    className="bg-red-500 hover:bg-red-600"
                                  >
                                    Remover
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          )}
                          {!isOwn && (
                            <p className="text-xs font-semibold mb-1 opacity-70">
                              {message.profiles?.username || 'Usuário'}
                            </p>
                          )}
                          <p className="text-sm">{message.content}</p>
                          <p className={cn(
                            'text-[10px] mt-1',
                            isOwn ? 'text-primary-foreground/70' : 'text-gray-400'
                          )}>
                            {formatDistanceToNow(new Date(message.created_at), { 
                              addSuffix: true, 
                              locale: ptBR 
                            })}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                  <div ref={messagesEndRef} />
                </>
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-center">
                  <div className="gradient-primary rounded-2xl p-4 mb-4">
                    <span className="text-4xl">👋</span>
                  </div>
                  <h3 className="font-display text-lg font-semibold mb-2">
                    Bem-vindo ao chat!
                  </h3>
                  <p className="text-muted-foreground text-sm">
                    Seja o primeiro a enviar uma mensagem
                  </p>
                </div>
              )}
            </div>

            <form 
              onSubmit={handleSubmit} 
              className="border-t border-[#2a2a2a] p-4 flex gap-2 flex-shrink-0 bg-[#1a1a1a]"
            >
              <Input
                placeholder="Digite sua mensagem..."
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                className="flex-1 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
                onFocus={(e) => {
                  // Atualizar altura imediatamente quando o input receber foco
                  if (window.visualViewport) {
                    setViewportHeight(window.visualViewport.height);
                  }
                  // Scroll para o final quando o input receber foco (aguardar teclado aparecer)
                  setTimeout(() => {
                    if (window.visualViewport) {
                      setViewportHeight(window.visualViewport.height);
                    }
                    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
                  }, 300);
                }}
              />
              <Button 
                type="submit" 
                disabled={sendMessage.isPending || !newMessage.trim()}
              >
                <Send className="h-4 w-4" />
              </Button>
            </form>
          </CardContent>
        </Card>
        </div>
      </div>
    </MainLayout>
  );
}
