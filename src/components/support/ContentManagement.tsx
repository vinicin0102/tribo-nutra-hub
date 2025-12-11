import { useState } from 'react';
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
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Pencil, Trash2, ChevronDown, ChevronRight, BookOpen, Play, X, Link as LinkIcon, Lock, Image as ImageIcon } from 'lucide-react';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';
import { CoverUpload } from '@/components/courses/CoverUpload';

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
  const [coverUrl, setCoverUrl] = useState(module?.cover_url || '');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ 
      title, 
      description, 
      order_index: orderIndex, 
      is_published: isPublished,
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
      <div className="flex items-center gap-2">
        <Switch
          id="published"
          checked={isPublished}
          onCheckedChange={setIsPublished}
        />
        <Label htmlFor="published">Publicado</Label>
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
  const [isLocked, setIsLocked] = useState(lesson?.is_locked || false);
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
      is_locked: isLocked,
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
        <Label htmlFor="vturb">Código Vturb</Label>
        <Textarea
          id="vturb"
          value={vturbCode}
          onChange={e => setVturbCode(e.target.value)}
          placeholder="Cole o código de embed do Vturb aqui..."
          rows={4}
          className="font-mono text-xs"
        />
        <p className="text-xs text-muted-foreground mt-1">Cole o código de embed completo ou apenas o ID do vídeo</p>
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
        <div className="flex items-center justify-between">
          <Label htmlFor="locked" className="flex items-center gap-2">
            <Lock className="w-4 h-4 text-destructive" />
            Aula Bloqueada
          </Label>
          <Switch
            id="locked"
            checked={isLocked}
            onCheckedChange={setIsLocked}
          />
        </div>
        {isLocked && (
          <p className="text-xs text-muted-foreground bg-destructive/10 p-2 rounded">
            Aulas bloqueadas aparecem em preto e branco com um cadeado para os alunos.
          </p>
        )}
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

  const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());
  const [moduleDialogOpen, setModuleDialogOpen] = useState(false);
  const [lessonDialogOpen, setLessonDialogOpen] = useState(false);
  const [editingModule, setEditingModule] = useState<Module | null>(null);
  const [editingLesson, setEditingLesson] = useState<Lesson | null>(null);
  const [selectedModuleId, setSelectedModuleId] = useState<string | undefined>();

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
        <div className="space-y-3">
          {modules.map(module => (
            <Card key={module.id} className="bg-card border-border overflow-hidden">
              <CardHeader className="p-3">
                <div className="flex items-center gap-3">
                  <button
                    onClick={() => toggleModule(module.id)}
                    className="p-1 hover:bg-muted rounded"
                  >
                    {expandedModules.has(module.id) ? (
                      <ChevronDown className="w-5 h-5 text-muted-foreground" />
                    ) : (
                      <ChevronRight className="w-5 h-5 text-muted-foreground" />
                    )}
                  </button>
                  
                  {/* Module Thumbnail */}
                  <div className="w-16 h-10 rounded overflow-hidden shrink-0 bg-muted">
                    {module.cover_url ? (
                      <img src={module.cover_url} alt="" className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <ImageIcon className="w-4 h-4 text-muted-foreground" />
                      </div>
                    )}
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <CardTitle className="text-sm font-medium text-foreground truncate">
                        {module.title}
                      </CardTitle>
                      {!module.is_published && (
                        <span className="text-xs bg-yellow-500/20 text-yellow-500 px-2 py-0.5 rounded">
                          Rascunho
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {module.lessons?.length || 0} aula(s) • Ordem: {module.order_index}
                    </p>
                  </div>
                  <div className="flex gap-1">
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      onClick={() => {
                        setSelectedModuleId(module.id);
                        setEditingLesson(null);
                        setLessonDialogOpen(true);
                      }}
                      title="Adicionar aula"
                    >
                      <Plus className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className={cn(
                        "h-8 w-8",
                        isUnlocked(module.id) 
                          ? "text-green-500 hover:text-green-600" 
                          : "text-muted-foreground hover:text-foreground"
                      )}
                      onClick={() => {
                        if (isUnlocked(module.id)) {
                          lockModule(module.id);
                        } else {
                          unlockModule(module.id);
                        }
                      }}
                      title={isUnlocked(module.id) ? "Bloquear módulo" : "Desbloquear módulo"}
                    >
                      <Lock className={cn("w-4 h-4", isUnlocked(module.id) && "fill-current")} />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8"
                      onClick={() => {
                        setEditingModule(module);
                        setModuleDialogOpen(true);
                      }}
                      title="Editar módulo"
                    >
                      <Pencil className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="h-8 w-8 text-destructive hover:text-destructive/80"
                      onClick={() => handleDeleteModule(module.id)}
                      title="Excluir módulo"
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </CardHeader>

              {expandedModules.has(module.id) && (
                <CardContent className="pt-0 pb-3">
                  {module.lessons && module.lessons.length > 0 ? (
                    <div className="space-y-1 ml-8 border-l border-border pl-4">
                      {module.lessons.map((lesson, index) => (
                        <div
                          key={lesson.id}
                          className={cn(
                            "flex items-center gap-2 py-2 px-3 rounded-lg",
                            lesson.is_locked 
                              ? "bg-destructive/10 border border-destructive/30" 
                              : "bg-muted"
                          )}
                        >
                          {/* Lesson Thumbnail */}
                          <div className={cn(
                            "w-14 h-9 rounded overflow-hidden shrink-0 bg-background relative",
                            lesson.is_locked && "grayscale"
                          )}>
                            {lesson.cover_url ? (
                              <img src={lesson.cover_url} alt="" className="w-full h-full object-cover" />
                            ) : (
                              <div className="w-full h-full flex items-center justify-center">
                                <Play className="w-3 h-3 text-muted-foreground" />
                              </div>
                            )}
                            {lesson.is_locked && (
                              <div className="absolute inset-0 flex items-center justify-center bg-black/40">
                                <Lock className="w-3 h-3 text-white" />
                              </div>
                            )}
                          </div>
                          
                          <div className="w-6 h-6 rounded-full bg-background flex items-center justify-center text-xs text-muted-foreground shrink-0">
                            {index + 1}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <p className="text-sm text-foreground truncate">{lesson.title}</p>
                              {lesson.is_locked && (
                                <span className="flex items-center gap-1 text-xs bg-destructive/20 text-destructive px-1.5 py-0.5 rounded">
                                  <Lock className="w-3 h-3" />
                                  Bloqueada
                                </span>
                              )}
                            </div>
                            <p className="text-xs text-muted-foreground">
                              {lesson.duration_minutes || 0} min
                              {!lesson.is_published && ' • Rascunho'}
                            </p>
                          </div>
                          <div className="flex gap-1">
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-7 w-7"
                              onClick={() => {
                                setEditingLesson(lesson);
                                setLessonDialogOpen(true);
                              }}
                            >
                              <Pencil className="w-3 h-3" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-7 w-7 text-destructive hover:text-destructive/80"
                              onClick={() => handleDeleteLesson(lesson.id)}
                            >
                              <Trash2 className="w-3 h-3" />
                            </Button>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="text-sm text-muted-foreground ml-8 py-2">
                      Nenhuma aula neste módulo
                    </p>
                  )}
                </CardContent>
              )}
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
