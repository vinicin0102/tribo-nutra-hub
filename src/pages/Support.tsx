import { useState } from 'react';
import { HelpCircle, Send, ChevronDown, ChevronUp, MessageSquare } from 'lucide-react';
import { MainLayout } from '@/components/layout/MainLayout';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

const faqs = [
  {
    question: 'Como ganho pontos na comunidade?',
    answer: 'Você ganha pontos ao criar publicações (+5 pontos), receber curtidas (+1 ponto) e participar do chat (+1 ponto por mensagem). Quanto mais você interage, mais pontos acumula!'
  },
  {
    question: 'O que são as conquistas/badges?',
    answer: 'Conquistas são selos especiais que você ganha ao atingir determinada quantidade de pontos. Cada badge representa um nível de engajamento na comunidade.'
  },
  {
    question: 'Como funciona o ranking?',
    answer: 'O ranking é baseado na quantidade total de pontos que você acumulou. Todos os membros da comunidade competem no mesmo ranking global.'
  },
  {
    question: 'Posso editar meu perfil?',
    answer: 'Sim! Clique no seu avatar no canto superior direito e selecione "Meu Perfil" para acessar as configurações do seu perfil.'
  },
  {
    question: 'Como faço para entrar em contato com o suporte?',
    answer: 'Você pode usar o formulário abaixo para enviar uma mensagem diretamente para nossa equipe de suporte. Responderemos o mais breve possível!'
  }
];

export default function Support() {
  const { user } = useAuth();
  const [expandedFaq, setExpandedFaq] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    subject: '',
    message: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) {
      toast.error('Você precisa estar logado');
      return;
    }

    if (!formData.subject.trim() || !formData.message.trim()) {
      toast.error('Preencha todos os campos');
      return;
    }

    setLoading(true);
    try {
      const { error } = await supabase
        .from('support_messages')
        .insert({
          user_id: user.id,
          subject: formData.subject,
          message: formData.message,
        });

      if (error) throw error;

      toast.success('Mensagem enviada com sucesso!');
      setFormData({ subject: '', message: '' });
    } catch (error) {
      toast.error('Erro ao enviar mensagem');
    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto space-y-6">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center gradient-primary rounded-2xl p-4 mb-4">
            <HelpCircle className="h-8 w-8 text-primary-foreground" />
          </div>
          <h1 className="font-display text-2xl font-bold mb-2">Central de Ajuda</h1>
          <p className="text-muted-foreground">
            Encontre respostas para suas dúvidas ou entre em contato conosco
          </p>
        </div>

        {/* FAQ */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MessageSquare className="h-5 w-5 text-primary" />
              Perguntas Frequentes
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <div className="divide-y divide-border">
              {faqs.map((faq, index) => (
                <div key={index} className="p-4">
                  <button
                    onClick={() => setExpandedFaq(expandedFaq === index ? null : index)}
                    className="flex items-center justify-between w-full text-left"
                  >
                    <span className="font-medium text-sm pr-4">{faq.question}</span>
                    {expandedFaq === index ? (
                      <ChevronUp className="h-4 w-4 text-muted-foreground flex-shrink-0" />
                    ) : (
                      <ChevronDown className="h-4 w-4 text-muted-foreground flex-shrink-0" />
                    )}
                  </button>
                  <div
                    className={cn(
                      'overflow-hidden transition-all duration-200',
                      expandedFaq === index ? 'mt-3 max-h-40' : 'max-h-0'
                    )}
                  >
                    <p className="text-sm text-muted-foreground">{faq.answer}</p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Contact Form */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Send className="h-5 w-5 text-secondary" />
              Enviar Mensagem
            </CardTitle>
            <CardDescription>
              Não encontrou o que procurava? Entre em contato conosco
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="subject">Assunto</Label>
                <Input
                  id="subject"
                  placeholder="Qual o assunto da sua mensagem?"
                  value={formData.subject}
                  onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="message">Mensagem</Label>
                <Textarea
                  id="message"
                  placeholder="Descreva sua dúvida ou problema..."
                  className="min-h-[120px] resize-none"
                  value={formData.message}
                  onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  required
                />
              </div>
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? 'Enviando...' : 'Enviar Mensagem'}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}
