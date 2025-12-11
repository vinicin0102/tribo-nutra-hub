import { useNavigate } from 'react-router-dom';
import { Module, Lesson } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { BookOpen, Lock, Play, CheckCircle2, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useRef, useState } from 'react';

interface ModuleCardProps {
  module: Module & { lessons?: Lesson[] };
  progress: number;
  completedCount: number;
  totalLessons: number;
  isLocked?: boolean;
  onClick: () => void;
}

function ModuleCard({ module, progress, completedCount, totalLessons, isLocked, onClick }: ModuleCardProps) {
  return (
    <button
      onClick={onClick}
      disabled={isLocked}
      className={cn(
        "flex-shrink-0 w-[260px] sm:w-[280px] md:w-[300px] rounded-xl border overflow-hidden transition-all duration-300",
        isLocked 
          ? "bg-[#1a1a1a] border-[#2a2a2a] opacity-60 grayscale cursor-not-allowed"
          : "bg-gradient-to-br from-[#1a1a1a] to-[#222] border-[#2a2a2a] hover:border-primary/50 hover:shadow-lg hover:shadow-primary/10 cursor-pointer"
      )}
    >
      {/* Cover image / placeholder */}
      <div className="relative h-32 sm:h-36 md:h-40 bg-gradient-to-br from-primary/20 to-orange-500/10 flex items-center justify-center">
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
        
        {isLocked ? (
          <div className="relative z-10 w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-[#2a2a2a] flex items-center justify-center">
            <Lock className="w-5 h-5 sm:w-6 sm:h-6 text-gray-500" />
          </div>
        ) : progress === 100 ? (
          <div className="relative z-10 w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-green-500/20 flex items-center justify-center">
            <CheckCircle2 className="w-6 h-6 sm:w-7 sm:h-7 text-green-500" />
          </div>
        ) : (
          <div className="relative z-10 w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-primary/90 flex items-center justify-center shadow-lg">
            <Play className="w-5 h-5 sm:w-6 sm:h-6 text-white ml-0.5" />
          </div>
        )}
        
        {/* Module order badge */}
        <div className="absolute top-2 sm:top-3 left-2 sm:left-3 bg-black/60 rounded-lg px-2 py-1">
          <span className="text-xs text-white font-medium">Módulo {module.order_index + 1}</span>
        </div>
        
        {/* Progress badge */}
        {!isLocked && progress > 0 && (
          <div className="absolute top-2 sm:top-3 right-2 sm:right-3 bg-primary/90 rounded-lg px-2 py-1">
            <span className="text-xs text-white font-bold">{progress}%</span>
          </div>
        )}
      </div>
      
      {/* Content */}
      <div className="p-3 sm:p-4">
        <h3 className={cn(
          "font-bold text-sm sm:text-base line-clamp-2 mb-1 sm:mb-2 transition-colors",
          isLocked ? "text-gray-500" : "text-white"
        )}>
          {module.title}
        </h3>
        
        {module.description && (
          <p className="text-xs text-gray-400 line-clamp-2 mb-2 sm:mb-3">
            {module.description}
          </p>
        )}
        
        <div className="flex items-center justify-between text-xs">
          <span className={cn(
            "flex items-center gap-1",
            isLocked ? "text-gray-600" : "text-gray-400"
          )}>
            <BookOpen className="w-3.5 h-3.5" />
            {totalLessons} aula{totalLessons !== 1 ? 's' : ''}
          </span>
          
          {!isLocked && (
            <span className={cn(
              "font-medium",
              progress === 100 ? "text-green-500" : "text-primary"
            )}>
              {completedCount}/{totalLessons}
            </span>
          )}
        </div>
        
        {/* Progress bar */}
        {!isLocked && (
          <div className="mt-2 sm:mt-3 h-1.5 bg-[#2a2a2a] rounded-full overflow-hidden">
            <div 
              className={cn(
                "h-full rounded-full transition-all duration-300",
                progress === 100 ? "bg-green-500" : "bg-gradient-to-r from-primary to-orange-500"
              )}
              style={{ width: `${progress}%` }}
            />
          </div>
        )}
      </div>
    </button>
  );
}

interface ModuleCarouselProps {
  modules: (Module & { lessons?: Lesson[] })[];
  onModuleClick: (moduleId: string) => void;
}

export function ModuleCarousel({ modules, onModuleClick }: ModuleCarouselProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const { completedLessons } = useLessonProgress();
  const [showLeftArrow, setShowLeftArrow] = useState(false);
  const [showRightArrow, setShowRightArrow] = useState(true);

  const handleScroll = () => {
    if (!scrollRef.current) return;
    const { scrollLeft, scrollWidth, clientWidth } = scrollRef.current;
    setShowLeftArrow(scrollLeft > 10);
    setShowRightArrow(scrollLeft < scrollWidth - clientWidth - 10);
  };

  const scroll = (direction: 'left' | 'right') => {
    if (!scrollRef.current) return;
    const scrollAmount = 300;
    scrollRef.current.scrollBy({
      left: direction === 'left' ? -scrollAmount : scrollAmount,
      behavior: 'smooth'
    });
  };

  const publishedModules = modules.filter(m => m.is_published);

  if (publishedModules.length === 0) return null;

  return (
    <div className="space-y-3 sm:space-y-4">
      <div className="flex items-center justify-between px-1">
        <h2 className="text-base sm:text-lg font-bold text-white flex items-center gap-2">
          <BookOpen className="w-4 h-4 sm:w-5 sm:h-5 text-primary" />
          Módulos
        </h2>
        
        {/* Navigation arrows - only show on larger screens */}
        <div className="hidden sm:flex items-center gap-2">
          <button
            onClick={() => scroll('left')}
            className={cn(
              "p-2 rounded-lg transition-colors",
              showLeftArrow 
                ? "bg-[#2a2a2a] hover:bg-[#333] text-white" 
                : "bg-[#1a1a1a] text-gray-600 cursor-not-allowed"
            )}
            disabled={!showLeftArrow}
          >
            <ChevronRight className="w-4 h-4 rotate-180" />
          </button>
          <button
            onClick={() => scroll('right')}
            className={cn(
              "p-2 rounded-lg transition-colors",
              showRightArrow 
                ? "bg-[#2a2a2a] hover:bg-[#333] text-white" 
                : "bg-[#1a1a1a] text-gray-600 cursor-not-allowed"
            )}
            disabled={!showRightArrow}
          >
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
      
      {/* Carousel */}
      <div 
        ref={scrollRef}
        onScroll={handleScroll}
        className="flex gap-3 sm:gap-4 overflow-x-auto pb-4 scrollbar-hide scroll-smooth -mx-4 px-4"
        style={{ scrollSnapType: 'x mandatory' }}
      >
        {publishedModules.map((module) => {
          const lessons = module.lessons?.filter(l => l.is_published) || [];
          const totalLessons = lessons.length;
          const completedCount = lessons.filter(l => completedLessons.includes(l.id)).length;
          const progress = totalLessons > 0 ? Math.round((completedCount / totalLessons) * 100) : 0;
          
          return (
            <div key={module.id} style={{ scrollSnapAlign: 'start' }}>
              <ModuleCard
                module={module}
                progress={progress}
                completedCount={completedCount}
                totalLessons={totalLessons}
                onClick={() => onModuleClick(module.id)}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
