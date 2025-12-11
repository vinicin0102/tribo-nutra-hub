import { useRef, useState } from 'react';
import { ChevronLeft, ChevronRight, Lock, CheckCircle, Play, Image as ImageIcon } from 'lucide-react';
import { Module, Lesson } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { cn } from '@/lib/utils';

interface ModuleCardProps {
  module: Module;
  index: number;
  progress: number;
  onClick: () => void;
}

function ModuleCard({ module, index, progress, onClick }: ModuleCardProps) {
  const isCompleted = progress === 100;
  const lessonCount = module.lessons?.filter(l => l.is_published)?.length || 0;
  
  return (
    <button
      onClick={onClick}
      className={cn(
        "flex-shrink-0 w-[280px] md:w-[320px] rounded-2xl overflow-hidden transition-all duration-300",
        "border border-border bg-card",
        "hover:border-primary/50 hover:shadow-lg hover:shadow-primary/10 cursor-pointer",
        isCompleted && "border-green-500/50"
      )}
    >
      <div className="relative h-36 md:h-40 overflow-hidden">
        {module.cover_url ? (
          <img src={module.cover_url} alt={module.title} className="w-full h-full object-cover" />
        ) : (
          <div className="w-full h-full bg-gradient-to-br from-primary/20 to-orange-500/10 flex items-center justify-center">
            <ImageIcon className="w-12 h-12 text-muted-foreground/50" />
          </div>
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
        <div className="absolute top-3 right-3">
          {isCompleted ? (
            <div className="p-2 rounded-full bg-green-500/80 backdrop-blur-sm">
              <CheckCircle className="w-4 h-4 text-white" />
            </div>
          ) : progress > 0 ? (
            <div className="p-2 rounded-full bg-primary/80 backdrop-blur-sm">
              <Play className="w-4 h-4 text-white" />
            </div>
          ) : null}
        </div>
        <div className="absolute top-3 left-3 px-3 py-1 rounded-full bg-black/60 backdrop-blur-sm">
          <span className="text-xs font-medium text-white">Módulo {index + 1}</span>
        </div>
      </div>
      <div className="p-4 space-y-3">
        <div>
          <h3 className="font-semibold text-foreground text-left line-clamp-1">{module.title}</h3>
          {module.description && (
            <p className="text-sm text-muted-foreground text-left line-clamp-2 mt-1">{module.description}</p>
          )}
        </div>
        <div className="space-y-1">
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">{lessonCount} aula(s)</span>
            <span className={cn("font-medium", isCompleted ? "text-green-500" : progress > 0 ? "text-primary" : "text-muted-foreground")}>
              {progress}%
            </span>
          </div>
          <div className="h-1.5 bg-muted rounded-full overflow-hidden">
            <div className={cn("h-full transition-all duration-500 rounded-full", isCompleted ? "bg-green-500" : "bg-primary")} style={{ width: `${progress}%` }} />
          </div>
        </div>
      </div>
    </button>
  );
}

interface ModuleCarouselProps {
  modules: Module[];
  onModuleSelect: (module: Module) => void;
}

export function ModuleCarousel({ modules, onModuleSelect }: ModuleCarouselProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [showLeftArrow, setShowLeftArrow] = useState(false);
  const [showRightArrow, setShowRightArrow] = useState(true);
  const { completedLessons } = useLessonProgress();
  const publishedModules = modules.filter(m => m.is_published);

  const handleScroll = () => {
    if (!scrollRef.current) return;
    const { scrollLeft, scrollWidth, clientWidth } = scrollRef.current;
    setShowLeftArrow(scrollLeft > 0);
    setShowRightArrow(scrollLeft < scrollWidth - clientWidth - 10);
  };

  const scroll = (direction: 'left' | 'right') => {
    if (!scrollRef.current) return;
    scrollRef.current.scrollBy({ left: direction === 'left' ? -340 : 340, behavior: 'smooth' });
  };

  const getModuleProgress = (module: Module) => {
    const lessons = module.lessons?.filter(l => l.is_published) || [];
    if (lessons.length === 0) return 0;
    const completed = lessons.filter(l => completedLessons.includes(l.id)).length;
    return Math.round((completed / lessons.length) * 100);
  };

  if (publishedModules.length === 0) return null;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between px-4 md:px-6">
        <h2 className="text-xl font-bold text-foreground">Módulos do Curso</h2>
        <div className="hidden md:flex gap-2">
          <button onClick={() => scroll('left')} className={cn("p-2 rounded-full border border-border bg-card transition-all", showLeftArrow ? "hover:bg-muted cursor-pointer" : "opacity-50 cursor-not-allowed")} disabled={!showLeftArrow}>
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button onClick={() => scroll('right')} className={cn("p-2 rounded-full border border-border bg-card transition-all", showRightArrow ? "hover:bg-muted cursor-pointer" : "opacity-50 cursor-not-allowed")} disabled={!showRightArrow}>
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
      <div ref={scrollRef} onScroll={handleScroll} className="flex gap-4 overflow-x-auto pb-4 px-4 md:px-6 scrollbar-hide">
        {publishedModules.map((module, index) => (
          <ModuleCard key={module.id} module={module} index={index} progress={getModuleProgress(module)} onClick={() => onModuleSelect(module)} />
        ))}
      </div>
    </div>
  );
}
