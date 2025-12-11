import { useNavigate } from 'react-router-dom';
import { Module, Lesson } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { ArrowLeft, Play, Clock, CheckCircle2, Lock, ExternalLink } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface ModuleLessonsProps {
  module: Module & { lessons?: Lesson[] };
  onBack: () => void;
}

export function ModuleLessons({ module, onBack }: ModuleLessonsProps) {
  const navigate = useNavigate();
  const { completedLessons, isCompleted } = useLessonProgress();
  
  const lessons = module.lessons?.filter(l => l.is_published) || [];
  const completedCount = lessons.filter(l => completedLessons.includes(l.id)).length;
  const progress = lessons.length > 0 ? Math.round((completedCount / lessons.length) * 100) : 0;

  return (
    <div className="space-y-4 sm:space-y-6">
      {/* Header */}
      <div className="flex items-start gap-3 sm:gap-4">
        <Button
          variant="ghost"
          size="icon"
          onClick={onBack}
          className="shrink-0 mt-0.5"
        >
          <ArrowLeft className="w-5 h-5" />
        </Button>
        
        <div className="flex-1 min-w-0">
          <p className="text-xs text-primary font-medium mb-0.5 sm:mb-1">Módulo {module.order_index + 1}</p>
          <h1 className="text-xl sm:text-2xl font-bold text-white line-clamp-2">{module.title}</h1>
          {module.description && (
            <p className="text-sm text-gray-400 mt-1 sm:mt-2 line-clamp-2">{module.description}</p>
          )}
        </div>
      </div>
      
      {/* Progress card */}
      <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] p-3 sm:p-4">
        <div className="flex items-center justify-between mb-2 sm:mb-3">
          <span className="text-sm text-gray-400">Progresso do módulo</span>
          <span className={cn(
            "text-sm font-bold",
            progress === 100 ? "text-green-500" : "text-primary"
          )}>
            {progress}%
          </span>
        </div>
        
        <div className="h-2 bg-[#2a2a2a] rounded-full overflow-hidden">
          <div 
            className={cn(
              "h-full rounded-full transition-all duration-300",
              progress === 100 ? "bg-green-500" : "bg-gradient-to-r from-primary to-orange-500"
            )}
            style={{ width: `${progress}%` }}
          />
        </div>
        
        <p className="text-xs text-gray-500 mt-2">
          {completedCount} de {lessons.length} aulas concluídas
        </p>
      </div>
      
      {/* Lessons list */}
      <div className="space-y-2 sm:space-y-3">
        {lessons.length === 0 ? (
          <div className="text-center py-8 sm:py-12 bg-[#1a1a1a] rounded-xl border border-[#2a2a2a]">
            <Lock className="w-10 h-10 sm:w-12 sm:h-12 text-gray-600 mx-auto mb-3 sm:mb-4" />
            <h3 className="text-base sm:text-lg font-semibold text-white mb-2">Conteúdo em breve</h3>
            <p className="text-sm text-gray-400">As aulas deste módulo serão liberadas em breve</p>
          </div>
        ) : (
          lessons.map((lesson, index) => {
            const completed = isCompleted(lesson.id);
            
            return (
              <button
                key={lesson.id}
                onClick={() => navigate(`/courses/${module.id}/${lesson.id}`)}
                className={cn(
                  "w-full flex items-center gap-3 sm:gap-4 p-3 sm:p-4 rounded-xl border transition-all duration-200",
                  completed 
                    ? "bg-green-500/10 border-green-500/30 hover:bg-green-500/20"
                    : "bg-[#1a1a1a] border-[#2a2a2a] hover:border-primary/50 hover:bg-[#222]"
                )}
              >
                {/* Lesson number / status */}
                <div className={cn(
                  "w-10 h-10 sm:w-12 sm:h-12 rounded-full flex items-center justify-center shrink-0",
                  completed 
                    ? "bg-green-500/20" 
                    : "bg-[#2a2a2a]"
                )}>
                  {completed ? (
                    <CheckCircle2 className="w-5 h-5 sm:w-6 sm:h-6 text-green-500" />
                  ) : (
                    <span className="text-sm sm:text-base font-bold text-gray-400">{index + 1}</span>
                  )}
                </div>
                
                {/* Content */}
                <div className="flex-1 min-w-0 text-left">
                  <h3 className={cn(
                    "font-medium text-sm sm:text-base line-clamp-1",
                    completed ? "text-green-400" : "text-white"
                  )}>
                    {lesson.title}
                  </h3>
                  
                  <div className="flex items-center gap-2 sm:gap-3 mt-0.5 sm:mt-1">
                    {lesson.duration_minutes > 0 && (
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {lesson.duration_minutes} min
                      </span>
                    )}
                    {lesson.external_links && lesson.external_links.length > 0 && (
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <ExternalLink className="w-3 h-3" />
                        {lesson.external_links.length} material{lesson.external_links.length !== 1 ? 'is' : ''}
                      </span>
                    )}
                  </div>
                </div>
                
                {/* Play button */}
                <div className={cn(
                  "w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center shrink-0",
                  completed 
                    ? "bg-green-500/20"
                    : "bg-primary/20"
                )}>
                  <Play className={cn(
                    "w-4 h-4 sm:w-5 sm:h-5 ml-0.5",
                    completed ? "text-green-500" : "text-primary"
                  )} />
                </div>
              </button>
            );
          })
        )}
      </div>
    </div>
  );
}
