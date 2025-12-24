import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'sonner';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import { Plus, Pencil, Trash2, Eye, EyeOff, ExternalLink, AlertTriangle } from 'lucide-react';

interface Popup {
    id: string;
    title: string;
    message: string | null;
    image_url: string | null;
    button_text: string | null;
    button_link: string | null;
    is_active: boolean;
    show_once_per_user: boolean;
    created_at: string;
}

interface PopupFormData {
    title: string;
    message: string;
    image_url: string;
    button_text: string;
    button_link: string;
    is_active: boolean;
    show_once_per_user: boolean;
}

// Helper para acessar tabela app_popups (não existe no schema ainda)
const getAppPopupsTable = () => {
    return (supabase as any).from('app_popups');
};

export function PopupManagement() {
    const { user } = useAuth();
    const queryClient = useQueryClient();
    const [isEditing, setIsEditing] = useState(false);
    const [editingPopup, setEditingPopup] = useState<Popup | null>(null);
    const [formData, setFormData] = useState<PopupFormData>({
        title: '',
        message: '',
        image_url: '',
        button_text: '',
        button_link: '',
        is_active: false,
        show_once_per_user: true,
    });

    // Buscar todos os popups
    const { data: popups, isLoading, error: fetchError } = useQuery({
        queryKey: ['admin-popups'],
        queryFn: async () => {
            const { data, error } = await getAppPopupsTable()
                .select('*')
                .order('created_at', { ascending: false });

            if (error) throw error;
            return data as Popup[];
        },
    });

    // Criar popup
    const createMutation = useMutation({
        mutationFn: async (data: PopupFormData) => {
            const { error } = await getAppPopupsTable()
                .insert({
                    ...data,
                    created_by: user?.id,
                });

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['admin-popups'] });
            toast.success('Popup criado com sucesso!');
            resetForm();
        },
        onError: (error) => {
            console.error('Erro ao criar popup:', error);
            toast.error('Erro ao criar popup');
        },
    });

    // Atualizar popup
    const updateMutation = useMutation({
        mutationFn: async ({ id, data }: { id: string; data: Partial<PopupFormData> }) => {
            const { error } = await getAppPopupsTable()
                .update(data)
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['admin-popups'] });
            toast.success('Popup atualizado!');
            resetForm();
        },
        onError: (error) => {
            console.error('Erro ao atualizar popup:', error);
            toast.error('Erro ao atualizar popup');
        },
    });

    // Deletar popup
    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await getAppPopupsTable()
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['admin-popups'] });
            toast.success('Popup excluído!');
        },
        onError: (error) => {
            console.error('Erro ao excluir popup:', error);
            toast.error('Erro ao excluir popup');
        },
    });

    // Toggle ativo
    const toggleActiveMutation = useMutation({
        mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
            // Se ativando, desativar todos os outros primeiro
            if (is_active) {
                await getAppPopupsTable()
                    .update({ is_active: false })
                    .neq('id', id);
            }

            const { error } = await getAppPopupsTable()
                .update({ is_active })
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: (_, { is_active }) => {
            queryClient.invalidateQueries({ queryKey: ['admin-popups'] });
            toast.success(is_active ? 'Popup ativado!' : 'Popup desativado!');
        },
    });

    const resetForm = () => {
        setIsEditing(false);
        setEditingPopup(null);
        setFormData({
            title: '',
            message: '',
            image_url: '',
            button_text: '',
            button_link: '',
            is_active: false,
            show_once_per_user: true,
        });
    };

    const handleEdit = (popup: Popup) => {
        setIsEditing(true);
        setEditingPopup(popup);
        setFormData({
            title: popup.title,
            message: popup.message || '',
            image_url: popup.image_url || '',
            button_text: popup.button_text || '',
            button_link: popup.button_link || '',
            is_active: popup.is_active,
            show_once_per_user: popup.show_once_per_user,
        });
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.title.trim()) {
            toast.error('Título é obrigatório');
            return;
        }

        if (editingPopup) {
            updateMutation.mutate({ id: editingPopup.id, data: formData });
        } else {
            createMutation.mutate(formData);
        }
    };

    // Se a tabela não existe, mostrar mensagem
    if (fetchError) {
        return (
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardContent className="p-6">
                    <div className="flex items-center gap-3 text-yellow-500">
                        <AlertTriangle className="h-5 w-5" />
                        <p>Sistema de popups não configurado. A tabela app_popups precisa ser criada.</p>
                    </div>
                </CardContent>
            </Card>
        );
    }

    return (
        <div className="space-y-6">
            {/* Formulário */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                        {editingPopup ? <Pencil className="h-5 w-5" /> : <Plus className="h-5 w-5" />}
                        {editingPopup ? 'Editar Popup' : 'Criar Novo Popup'}
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div className="grid gap-4 md:grid-cols-2">
                            <div className="space-y-2">
                                <Label className="text-white">Título *</Label>
                                <Input
                                    value={formData.title}
                                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                    placeholder="Ex: Oferta Especial!"
                                    className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                />
                            </div>

                            <div className="space-y-2">
                                <Label className="text-white">URL da Imagem</Label>
                                <Input
                                    value={formData.image_url}
                                    onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                                    placeholder="https://exemplo.com/imagem.jpg"
                                    className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label className="text-white">Mensagem</Label>
                            <Textarea
                                value={formData.message}
                                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                                placeholder="Escreva a mensagem do popup..."
                                className="bg-[#2a2a2a] border-[#3a3a3a] text-white min-h-[100px]"
                            />
                        </div>

                        <div className="grid gap-4 md:grid-cols-2">
                            <div className="space-y-2">
                                <Label className="text-white">Texto do Botão</Label>
                                <Input
                                    value={formData.button_text}
                                    onChange={(e) => setFormData({ ...formData, button_text: e.target.value })}
                                    placeholder="Ex: Saiba Mais"
                                    className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                />
                            </div>

                            <div className="space-y-2">
                                <Label className="text-white">Link do Botão</Label>
                                <Input
                                    value={formData.button_link}
                                    onChange={(e) => setFormData({ ...formData, button_link: e.target.value })}
                                    placeholder="https://exemplo.com"
                                    className="bg-[#2a2a2a] border-[#3a3a3a] text-white"
                                />
                            </div>
                        </div>

                        <div className="flex flex-wrap gap-6">
                            <div className="flex items-center gap-2">
                                <Switch
                                    checked={formData.show_once_per_user}
                                    onCheckedChange={(checked) => setFormData({ ...formData, show_once_per_user: checked })}
                                />
                                <Label className="text-white">Mostrar apenas 1x por usuário</Label>
                            </div>

                            <div className="flex items-center gap-2">
                                <Switch
                                    checked={formData.is_active}
                                    onCheckedChange={(checked) => setFormData({ ...formData, is_active: checked })}
                                />
                                <Label className="text-white">Ativar imediatamente</Label>
                            </div>
                        </div>

                        <div className="flex gap-2">
                            <Button
                                type="submit"
                                className="bg-primary hover:bg-primary/90"
                                disabled={createMutation.isPending || updateMutation.isPending}
                            >
                                {editingPopup ? 'Salvar Alterações' : 'Criar Popup'}
                            </Button>
                            {editingPopup && (
                                <Button type="button" variant="outline" onClick={resetForm}>
                                    Cancelar
                                </Button>
                            )}
                        </div>
                    </form>
                </CardContent>
            </Card>

            {/* Lista de Popups */}
            <Card className="bg-[#1a1a1a] border-[#2a2a2a]">
                <CardHeader>
                    <CardTitle className="text-white">Popups Criados</CardTitle>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <p className="text-gray-400">Carregando...</p>
                    ) : popups?.length === 0 ? (
                        <p className="text-gray-400">Nenhum popup criado ainda.</p>
                    ) : (
                        <div className="space-y-4">
                            {popups?.map((popup) => (
                                <div
                                    key={popup.id}
                                    className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 bg-[#2a2a2a] rounded-lg"
                                >
                                    <div className="flex-1">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h3 className="text-white font-medium">{popup.title}</h3>
                                            {popup.is_active ? (
                                                <Badge className="bg-green-500/20 text-green-400">Ativo</Badge>
                                            ) : (
                                                <Badge variant="secondary">Inativo</Badge>
                                            )}
                                        </div>
                                        {popup.message && (
                                            <p className="text-gray-400 text-sm line-clamp-2">{popup.message}</p>
                                        )}
                                        {popup.button_link && (
                                            <div className="flex items-center gap-1 mt-1 text-xs text-primary">
                                                <ExternalLink className="h-3 w-3" />
                                                <span className="truncate max-w-[200px]">{popup.button_link}</span>
                                            </div>
                                        )}
                                    </div>

                                    <div className="flex items-center gap-2">
                                        <Button
                                            size="sm"
                                            variant="ghost"
                                            onClick={() => toggleActiveMutation.mutate({
                                                id: popup.id,
                                                is_active: !popup.is_active
                                            })}
                                            className="text-gray-400 hover:text-white"
                                        >
                                            {popup.is_active ? (
                                                <EyeOff className="h-4 w-4" />
                                            ) : (
                                                <Eye className="h-4 w-4" />
                                            )}
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="ghost"
                                            onClick={() => handleEdit(popup)}
                                            className="text-gray-400 hover:text-white"
                                        >
                                            <Pencil className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="ghost"
                                            onClick={() => {
                                                if (confirm('Tem certeza que deseja excluir este popup?')) {
                                                    deleteMutation.mutate(popup.id);
                                                }
                                            }}
                                            className="text-red-400 hover:text-red-300"
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}