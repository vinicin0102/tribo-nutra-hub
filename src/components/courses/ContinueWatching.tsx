import { useNavigate } from 'react-router-dom';
import { useModulesWithLessons, Lesson, Module } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { Play, Clock, ArrowRight } from 'lucide-react';
import { cn } from '@/lib/utils';

interface LessonWithModule extends Lesson {
  module: Module;
}

export function ContinueWatching() {
  const navigate = useNavigate();
  const { data: modules } = useModulesWithLessons();
  const { completedLessons, isLoading } = useLessonProgress();

  if (isLoading || !modules) return null;

  // Encontrar aulas não concluídas em módulos publicados
  const allLessons: LessonWithModule[] = [];
  modules
    .filter(m => m.is_published)
    .forEach(module => {
      module.lessons
        ?.filter(l => l.is_published)
        .forEach(lesson => {
          allLessons.push({ ...lesson, module });
        });
    });

  // Filtrar apenas as não concluídas (primeiras 3)
  const incompleteLessons = allLessons
    .filter(l => !completedLessons.includes(l.id))
    .slice(0, 3);

  if (incompleteLessons.length === 0) return null;

  return (
    <div className="space-y-3 sm:space-y-4">
      <div className="flex items-center justify-between px-1">
        <h2 className="text-base sm:text-lg font-bold text-white flex items-center gap-2">
          <Play className="w-4 h-4 sm:w-5 sm:h-5 text-primary" />
          Continue Assistindo
        </h2>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
        {incompleteLessons.map((lesson) => (
          <button
            key={lesson.id}
            onClick={() => navigate(`/courses/${lesson.module.id}/${lesson.id}`)}
            className={cn(
              "group bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] overflow-hidden",
              "hover:border-primary/50 hover:bg-[#222] transition-all duration-300",
              "text-left"
            )}
          >
            {/* Thumbnail placeholder com gradient */}
            <div className="relative aspect-video bg-gradient-to-br from-[#252525] to-[#1a1a1a] flex items-center justify-center">
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
              <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-full bg-primary/90 flex items-center justify-center group-hover:scale-110 transition-transform shadow-lg">
                <Play className="w-5 h-5 sm:w-6 sm:h-6 text-white ml-1" />
              </div>
              
              {/* Duration badge */}
              {lesson.duration_minutes > 0 && (
                <div className="absolute bottom-2 right-2 bg-black/80 rounded px-2 py-0.5 flex items-center gap-1">
                  <Clock className="w-3 h-3 text-white" />
                  <span className="text-xs text-white">{lesson.duration_minutes} min</span>
                </div>
              )}
            </div>
            
            {/* Content */}
            <div className="p-3 sm:p-4">
              <p className="text-[10px] sm:text-xs text-primary font-medium truncate mb-1">
                {lesson.module.title}
              </p>
              <h3 className="font-semibold text-white text-sm sm:text-base line-clamp-2 group-hover:text-primary transition-colors">
                {lesson.title}
              </h3>
              
              <div className="flex items-center gap-1 mt-2 sm:mt-3 text-primary text-xs sm:text-sm font-medium">
                <span>Continuar</span>
                <ArrowRight className="w-3 h-3 sm:w-4 sm:h-4 group-hover:translate-x-1 transition-transform" />
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
