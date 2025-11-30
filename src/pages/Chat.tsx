import { useState, useEffect, useRef } from 'react';
import { Send } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { MainLayout } from '@/components/layout/MainLayout';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useChatMessages, useSendMessage } from '@/hooks/useChat';
import { useAuth } from '@/contexts/AuthContext';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';

export default function Chat() {
  const { user } = useAuth();
  const { data: messages, isLoading } = useChatMessages();
  const sendMessage = useSendMessage();
  const [newMessage, setNewMessage] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

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

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto">
        <Card className="h-[calc(100vh-12rem)]">
          <CardHeader className="border-b border-border pb-4">
            <CardTitle className="flex items-center gap-2">
              <div className="gradient-primary rounded-lg p-2">
                <span className="text-lg">💬</span>
              </div>
              Chat da Tribo
            </CardTitle>
          </CardHeader>
          <CardContent className="flex flex-col h-[calc(100%-5rem)] p-0">
            <div className="flex-1 overflow-y-auto p-4 space-y-3">
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
                          <AvatarImage src={message.profiles?.avatar_url || ''} />
                          <AvatarFallback className="text-xs gradient-primary text-primary-foreground">
                            {message.profiles?.username?.charAt(0).toUpperCase() || 'U'}
                          </AvatarFallback>
                        </Avatar>
                        <div
                          className={cn(
                            'max-w-[70%] rounded-2xl px-4 py-2',
                            isOwn 
                              ? 'gradient-primary text-primary-foreground rounded-tr-sm' 
                              : 'bg-muted rounded-tl-sm'
                          )}
                        >
                          {!isOwn && (
                            <p className="text-xs font-semibold mb-1 opacity-70">
                              {message.profiles?.username || 'Usuário'}
                            </p>
                          )}
                          <p className="text-sm">{message.content}</p>
                          <p className={cn(
                            'text-[10px] mt-1',
                            isOwn ? 'text-primary-foreground/70' : 'text-muted-foreground'
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
              className="border-t border-border p-4 flex gap-2"
            >
              <Input
                placeholder="Digite sua mensagem..."
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                className="flex-1"
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
    </MainLayout>
  );
}
