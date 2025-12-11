import { useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Play, Clock, ChevronLeft, ChevronRight } from 'lucide-react';
import { useModulesWithLessons, Lesson, Module } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';

export function ContinueWatching() {
  const navigate = useNavigate();
  const scrollRef = useRef<HTMLDivElement>(null);
  const [currentIndex, setCurrentIndex] = useState(0);
  const { data: modules, isLoading } = useModulesWithLessons();
  const { completedLessons } = useLessonProgress();

  // Get watch progress from localStorage
  const getWatchProgress = (lessonId: string) => {
    try {
      const progress = localStorage.getItem(`lesson_progress_${lessonId}`);
      if (progress) {
        return JSON.parse(progress);
      }
    } catch (e) {
      console.error('Error reading progress:', e);
    }
    return null;
  };

  // Calculate progress percentage and time
  const getLessonProgress = (lesson: Lesson) => {
    const progress = getWatchProgress(lesson.id);
    if (!progress || !lesson.duration_minutes) {
      return { percentage: 0, currentMinutes: 0 };
    }
    
    const currentSeconds = progress.currentTime || 0;
    const totalSeconds = lesson.duration_minutes * 60;
    const percentage = totalSeconds > 0 ? Math.round((currentSeconds / totalSeconds) * 100) : 0;
    const currentMinutes = Math.floor(currentSeconds / 60);
    
    return { percentage, currentMinutes };
  };

  if (isLoading || !modules) return null;

  const incompleteLessons: { lesson: Lesson; module: Module; progress: { percentage: number; currentMinutes: number } }[] = [];
  modules.filter(m => m.is_published).forEach(module => {
    module.lessons?.filter(l => l.is_published && !l.is_locked && !completedLessons.includes(l.id)).forEach(lesson => {
      const progress = getLessonProgress(lesson);
      // Only show lessons with some progress
      if (progress.percentage > 0) {
        incompleteLessons.push({ lesson, module, progress });
      }
    });
  });

  // Sort by progress (most recent first)
  incompleteLessons.sort((a, b) => b.progress.percentage - a.progress.percentage);

  const lessonsToShow = incompleteLessons.slice(0, 5);
  if (lessonsToShow.length === 0) return null;

  const scroll = (direction: 'left' | 'right') => {
    if (!scrollRef.current) return;
    const cardWidth = window.innerWidth < 768 ? 280 : 360;
    const newIndex = direction === 'left' 
      ? Math.max(0, currentIndex - 1)
      : Math.min(lessonsToShow.length - 1, currentIndex + 1);
    setCurrentIndex(newIndex);
    scrollRef.current.scrollTo({ left: newIndex * cardWidth, behavior: 'smooth' });
  };

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
        {lessonsToShow.map(({ lesson, module, progress }) => (
          <div 
            key={lesson.id} 
            className={cn(
              "flex-shrink-0 w-[280px] md:w-[360px] rounded-2xl overflow-hidden",
              "bg-card border border-border",
              "hover:border-primary/50 transition-all"
            )}
          >
            {/* Content - no thumbnail */}
            <div className="p-4 space-y-3">
              {/* Module name */}
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wide">
                {module.title}
              </p>
              
              {/* Lesson title */}
              <h3 className="font-bold text-foreground line-clamp-2 text-base">
                {lesson.title}
              </h3>
              
              {/* Progress bar */}
              <div className="space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-muted-foreground">Progresso</span>
                  <span className="font-semibold text-foreground">{progress.percentage}%</span>
                </div>
                <Progress value={progress.percentage} className="h-2" />
              </div>
              
              {/* Time info and Continue button */}
              <div className="flex items-center justify-between pt-2">
                <div className="flex items-center gap-1 text-xs text-muted-foreground">
                  <Clock className="w-3 h-3" />
                  <span>
                    {progress.currentMinutes > 0 ? `${progress.currentMinutes} min` : '0 min'} / {lesson.duration_minutes || 0} min
                  </span>
                </div>
                
                <Button 
                  onClick={() => navigate(`/courses/${module.id}/${lesson.id}`)}
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
