import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Play, Clock, ChevronLeft, ChevronRight, Image as ImageIcon } from 'lucide-react';
import { useModulesWithLessons, Lesson, Module } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';

export function ContinueWatching() {
  const navigate = useNavigate();
  const scrollRef = useRef<HTMLDivElement>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const { data: modules, isLoading } = useModulesWithLessons();
  const { completedLessons } = useLessonProgress();

  if (isLoading || !modules) return null;

  const incompleteLessons: { lesson: Lesson; module: Module }[] = [];
  modules.filter(m => m.is_published).forEach(module => {
    module.lessons?.filter(l => l.is_published && !l.is_locked && !completedLessons.includes(l.id)).forEach(lesson => {
      incompleteLessons.push({ lesson, module });
    });
  });

  const lessonsToShow = incompleteLessons.slice(0, 5);
  if (lessonsToShow.length === 0) return null;

  const scroll = (direction: 'left' | 'right') => {
    if (!scrollRef.current) return;
    const cardWidth = window.innerWidth < 768 ? 300 : 380;
    const newIndex = direction === 'left' 
      ? Math.max(0, currentIndex - 1)
      : Math.min(lessonsToShow.length - 1, currentIndex + 1);
    setCurrentIndex(newIndex);
    scrollRef.current.scrollTo({ left: newIndex * cardWidth, behavior: 'smooth' });
  };

  // Calculate progress for each lesson (placeholder - 0% for incomplete)
  const getLessonProgress = () => 0;

  return (
    <div className="space-y-4">
      {/* Section title with orange bar */}
      <div className="flex items-center justify-between px-4 md:px-6">
        <div className="flex items-center gap-3">
          <div className="w-1 h-6 bg-primary rounded-full" />
          <h2 className="text-xl font-bold text-foreground">Continue Assistindo</h2>
        </div>
        
        {/* Navigation arrows */}
        <div className="flex gap-2">
          <button 
            onClick={() => scroll('left')} 
            className={cn(
              "w-10 h-10 rounded-lg flex items-center justify-center transition-all",
              currentIndex > 0 
                ? "bg-primary text-primary-foreground hover:bg-primary/90 cursor-pointer" 
                : "bg-muted text-muted-foreground cursor-not-allowed"
            )} 
            disabled={currentIndex === 0}
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button 
            onClick={() => scroll('right')} 
            className={cn(
              "w-10 h-10 rounded-lg flex items-center justify-center transition-all",
              currentIndex < lessonsToShow.length - 1 
                ? "bg-primary text-primary-foreground hover:bg-primary/90 cursor-pointer" 
                : "bg-muted text-muted-foreground cursor-not-allowed"
            )} 
            disabled={currentIndex >= lessonsToShow.length - 1}
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Horizontal carousel */}
      <div 
        ref={scrollRef}
        className="flex gap-4 overflow-x-auto pb-4 px-4 md:px-6 scrollbar-hide scroll-smooth"
      >
        {lessonsToShow.map(({ lesson, module }) => (
          <div 
            key={lesson.id} 
            className={cn(
              "flex-shrink-0 w-[280px] md:w-[360px] rounded-2xl overflow-hidden",
              "bg-card border border-border",
              "hover:border-primary/50 transition-all"
            )}
          >
            {/* Thumbnail */}
            <div className="relative aspect-video overflow-hidden">
              {lesson.cover_url ? (
                <img 
                  src={lesson.cover_url} 
                  alt={lesson.title} 
                  className="w-full h-full object-cover" 
                />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-muted to-muted/50 flex items-center justify-center">
                  <ImageIcon className="w-10 h-10 text-muted-foreground/50" />
                </div>
              )}
              
              {/* Duration badge */}
              <div className="absolute bottom-2 right-2 flex items-center gap-1 px-2 py-1 rounded bg-black/70 text-white text-xs">
                <Clock className="w-3 h-3" />
                {lesson.duration_minutes || 0} min
              </div>
            </div>
            
            {/* Content */}
            <div className="p-4 space-y-3">
              {/* Module name */}
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wide">
                {module.title}
              </p>
              
              {/* Module description */}
              {module.description && (
                <p className="text-sm text-muted-foreground line-clamp-1">
                  {module.description}
                </p>
              )}
              
              {/* Lesson title - orange/yellow */}
              <h3 className="font-bold text-primary line-clamp-2">
                {lesson.title}
              </h3>
              
              {/* Progress and Continue button */}
              <div className="flex items-center justify-between pt-2">
                <span className="text-sm font-bold text-muted-foreground">
                  {getLessonProgress()}%
                </span>
                
                <Button 
                  onClick={() => navigate(`/lesson/${lesson.id}`)}
                  size="sm"
                  className="gap-2"
                >
                  Continuar
                  <Play className="w-4 h-4" fill="currentColor" />
                </Button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
