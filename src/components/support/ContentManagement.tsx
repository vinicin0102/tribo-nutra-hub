import { useState, useEffect } from 'react';
import { 
  useModulesWithLessons, 
  useCreateModule, 
  useUpdateModule, 
  useDeleteModule,
  useCreateLesson,
  useUpdateLesson,
  useDeleteLesson,
  Module,
  Lesson,
  ExternalLink
} from '@/hooks/useCourses';
import { useUnlockedModules } from '@/hooks/useUnlockedModules';
import { useReorderModules } from '@/hooks/useReorderModules';
import { useReorderLessons } from '@/hooks/useReorderLessons';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Pencil, Trash2, ChevronDown, ChevronRight, BookOpen, Play, X, Link as LinkIcon, Lock, Unlock, Image as ImageIcon, Image } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';
import { CoverUpload } from '@/components/courses/CoverUpload';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { SortableModuleItem } from './SortableModuleItem';
import { SortableLessonItem } from './SortableLessonItem';

function ModuleForm({ 
  module, 
  onSubmit, 
  onCancel 
}: { 
  module?: Module; 
  onSubmit: (data: Partial<Module>) => void;
  onCancel: () => void;
}) {
  const [title, setTitle] = useState(module?.title || '');
  const [description, setDescription] = useState(module?.description || '');
  const [orderIndex, setOrderIndex] = useState(module?.order_index || 0);
  const [isPublished, setIsPublished] = useState(module?.is_published || false);
  const [isLocked, setIsLocked] = useState(module?.is_locked || false);
  const [coverUrl, setCoverUrl] = useState(module?.cover_url || '');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ 
      title, 
      description, 
      order_index: orderIndex, 
      is_published: isPublished,
      is_locked: isLocked,
      cover_url: coverUrl || null
    });
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
      <div>
        <Label>Capa do Módulo</Label>
        <CoverUpload
          currentUrl={coverUrl}
          onUpload={(url) => setCoverUrl(url)}
          onRemove={() => setCoverUrl('')}
          folder="modules"
          aspectRatio="16:9"
        />
      </div>
      <div>
        <Label htmlFor="title">Título do Módulo</Label>
        <Input
          id="title"
          value={title}
          onChange={e => setTitle(e.target.value)}
          placeholder="Ex: Introdução ao Curso"
          required
        />
      </div>
      <div>
        <Label htmlFor="description">Descrição</Label>
        <Textarea
          id="description"
          value={description}
          onChange={e => setDescription(e.target.value)}
          placeholder="Descreva o conteúdo deste módulo..."
          rows={3}
        />
      </div>
      <div>
        <Label htmlFor="order">Ordem</Label>
        <Input
          id="order"
          type="number"
          value={orderIndex}
          onChange={e => setOrderIndex(parseInt(e.target.value) || 0)}
          min={0}
        />
      </div>
      <div className="space-y-3 pt-2 border-t border-border">
        <div className="flex items-center justify-between">
          <Label htmlFor="published" className="flex items-center gap-2">
            <Play className="w-4 h-4" />
            Publicado
          </Label>
          <Switch
            id="published"
            checked={isPublished}
            onCheckedChange={setIsPublished}
          />
        </div>
        <div className="flex items-center justify-between">
          <Label htmlFor="locked" className="flex items-center gap-2">
            <Lock className="w-4 h-4 text-destructive" />
            Módulo Bloqueado
          </Label>
          <Switch
            id="locked"
            checked={isLocked}
            onCheckedChange={setIsLocked}
          />
        </div>
        {isLocked && (
          <p className="text-xs text-muted-foreground bg-destructive/10 p-2 rounded">
            Módulos bloqueados aparecem em preto e branco com um cadeado para os alunos.
          </p>
        )}
      </div>
      <div className="flex gap-2 pt-2">
        <Button type="button" variant="outline" onClick={onCancel} className="flex-1">
          Cancelar
        </Button>
        <Button type="submit" className="flex-1">
          {module ? 'Atualizar' : 'Criar'} Módulo
        </Button>
      </div>
    </form>
  );
}

function LessonForm({ 
  lesson, 
  modules,
  defaultModuleId,
  onSubmit, 
  onCancel 
}: { 
  lesson?: Lesson; 
  modules: Module[];
  defaultModuleId?: string;
  onSubmit: (data: Partial<Lesson>) => void;
  onCancel: () => void;
}) {
  const [moduleId, setModuleId] = useState(lesson?.module_id || defaultModuleId || '');
  const [title, setTitle] = useState(lesson?.title || '');
  const [description, setDescription] = useState(lesson?.description || '');
  const [vturbCode, setVturbCode] = useState(lesson?.vturb_code || '');
  const [orderIndex, setOrderIndex] = useState(lesson?.order_index || 0);
  const [durationMinutes, setDurationMinutes] = useState(lesson?.duration_minutes || 0);
  const [isPublished, setIsPublished] = useState(lesson?.is_published || false);
  const [coverUrl, setCoverUrl] = useState(lesson?.cover_url || '');
  const [externalLinks, setExternalLinks] = useState<ExternalLink[]>(lesson?.external_links || []);
  const [newLinkTitle, setNewLinkTitle] = useState('');
  const [newLinkUrl, setNewLinkUrl] = useState('');

  const addLink = () => {
    if (newLinkTitle && newLinkUrl) {
      setExternalLinks([...externalLinks, { title: newLinkTitle, url: newLinkUrl }]);
      setNewLinkTitle('');
      setNewLinkUrl('');
    }
  };

  const removeLink = (index: number) => {
    setExternalLinks(externalLinks.filter((_, i) => i !== index));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ 
      module_id: moduleId,
      title, 
      description, 
      vturb_code: vturbCode,
      order_index: orderIndex, 
      duration_minutes: durationMinutes,
      is_published: isPublished,
      cover_url: coverUrl || null,
      external_links: externalLinks
    });
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
      <div>
        <Label>Thumbnail da Aula</Label>
        <CoverUpload
          currentUrl={coverUrl}
          onUpload={(url) => setCoverUrl(url)}
          onRemove={() => setCoverUrl('')}
          folder="lessons"
          aspectRatio="16:9"
        />
      </div>
      <div>
        <Label htmlFor="module">Módulo</Label>
        <Select value={moduleId} onValueChange={setModuleId} required>
          <SelectTrigger>
            <SelectValue placeholder="Selecione o módulo" />
          </SelectTrigger>
          <SelectContent>
            {modules.map(m => (
              <SelectItem key={m.id} value={m.id}>{m.title}</SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
      <div>
        <Label htmlFor="title">Título da Aula</Label>
        <Input
          id="title"
          value={title}
          onChange={e => setTitle(e.target.value)}
          placeholder="Ex: Bem-vindo ao curso"
          required
        />
      </div>
      <div>
        <Label htmlFor="description">Descrição</Label>
        <Textarea
          id="description"
          value={description}
          onChange={e => setDescription(e.target.value)}
          placeholder="Descreva o conteúdo desta aula..."
          rows={3}
        />
      </div>
      <div>
        <Label htmlFor="vturb">Código do Vídeo</Label>
        <Textarea
          id="vturb"
          value={vturbCode}
          onChange={e => setVturbCode(e.target.value)}
          placeholder="Cole o código embed do vídeo (Panda Video, Vturb, Voomly, etc.)"
          rows={4}
          className="font-mono text-xs"
        />
        <p className="text-xs text-muted-foreground mt-1">
          Suporta: Panda Video, Vturb, Voomly ou qualquer iframe. Cole o código completo do embed.
        </p>
      </div>
      <div className="grid grid-cols-2 gap-4">
        <div>
          <Label htmlFor="order">Ordem</Label>
          <Input
            id="order"
            type="number"
            value={orderIndex}
            onChange={e => setOrderIndex(parseInt(e.target.value) || 0)}
            min={0}
          />
        </div>
        <div>
          <Label htmlFor="duration">Duração (min)</Label>
          <Input
            id="duration"
            type="number"
            value={durationMinutes}
            onChange={e => setDurationMinutes(parseInt(e.target.value) || 0)}
            min={0}
          />
        </div>
      </div>

      {/* External Links */}
      <div className="space-y-2">
        <Label>Links Externos</Label>
        {externalLinks.map((link, index) => (
          <div key={index} className="flex items-center gap-2 bg-muted p-2 rounded-lg">
            <LinkIcon className="w-4 h-4 text-muted-foreground shrink-0" />
            <span className="text-sm truncate flex-1">{link.title}</span>
            <button
              type="button"
              onClick={() => removeLink(index)}
              className="text-destructive hover:text-destructive/80"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        ))}
        <div className="flex gap-2">
          <Input
            placeholder="Título do link"
            value={newLinkTitle}
            onChange={e => setNewLinkTitle(e.target.value)}
            className="flex-1"
          />
          <Input
            placeholder="URL"
            value={newLinkUrl}
            onChange={e => setNewLinkUrl(e.target.value)}
            className="flex-1"
          />
          <Button type="button" variant="outline" size="icon" onClick={addLink}>
            <Plus className="w-4 h-4" />
          </Button>
        </div>
      </div>

      {/* Toggles */}
      <div className="space-y-3 pt-2 border-t border-border">
        <div className="flex items-center justify-between">
          <Label htmlFor="published" className="flex items-center gap-2">
            <Play className="w-4 h-4" />
            Publicado
          </Label>
          <Switch
            id="published"
            checked={isPublished}
            onCheckedChange={setIsPublished}
          />
        </div>
      </div>

      <div className="flex gap-2 pt-2">
        <Button type="button" variant="outline" onClick={onCancel} className="flex-1">
          Cancelar
        </Button>
        <Button type="submit" className="flex-1">
          {lesson ? 'Atualizar' : 'Criar'} Aula
        </Button>
      </div>
    </form>
  );
}

export function ContentManagement() {
  const { data: modules, isLoading } = useModulesWithLessons();
  const createModule = useCreateModule();
  const updateModule = useUpdateModule();
  const deleteModule = useDeleteModule();
  const createLesson = useCreateLesson();
  const updateLesson = useUpdateLesson();
  const deleteLesson = useDeleteLesson();
  const { isUnlocked, unlockModule, lockModule } = useUnlockedModules();
  const reorderModules = useReorderModules();
  const reorderLessons = useReorderLessons();

  const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());
  const [moduleDialogOpen, setModuleDialogOpen] = useState(false);
  const [lessonDialogOpen, setLessonDialogOpen] = useState(false);
  const [bannerDialogOpen, setBannerDialogOpen] = useState(false);
  const [editingModule, setEditingModule] = useState<Module | null>(null);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [selectedModuleId, setSelectedModuleId] = useState<string | undefined>();
  const [bannerImageUrl, setBannerImageUrl] = useState('');
  const [bannerTitle, setBannerTitle] = useState('');
  const [bannerDescription, setBannerDescription] = useState('');
  const [bannerLinkUrl, setBannerLinkUrl] = useState('');
  const [modulesList, setModulesList] = useState<Module[]>([]);
  const [lessonsByModule, setLessonsByModule] = useState<Record<string, Lesson[]>>({});

  // Sincronizar módulos e aulas quando dados mudarem
  useEffect(() => {
    if (modules) {
      setModulesList(modules);
      const lessonsMap: Record<string, Lesson[]> = {};
      modules.forEach(module => {
        if (module.lessons) {
          lessonsMap[module.id] = module.lessons;
        }
      });
      setLessonsByModule(lessonsMap);
    }
  }, [modules]);

  // Configurar sensores para drag and drop
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  // Carregar banner existente
  useEffect(() => {
    try {
      const stored = localStorage.getItem('course_banner');
      if (stored) {
        const banner = JSON.parse(stored);
        setBannerImageUrl(banner.image_url || '');
        setBannerTitle(banner.title || '');
        setBannerDescription(banner.description || '');
        setBannerLinkUrl(banner.link_url || '');
      }
    } catch (e) {
      console.error('Error loading banner:', e);
    }
  }, []);

  const handleSaveBanner = () => {
    const banner = {
      image_url: bannerImageUrl || null,
      title: bannerTitle || null,
      description: bannerDescription || null,
      link_url: bannerLinkUrl || null,
      is_active: true,
      created_at: new Date().toISOString(),
    };
    localStorage.setItem('course_banner', JSON.stringify(banner));
    setBannerDialogOpen(false);
    // Recarregar página para atualizar o banner
    window.location.reload();
  };

  const handleDeleteBanner = () => {
    if (confirm('Tem certeza que deseja remover o banner?')) {
      localStorage.removeItem('course_banner');
      setBannerImageUrl('');
      setBannerTitle('');
      setBannerDescription('');
      setBannerLinkUrl('');
      window.location.reload();
    }
  };

  const toggleModule = (moduleId: string) => {
    setExpandedModules(prev => {
      const next = new Set(prev);
      if (next.has(moduleId)) {
        next.delete(moduleId);
      } else {
        next.add(moduleId);
      }
      return next;
    });
  };

  const handleCreateModule = (data: Partial<Module>) => {
    createModule.mutate(data as any, {
      onSuccess: () => {
        setModuleDialogOpen(false);
        setEditingModule(null);
      }
    });
  };

  const handleUpdateModule = (data: Partial<Module>) => {
    if (!editingModule) return;
    updateModule.mutate({ id: editingModule.id, ...data }, {
      onSuccess: () => {
        setModuleDialogOpen(false);
        setEditingModule(null);
      }
    });
  };

  const handleDeleteModule = (id: string) => {
    if (confirm('Tem certeza que deseja excluir este módulo? Todas as aulas serão excluídas também.')) {
      deleteModule.mutate(id);
    }
  };

  const handleCreateLesson = (data: Partial<Lesson>) => {
    createLesson.mutate(data as any, {
      onSuccess: () => {
        setLessonDialogOpen(false);
        setEditingLesson(null);
        setSelectedModuleId(undefined);
      }
    });
  };

  const handleUpdateLesson = (data: Partial<Lesson>) => {
    if (!editingLesson) return;
    updateLesson.mutate({ id: editingLesson.id, ...data }, {
      onSuccess: () => {
        setLessonDialogOpen(false);
        setEditingLesson(null);
      }
    });
  };

  const handleDeleteLesson = (id: string) => {
    if (confirm('Tem certeza que deseja excluir esta aula?')) {
      deleteLesson.mutate(id);
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map(i => (
          <Skeleton key={i} className="h-20 w-full bg-muted" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <h2 className="text-lg font-semibold text-foreground">Gerenciar Conteúdo</h2>
        <div className="flex gap-2">
          <Dialog open={moduleDialogOpen} onOpenChange={setModuleDialogOpen}>
            <DialogTrigger asChild>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => setEditingModule(null)}
              >
                <Plus className="w-4 h-4 mr-2" />
                Módulo
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>{editingModule ? 'Editar Módulo' : 'Novo Módulo'}</DialogTitle>
              </DialogHeader>
              <ModuleForm
                module={editingModule || undefined}
                onSubmit={editingModule ? handleUpdateModule : handleCreateModule}
                onCancel={() => {
                  setModuleDialogOpen(false);
                  setEditingModule(null);
                }}
              />
            </DialogContent>
          </Dialog>

          <Dialog open={lessonDialogOpen} onOpenChange={setLessonDialogOpen}>
            <DialogTrigger asChild>
              <Button 
                size="sm"
                onClick={() => {
                  setEditingLesson(null);
                  setSelectedModuleId(undefined);
                }}
                disabled={!modules || modules.length === 0}
              >
                <Plus className="w-4 h-4 mr-2" />
                Aula
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>{editingLesson ? 'Editar Aula' : 'Nova Aula'}</DialogTitle>
              </DialogHeader>
              <LessonForm
                lesson={editingLesson || undefined}
                modules={modules || []}
                defaultModuleId={selectedModuleId}
                onSubmit={editingLesson ? handleUpdateLesson : handleCreateLesson}
                onCancel={() => {
                  setLessonDialogOpen(false);
                  setEditingLesson(null);
                  setSelectedModuleId(undefined);
                }}
              />
            </DialogContent>
          </Dialog>

          <Dialog open={bannerDialogOpen} onOpenChange={setBannerDialogOpen}>
            <DialogTrigger asChild>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => {
                  try {
                    const stored = localStorage.getItem('course_banner');
                    if (stored) {
                      const banner = JSON.parse(stored);
                      setBannerImageUrl(banner.image_url || '');
                      setBannerTitle(banner.title || '');
                      setBannerDescription(banner.description || '');
                      setBannerLinkUrl(banner.link_url || '');
                    }
                  } catch (e) {
                    console.error('Error loading banner:', e);
                  }
                }}
              >
                <Image className="w-4 h-4 mr-2" />
                Banner
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>Gerenciar Banner da Área de Membros</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
                <div>
                  <Label>Imagem do Banner</Label>
                  <CoverUpload
                    currentUrl={bannerImageUrl}
                    onUpload={(url) => setBannerImageUrl(url)}
                    onRemove={() => setBannerImageUrl('')}
                    folder="banners"
                    aspectRatio="16:9"
                  />
                  <p className="text-xs text-muted-foreground mt-1">
                    Recomendado: 1200x400px ou proporção 3:1
                  </p>
                </div>
                <div>
                  <Label htmlFor="banner-title">Título (Opcional)</Label>
                  <Input
                    id="banner-title"
                    value={bannerTitle}
                    onChange={e => setBannerTitle(e.target.value)}
                    placeholder="Ex: Novo curso disponível!"
                  />
                </div>
                <div>
                  <Label htmlFor="banner-description">Descrição (Opcional)</Label>
                  <Textarea
                    id="banner-description"
                    value={bannerDescription}
                    onChange={e => setBannerDescription(e.target.value)}
                    placeholder="Descrição do banner..."
                    rows={3}
                  />
                </div>
                <div>
                  <Label htmlFor="banner-link">Link (Opcional)</Label>
                  <Input
                    id="banner-link"
                    value={bannerLinkUrl}
                    onChange={e => setBannerLinkUrl(e.target.value)}
                    placeholder="https://..."
                    type="url"
                  />
                  <p className="text-xs text-muted-foreground mt-1">
                    URL para onde o banner deve redirecionar ao ser clicado
                  </p>
                </div>
                <div className="flex gap-2 pt-2">
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setBannerDialogOpen(false)} 
                    className="flex-1"
                  >
                    Cancelar
                  </Button>
                  {bannerImageUrl && (
                    <Button 
                      type="button" 
                      variant="destructive" 
                      onClick={handleDeleteBanner} 
                      className="flex-1"
                    >
                      Remover
                    </Button>
                  )}
                  <Button 
                    type="button" 
                    onClick={handleSaveBanner} 
                    className="flex-1"
                  >
                    Salvar Banner
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>

          <Dialog open={bannerDialogOpen} onOpenChange={setBannerDialogOpen}>
            <DialogTrigger asChild>
              <Button 
                variant="outline" 
                size="sm"
                onClick={() => {
                  try {
                    const stored = localStorage.getItem('course_banner');
                    if (stored) {
                      const banner = JSON.parse(stored);
                      setBannerImageUrl(banner.image_url || '');
                      setBannerTitle(banner.title || '');
                      setBannerDescription(banner.description || '');
                      setBannerLinkUrl(banner.link_url || '');
                    } else {
                      setBannerImageUrl('');
                      setBannerTitle('');
                      setBannerDescription('');
                      setBannerLinkUrl('');
                    }
                  } catch (e) {
                    console.error('Error loading banner:', e);
                  }
                }}
              >
                <Image className="w-4 h-4 mr-2" />
                Banner
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-lg">
              <DialogHeader>
                <DialogTitle>Gerenciar Banner da Área de Membros</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
                <div>
                  <Label>Imagem do Banner</Label>
                  <CoverUpload
                    currentUrl={bannerImageUrl}
                    onUpload={(url) => setBannerImageUrl(url)}
                    onRemove={() => setBannerImageUrl('')}
                    folder="banners"
                    aspectRatio="16:9"
                  />
                  <p className="text-xs text-muted-foreground mt-1">
                    Recomendado: 1200x400px ou proporção 3:1
                  </p>
                </div>
                <div>
                  <Label htmlFor="banner-title">Título (Opcional)</Label>
                  <Input
                    id="banner-title"
                    value={bannerTitle}
                    onChange={e => setBannerTitle(e.target.value)}
                    placeholder="Ex: Novo curso disponível!"
                  />
                </div>
                <div>
                  <Label htmlFor="banner-description">Descrição (Opcional)</Label>
                  <Textarea
                    id="banner-description"
                    value={bannerDescription}
                    onChange={e => setBannerDescription(e.target.value)}
                    placeholder="Descrição do banner..."
                    rows={3}
                  />
                </div>
                <div>
                  <Label htmlFor="banner-link">Link (Opcional)</Label>
                  <Input
                    id="banner-link"
                    value={bannerLinkUrl}
                    onChange={e => setBannerLinkUrl(e.target.value)}
                    placeholder="https://..."
                    type="url"
                  />
                  <p className="text-xs text-muted-foreground mt-1">
                    URL para onde o banner deve redirecionar ao ser clicado
                  </p>
                </div>
                <div className="flex gap-2 pt-2">
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setBannerDialogOpen(false)} 
                    className="flex-1"
                  >
                    Cancelar
                  </Button>
                  {bannerImageUrl && (
                    <Button 
                      type="button" 
                      variant="destructive" 
                      onClick={handleDeleteBanner} 
                      className="flex-1"
                    >
                      Remover
                    </Button>
                  )}
                  <Button 
                    type="button" 
                    onClick={handleSaveBanner} 
                    className="flex-1"
                  >
                    Salvar Banner
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Modules List */}
      {!modules || modules.length === 0 ? (
        <Card className="bg-card border-border">
          <CardContent className="py-8 text-center">
            <BookOpen className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
            <p className="text-muted-foreground">Nenhum módulo criado ainda</p>
            <p className="text-muted-foreground/70 text-sm mt-1">Crie seu primeiro módulo para começar</p>
          </CardContent>
        </Card>
      ) : (
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragEnd={handleModuleDragEnd}
        >
          <SortableContext
            items={modulesList.map(m => m.id)}
            strategy={verticalListSortingStrategy}
          >
            <div className="space-y-3">
              {modulesList.map(module => (
                <SortableModuleItem
                  key={module.id}
                  module={module}
                  isExpanded={expandedModules.has(module.id)}
                  onToggle={() => toggleModule(module.id)}
                  onAddLesson={() => {
                    setSelectedModuleId(module.id);
                    setEditingLesson(null);
                    setLessonDialogOpen(true);
                  }}
                  onEdit={() => {
                    setEditingModule(module);
                    setModuleDialogOpen(true);
                  }}
                  onDelete={() => handleDeleteModule(module.id)}
                />
              ))}
            </div>
          </SortableContext>

          {/* Aulas dentro de cada módulo */}
          {modulesList.map(module => {
            if (!expandedModules.has(module.id)) return null;
            
            const lessons = lessonsByModule[module.id] || [];
            
            return (
              <Card key={`lessons-${module.id}`} className="mt-2 ml-4 border-border">
                <CardContent className="pt-3 pb-3">
                  {lessons.length > 0 ? (
                    <DndContext
                      sensors={sensors}
                      collisionDetection={closestCenter}
                      onDragEnd={(e) => handleLessonDragEnd(e, module.id)}
                    >
                      <SortableContext
                        items={lessons.map(l => l.id)}
                        strategy={verticalListSortingStrategy}
                      >
                        <div className="space-y-1 ml-8 border-l border-border pl-4">
                          {lessons.map((lesson, index) => (
                            <SortableLessonItem
                              key={lesson.id}
                              lesson={lesson}
                              index={index}
                              onEdit={() => {
                                setEditingLesson(lesson);
                                setLessonDialogOpen(true);
                              }}
                              onDelete={() => handleDeleteLesson(lesson.id)}
                            />
                          ))}
                        </div>
                      </SortableContext>
                    </DndContext>
                  ) : (
                    <p className="text-sm text-muted-foreground ml-8 py-2">
                      Nenhuma aula neste módulo
                    </p>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </DndContext>
      )}
    </div>
  );
}
