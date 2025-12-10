import { useParams, useNavigate } from 'react-router-dom';
import { useLesson, useLessons, useModules, Lesson as LessonType } from '@/hooks/useCourses';
import { ArrowLeft, ArrowRight, ExternalLink, Clock, ChevronDown, ChevronUp, List } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { useState } from 'react';
import { cn } from '@/lib/utils';

function VturbPlayer({ code }: { code: string }) {
  // Se o código for um iframe completo, extrair o src ou usar diretamente
  if (code.includes('<iframe') || code.includes('<script')) {
    return (
      <div 
        className="w-full aspect-video bg-black rounded-lg overflow-hidden"
        dangerouslySetInnerHTML={{ __html: code }}
      />
    );
  }

  // Se for apenas o ID do vídeo, criar o iframe
  return (
    <div className="w-full aspect-video bg-black rounded-lg overflow-hidden">
      <iframe
        src={`https://scripts.converteai.net/${code}`}
        className="w-full h-full"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />
    </div>
  );
}

function LessonSidebar({ 
  lessons, 
  currentLessonId, 
  moduleId,
  isOpen,
  onToggle
}: { 
  lessons: LessonType[]; 
  currentLessonId: string;
  moduleId: string;
  isOpen: boolean;
  onToggle: () => void;
}) {
  const navigate = useNavigate();

  return (
    <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] overflow-hidden">
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors"
      >
        <span className="font-medium text-white flex items-center gap-2">
          <List className="w-4 h-4" />
          Aulas do módulo
        </span>
        {isOpen ? (
          <ChevronUp className="w-5 h-5 text-gray-400" />
        ) : (
          <ChevronDown className="w-5 h-5 text-gray-400" />
        )}
      </button>
      
      {isOpen && (
        <div className="border-t border-[#2a2a2a] max-h-64 overflow-y-auto">
          {lessons.map((lesson, index) => (
            <button
              key={lesson.id}
              onClick={() => navigate(`/courses/${moduleId}/${lesson.id}`)}
              className={cn(
                'w-full flex items-center gap-3 p-3 text-left transition-colors',
                lesson.id === currentLessonId
                  ? 'bg-primary/20 border-l-2 border-primary'
                  : 'hover:bg-[#222]'
              )}
            >
              <span className={cn(
                'w-6 h-6 rounded-full flex items-center justify-center text-xs font-medium',
                lesson.id === currentLessonId
                  ? 'bg-primary text-white'
                  : 'bg-[#2a2a2a] text-gray-400'
              )}>
                {index + 1}
              </span>
              <span className={cn(
                'text-sm truncate flex-1',
                lesson.id === currentLessonId ? 'text-white font-medium' : 'text-gray-300'
              )}>
                {lesson.title}
              </span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default function Lesson() {
  const { moduleId, lessonId } = useParams<{ moduleId: string; lessonId: string }>();
  const navigate = useNavigate();
  const { data: lesson, isLoading: lessonLoading } = useLesson(lessonId || '');
  const { data: lessons, isLoading: lessonsLoading } = useLessons(moduleId);
  const { data: modules } = useModules();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const currentModule = modules?.find(m => m.id === moduleId);
  const currentIndex = lessons?.findIndex(l => l.id === lessonId) ?? -1;
  const prevLesson = currentIndex > 0 ? lessons?.[currentIndex - 1] : null;
  const nextLesson = currentIndex < (lessons?.length ?? 0) - 1 ? lessons?.[currentIndex + 1] : null;

  if (lessonLoading || lessonsLoading) {
    return (
      <div className="min-h-screen bg-[#0a0a0a]">
        <div className="container max-w-4xl mx-auto px-4 py-6">
          <Skeleton className="h-8 w-32 mb-6 bg-[#1a1a1a]" />
          <Skeleton className="aspect-video w-full bg-[#1a1a1a] rounded-lg mb-6" />
          <Skeleton className="h-8 w-3/4 bg-[#1a1a1a] mb-4" />
          <Skeleton className="h-20 w-full bg-[#1a1a1a]" />
        </div>
      </div>
    );
  }

  if (!lesson) {
    return (
      <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-xl font-bold text-white mb-4">Aula não encontrada</h1>
          <Button onClick={() => navigate('/courses')} variant="outline">
            Voltar para Aulas
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      <div className="container max-w-4xl mx-auto px-4 py-6 pb-24">
        {/* Header */}
        <div className="flex items-center gap-3 mb-6">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate('/courses')}
            className="shrink-0"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="min-w-0">
            <p className="text-xs text-primary font-medium truncate">
              {currentModule?.title || 'Módulo'}
            </p>
            <h1 className="text-lg font-bold text-white truncate">{lesson.title}</h1>
          </div>
        </div>

        {/* Video Player */}
        {lesson.vturb_code ? (
          <VturbPlayer code={lesson.vturb_code} />
        ) : (
          <div className="w-full aspect-video bg-[#1a1a1a] rounded-lg flex items-center justify-center">
            <p className="text-gray-500">Vídeo não disponível</p>
          </div>
        )}

        {/* Lesson Info */}
        <div className="mt-6 space-y-4">
          <div className="flex items-center gap-4 text-sm text-gray-400">
            {lesson.duration_minutes > 0 && (
              <span className="flex items-center gap-1">
                <Clock className="w-4 h-4" />
                {lesson.duration_minutes} minutos
              </span>
            )}
          </div>

          {lesson.description && (
            <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a]">
              <h3 className="font-medium text-white mb-2">Descrição</h3>
              <p className="text-gray-400 text-sm whitespace-pre-wrap">{lesson.description}</p>
            </div>
          )}

          {/* External Links */}
          {lesson.external_links && lesson.external_links.length > 0 && (
            <div className="bg-[#1a1a1a] rounded-xl p-4 border border-[#2a2a2a]">
              <h3 className="font-medium text-white mb-3">Materiais</h3>
              <div className="space-y-2">
                {lesson.external_links.map((link, index) => (
                  <a
                    key={index}
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2 text-primary hover:underline text-sm"
                  >
                    <ExternalLink className="w-4 h-4" />
                    {link.title}
                  </a>
                ))}
              </div>
            </div>
          )}

          {/* Lesson Sidebar */}
          {lessons && lessons.length > 1 && (
            <LessonSidebar
              lessons={lessons}
              currentLessonId={lessonId || ''}
              moduleId={moduleId || ''}
              isOpen={sidebarOpen}
              onToggle={() => setSidebarOpen(!sidebarOpen)}
            />
          )}

          {/* Navigation */}
          <div className="flex items-center justify-between gap-4 pt-4">
            <Button
              variant="outline"
              onClick={() => prevLesson && navigate(`/courses/${moduleId}/${prevLesson.id}`)}
              disabled={!prevLesson}
              className="flex-1"
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Anterior
            </Button>
            <Button
              onClick={() => nextLesson && navigate(`/courses/${moduleId}/${nextLesson.id}`)}
              disabled={!nextLesson}
              className="flex-1"
            >
              Próxima
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
