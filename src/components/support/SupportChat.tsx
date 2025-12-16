import { useState, useEffect, useRef } from 'react';
import { Send, Image as ImageIcon, Paperclip } from 'lucide-react';
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
import { uploadImage } from '@/lib/upload';
import { uploadPDF } from '@/lib/upload';

interface SupportChatMessage {
  id: string;
  user_id: string;
  support_user_id: string | null;
  message: string;
  is_from_support: boolean;
  created_at: string;
  image_url?: string | null;
  audio_url?: string | null;
  audio_duration?: number | null;
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
  const [uploadingImage, setUploadingImage] = useState(false);
  const [uploadingFile, setUploadingFile] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const imageInputRef = useRef<HTMLInputElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    loadConversations();
  }, []);

  useEffect(() => {
    if (selectedUserId) {
      loadMessages(selectedUserId);
      const unsubscribe = subscribeToMessages(selectedUserId);
      return () => {
        if (unsubscribe) unsubscribe();
      };
    }
  }, [selectedUserId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const loadConversations = async () => {
    try {
      // Buscar mensagens do support_chat
      const { data: messagesData, error: messagesError } = await (supabase.from('support_chat') as any)
        .select('user_id, message, created_at')
        .order('created_at', { ascending: false });

      if (messagesError) throw messagesError;

      // Pegar IDs únicos de usuários
      const userIds = [...new Set(messagesData?.map((m: any) => m.user_id) || [])];
      
      if (userIds.length === 0) {
        setConversations([]);
        return;
      }

      // Buscar perfis dos usuários
      const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('user_id, username, avatar_url')
        .in('user_id', userIds as string[]);

      if (profilesError) throw profilesError;

      // Criar mapa de perfis
      const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

      // Agrupar por usuário
      const grouped = new Map<string, { userId: string; username: string; avatar: string | null; lastMessage: string; unread: number }>();
      
      messagesData?.forEach((msg: any) => {
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
      const { data: messagesData, error: messagesError } = await (supabase.from('support_chat') as any)
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: true });

      if (messagesError) throw messagesError;

      // Buscar perfis dos usuários
      const userIds = [...new Set(messagesData?.map((m: any) => m.is_from_support ? m.support_user_id : m.user_id).filter(Boolean) || [])] as string[];
      
      if (userIds.length > 0) {
        const { data: profiles } = await supabase
          .from('profiles')
          .select('user_id, username, avatar_url')
          .in('user_id', userIds);

        const profileMap = new Map(profiles?.map(p => [p.user_id, p]) || []);

        const messagesWithProfiles = messagesData?.map((msg: any) => ({
          ...msg,
          profiles: profileMap.get(msg.is_from_support ? msg.support_user_id : msg.user_id) || null
        })) || [];

        setMessages(messagesWithProfiles);
      } else {
        setMessages(messagesData || []);
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
      const { error } = await (supabase.from('support_chat') as any)
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

  const handleImageSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !selectedUserId || !user) return;

    try {
      // Validar arquivo
      if (!file.type.startsWith('image/')) {
        toast.error('Por favor, selecione uma imagem válida');
        return;
      }

      setUploadingImage(true);
      toast.info('Enviando imagem...');
      
      // Upload da imagem
      let imageUrl: string;
      try {
        imageUrl = await uploadImage(file, 'posts', user.id);
        console.log('✅ Imagem enviada com sucesso:', imageUrl);
      } catch (uploadError: any) {
        console.error('❌ Erro no upload:', uploadError);
        const errorMsg = uploadError?.message || 'Erro desconhecido no upload';
        
        if (errorMsg.includes('Bucket not found') || errorMsg.includes('não configurado')) {
          toast.error('Bucket de imagens não configurado. Configure o bucket "images" no Supabase Storage.');
        } else if (errorMsg.includes('permission') || errorMsg.includes('policy')) {
          toast.error('Erro de permissão. Verifique as políticas do Storage no Supabase.');
        } else {
          toast.error(`Erro ao fazer upload: ${errorMsg}`);
        }
        return;
      }
      
      // Enviar mensagem com imagem
      const { error, data } = await supabase
        .from('support_chat')
        .insert({
          user_id: selectedUserId,
          support_user_id: user.id,
          message: '📷 Imagem',
          image_url: imageUrl,
          is_from_support: true,
        })
        .select();
      
      if (error) {
        console.error('❌ Erro ao inserir mensagem:', error);
        
        // Mensagens de erro mais específicas
        if (error.message?.includes('column') && error.message?.includes('image_url')) {
          toast.error('Coluna image_url não existe. Execute ADICIONAR-COLUNA-IMAGE-URL-SUPPORT.sql no Supabase.');
        } else if (error.message?.includes('permission') || error.message?.includes('policy') || error.code === '42501') {
          toast.error('Erro de permissão. Verifique as políticas RLS da tabela support_chat.');
        } else {
          toast.error(`Erro ao enviar mensagem: ${error.message || 'Erro desconhecido'}`);
        }
        return;
      }
      
      console.log('✅ Mensagem com imagem inserida:', data);
      
      loadMessages(selectedUserId);
      loadConversations();
      toast.success('Imagem enviada!');
      
      // Limpar input
      if (imageInputRef.current) {
        imageInputRef.current.value = '';
      }
    } catch (error: any) {
      console.error('❌ Erro geral ao enviar imagem:', error);
      toast.error(`Erro ao enviar imagem: ${error?.message || 'Erro desconhecido'}`);
    } finally {
      setUploadingImage(false);
    }
  };

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !selectedUserId || !user) return;

    try {
      setUploadingFile(true);
      toast.info('Enviando arquivo...');
      
      let fileUrl: string;
      
      // Verificar se é PDF
      if (file.type === 'application/pdf') {
        try {
          fileUrl = await uploadPDF(file, 'pdfs', user.id);
          console.log('✅ PDF enviado com sucesso:', fileUrl);
        } catch (uploadError: any) {
          console.error('❌ Erro no upload do PDF:', uploadError);
          const errorMsg = uploadError?.message || 'Erro desconhecido no upload';
          
          if (errorMsg.includes('Bucket not found') || errorMsg.includes('não configurado')) {
            toast.error('Bucket de documentos não configurado. Configure o bucket "documents" ou "images" no Supabase Storage.');
          } else if (errorMsg.includes('permission') || errorMsg.includes('policy')) {
            toast.error('Erro de permissão. Verifique as políticas do Storage no Supabase.');
          } else {
            toast.error(`Erro ao fazer upload do PDF: ${errorMsg}`);
          }
          return;
        }
      } else {
        // Para outros tipos de arquivo, usar uploadImage como fallback (se for imagem)
        if (file.type.startsWith('image/')) {
          try {
            fileUrl = await uploadImage(file, 'posts', user.id);
            console.log('✅ Arquivo (imagem) enviado com sucesso:', fileUrl);
          } catch (uploadError: any) {
            console.error('❌ Erro no upload:', uploadError);
            toast.error(`Erro ao fazer upload: ${uploadError?.message || 'Erro desconhecido'}`);
            return;
          }
        } else {
          toast.error('Tipo de arquivo não suportado. Use PDF ou imagens.');
          return;
        }
      }
      
      // Enviar mensagem com arquivo
      const fileName = file.name;
      const fileType = file.type === 'application/pdf' ? '📄 PDF' : '📷 Imagem';
      
      const { error, data } = await supabase
        .from('support_chat')
        .insert({
          user_id: selectedUserId,
          support_user_id: user.id,
          message: `${fileType}: ${fileName}`,
          image_url: file.type.startsWith('image/') ? fileUrl : null,
          is_from_support: true,
        })
        .select();
      
      if (error) {
        console.error('❌ Erro ao inserir mensagem:', error);
        toast.error(`Erro ao enviar arquivo: ${error.message || 'Erro desconhecido'}`);
        return;
      }
      
      console.log('✅ Mensagem com arquivo inserida:', data);
      
      loadMessages(selectedUserId);
      loadConversations();
      toast.success('Arquivo enviado!');
      
      // Limpar input
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } catch (error: any) {
      console.error('❌ Erro geral ao enviar arquivo:', error);
      toast.error(`Erro ao enviar arquivo: ${error?.message || 'Erro desconhecido'}`);
    } finally {
      setUploadingFile(false);
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
                        {msg.image_url && (
                          <div className="mb-2">
                            <img
                              src={msg.image_url}
                              alt="Imagem enviada"
                              className="max-w-full max-h-64 rounded-lg object-contain"
                              onClick={() => window.open(msg.image_url || '', '_blank')}
                              style={{ cursor: 'pointer' }}
                            />
                          </div>
                        )}
                        {msg.message && (
                          <p className="text-sm">{msg.message}</p>
                        )}
                        {msg.message?.includes('📄 PDF:') && !msg.image_url && (
                          <a
                            href={msg.message.split('📄 PDF: ')[1]}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-sm underline hover:opacity-80"
                          >
                            {msg.message.split('📄 PDF: ')[1]}
                          </a>
                        )}
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
                <div className="flex gap-2 items-center">
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    onClick={() => imageInputRef.current?.click()}
                    disabled={uploadingImage || uploadingFile}
                    className="flex-shrink-0"
                    title="Enviar imagem"
                  >
                    <ImageIcon className="h-4 w-4" />
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={uploadingImage || uploadingFile}
                    className="flex-shrink-0"
                    title="Enviar arquivo"
                  >
                    <Paperclip className="h-4 w-4" />
                  </Button>
                  <Input
                    placeholder="Digite sua mensagem..."
                    value={newMessage}
                    onChange={(e) => setNewMessage(e.target.value)}
                    className="flex-1 bg-[#2a2a2a] border-[#3a3a3a] text-white placeholder:text-gray-500"
                    disabled={uploadingImage || uploadingFile}
                  />
                  <Button 
                    type="submit" 
                    disabled={loading || (!newMessage.trim() && !uploadingImage && !uploadingFile)}
                  >
                    <Send className="h-4 w-4" />
                  </Button>
                </div>
                <input
                  ref={imageInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleImageSelect}
                />
                <input
                  ref={fileInputRef}
                  type="file"
                  accept=".pdf,image/*"
                  className="hidden"
                  onChange={handleFileSelect}
                />
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
