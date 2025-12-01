import { useState, useEffect, useRef } from 'react';
import { Send } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from '@/hooks/useProfile';
import { toast } from 'sonner';
import { formatDistanceToNow } from 'date-fns';
import { ptBR } from 'date-fns/locale';

interface SupportChatMessage {
  id: string;
  user_id: string;
  support_user_id: string | null;
  message: string;
  is_from_support: boolean;
  created_at: string;
  profiles?: {
    username: string;
    avatar_url: string | null;
  } | null;
}

export function SupportChat() {
  const { user } = useAuth();
  const { data: supportProfile } = useProfile();
  const [conversations, setConversations] = useState<{ userId: string; username: string; avatar: string | null; lastMessage: string; unread: number }[]>([]);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [messages, setMessages] = useState<SupportChatMessage[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadConversations();
  }, []);

  useEffect(() => {
    if (selectedUserId) {
      loadMessages(selectedUserId);
      subscribeToMessages(selectedUserId);
    }
  }, [selectedUserId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const loadConversations = async () => {
    try {
      // Buscar usuários únicos que têm mensagens no support_chat
      const { data: messages, error: messagesError } = await supabase
        .from('support_chat')
        .select('user_id, message, created_at')
        .order('created_at', { ascending: false });

      if (messagesError) throw messagesError;

      // Pegar IDs únicos de usuários
      const userIds = [...new Set(messages?.map(m => m.user_id) || [])];
      
      if (userIds.length === 0) {
        setConversations([]);
        return;
      }

      // Buscar perfis dos usuários
      const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('user_id, username, avatar_url')
        .in('user_id', userIds);

      if (profilesError) throw profilesError;

      // Criar mapa de perfis
      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

      // Agrupar por usuário
      const grouped = new Map<string, { userId: string; username: string; avatar: string | null; lastMessage: string; unread: number }>();
      
      messages?.forEach((msg: any) => {
        const userId = msg.user_id;
        if (!grouped.has(userId)) {
          const profile = profileMap.get(userId);
          grouped.set(userId, {
            userId,
            username: profile?.username || 'Usuário',
            avatar: profile?.avatar_url || null,
            lastMessage: msg.message,
            unread: 0
          });
        }
      });

      setConversations(Array.from(grouped.values()));
    } catch (error) {
      console.error('Erro ao carregar conversas:', error);
    }
  };

  const loadMessages = async (userId: string) => {
    try {
      const { data: messages, error: messagesError } = await supabase
        .from('support_chat')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: true });

      if (messagesError) throw messagesError;

      // Buscar perfis dos usuários
      const userIds = [...new Set(messages?.map(m => m.is_from_support ? m.support_user_id : m.user_id).filter(Boolean) || [])];
      
      if (userIds.length > 0) {
        const { data: profiles } = await supabase
          .from('profiles')
          .select('user_id, username, avatar_url')
          .in('user_id', userIds);

        const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

        const messagesWithProfiles = messages?.map(msg => ({
          ...msg,
          profiles: profileMap.get(msg.is_from_support ? msg.support_user_id : msg.user_id) || null
        })) || [];

        setMessages(messagesWithProfiles);
      } else {
        setMessages(messages || []);
      }
    } catch (error) {
      console.error('Erro ao carregar mensagens:', error);
    }
  };

  const subscribeToMessages = (userId: string) => {
    const channel = supabase
      .channel(`support-chat-${userId}`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'support_chat',
          filter: `user_id=eq.${userId}`,
        },
        () => {
          loadMessages(userId);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  };

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newMessage.trim() || !selectedUserId || !user) return;

    setLoading(true);
    try {
      const { error } = await supabase
        .from('support_chat')
        .insert({
          user_id: selectedUserId,
          support_user_id: user.id,
          message: newMessage.trim(),
          is_from_support: true,
        });

      if (error) throw error;

      setNewMessage('');
      loadMessages(selectedUserId);
    } catch (error: any) {
      toast.error('Erro ao enviar mensagem');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-4 h-[calc(100vh-200px)]">
      {/* Lista de conversas */}
      <Card className="border border-[#2a2a2a] bg-[#1a1a1a]">
        <CardHeader>
          <CardTitle className="text-white">Conversas</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <div className="divide-y divide-[#2a2a2a] max-h-[calc(100vh-300px)] overflow-y-auto">
            {conversations.length === 0 ? (
              <div className="p-4 text-center text-gray-400">
                <p>Nenhuma conversa ainda</p>
              </div>
            ) : (
              conversations.map((conv) => (
                <button
                  key={conv.userId}
                  onClick={() => setSelectedUserId(conv.userId)}
                  className={`
                    w-full p-4 flex items-center gap-3 hover:bg-[#2a2a2a] transition-colors text-left
                    ${selectedUserId === conv.userId ? 'bg-[#2a2a2a]' : ''}
                  `}
                >
                  <Avatar className="h-10 w-10">
                    <AvatarImage src={conv.avatar || ''} />
                    <AvatarFallback className="bg-primary text-white">
                      {conv.username.charAt(0).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-semibold truncate">{conv.username}</p>
                    <p className="text-xs text-gray-400 truncate">{conv.lastMessage}</p>
                  </div>
                </button>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      {/* Área de mensagens */}
      <div className="lg:col-span-2">
        {selectedUserId ? (
          <Card className="border border-[#2a2a2a] bg-[#1a1a1a] h-full flex flex-col">
            <CardHeader className="border-b border-[#2a2a2a]">
              <CardTitle className="text-white">
                {conversations.find(c => c.userId === selectedUserId)?.username || 'Usuário'}
              </CardTitle>
            </CardHeader>
            <CardContent className="flex-1 flex flex-col p-0">
              {/* Mensagens */}
              <div className="flex-1 overflow-y-auto p-4 space-y-4">
                {messages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`flex gap-3 ${msg.is_from_support ? 'justify-end' : 'justify-start'}`}
                  >
                    {!msg.is_from_support && (
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={msg.profiles?.avatar_url || ''} />
                        <AvatarFallback className="bg-primary text-white text-xs">
                          {msg.profiles?.username?.charAt(0).toUpperCase() || 'U'}
                        </AvatarFallback>
                      </Avatar>
                    )}
                    <div className={`max-w-[70%] ${msg.is_from_support ? 'order-2' : ''}`}>
                      <div
                        className={`rounded-lg p-3 ${
                          msg.is_from_support
                            ? 'bg-primary text-white'
                            : 'bg-[#2a2a2a] text-white'
                        }`}
                      >
                        <p className="text-sm">{msg.message}</p>
                      </div>
                      <p className="text-xs text-gray-400 mt-1">
                        {formatDistanceToNow(new Date(msg.created_at), {
                          addSuffix: true,
                          locale: ptBR,
                        })}
                      </p>
                    </div>
                    {msg.is_from_support && (
                      <Avatar className="h-8 w-8">
                        <AvatarImage src={supportProfile?.avatar_url || ''} />
                        <AvatarFallback className="bg-primary text-white text-xs">
                          {supportProfile?.username?.charAt(0).toUpperCase() || 'S'}
                        </AvatarFallback>
                      </Avatar>
                    )}
                  </div>
                ))}
                <div ref={messagesEndRef} />
              </div>

              {/* Input de mensagem */}
              <form onSubmit={handleSendMessage} className="border-t border-[#2a2a2a] p-4">
                <div className="flex gap-2">
                  <Input
                    placeholder="Digite sua mensagem..."
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    className="flex-1 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
                  />
                  <Button type="submit" disabled={loading || !newMessage.trim()}>
                    <Send className="h-4 w-4" />
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        ) : (
          <Card className="border border-[#2a2a2a] bg-[#1a1a1a] h-full flex items-center justify-center">
            <CardContent>
              <p className="text-gray-400 text-center">Selecione uma conversa para começar</p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}

