import { useNavigate } from 'react-router-dom';
import { Play, Clock, Image as ImageIcon } from 'lucide-react';
import { useModulesWithLessons, Lesson, Module } from '@/hooks/useCourses';
import { useLessonProgress } from '@/hooks/useLessonProgress';
import { cn } from '@/lib/utils';

export function ContinueWatching() {
  const navigate = useNavigate();
  const { data: modules, isLoading } = useModulesWithLessons();
  const { completedLessons } = useLessonProgress();

  if (isLoading || !modules) return null;

  const incompleteLessons: { lesson: Lesson; module: Module }[] = [];
  modules.filter(m => m.is_published).forEach(module => {
    module.lessons?.filter(l => l.is_published && !l.is_locked && !completedLessons.includes(l.id)).forEach(lesson => {
      incompleteLessons.push({ lesson, module });
    });
  });

  const lessonsToShow = incompleteLessons.slice(0, 3);
  if (lessonsToShow.length === 0) return null;

  return (
    <div className="space-y-4 px-4 md:px-6">
      <div className="flex items-center gap-2"><Play className="w-5 h-5 text-primary" /><h2 className="text-xl font-bold text-foreground">Continue Assistindo</h2></div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {lessonsToShow.map(({ lesson, module }) => (
          <button key={lesson.id} onClick={() => navigate(`/lesson/${lesson.id}`)} className={cn("group relative bg-card border border-border rounded-xl overflow-hidden", "hover:border-primary/50 hover:shadow-lg hover:shadow-primary/10 transition-all text-left")}>
            <div className="relative aspect-video overflow-hidden">
              {lesson.cover_url ? <img src={lesson.cover_url} alt={lesson.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" /> : <div className="w-full h-full bg-gradient-to-br from-muted to-muted/50 flex items-center justify-center"><ImageIcon className="w-10 h-10 text-muted-foreground/50" /></div>}
              <div className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 group-hover:opacity-100 transition-opacity"><div className="p-3 rounded-full bg-primary"><Play className="w-6 h-6 text-primary-foreground" fill="currentColor" /></div></div>
              <div className="absolute bottom-2 right-2 flex items-center gap-1 px-2 py-1 rounded bg-black/70 text-white text-xs"><Clock className="w-3 h-3" />{lesson.duration_minutes || 0} min</div>
            </div>
            <div className="p-3"><p className="text-xs text-primary font-medium truncate">{module.title}</p><h3 className="font-medium text-foreground mt-1 line-clamp-2">{lesson.title}</h3></div>
          </button>
        ))}
      </div>
    </div>
  );
}
