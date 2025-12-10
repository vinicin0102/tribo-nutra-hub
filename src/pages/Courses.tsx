import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { MainLayout } from '@/components/layout/MainLayout';
import { useModulesWithLessons, Module, Lesson } from '@/hooks/useCourses';
import { ChevronDown, ChevronRight, Play, Clock, BookOpen, Lock } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Skeleton } from '@/components/ui/skeleton';

function ModuleAccordion({ module, isOpen, onToggle }: { 
  module: Module & { lessons?: Lesson[] }; 
  isOpen: boolean; 
  onToggle: () => void;
}) {
  const navigate = useNavigate();
  const lessons = module.lessons || [];
  const totalDuration = lessons.reduce((acc, l) => acc + (l.duration_minutes || 0), 0);

  return (
    <div className="bg-[#1a1a1a] rounded-xl border border-[#2a2a2a] overflow-hidden">
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-[#222] transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg bg-primary/20 flex items-center justify-center">
            <BookOpen className="w-5 h-5 text-primary" />
          </div>
          <div className="text-left">
            <h3 className="font-semibold text-white">{module.title}</h3>
            <div className="flex items-center gap-3 text-xs text-gray-400 mt-0.5">
              <span>{lessons.length} aula{lessons.length !== 1 ? 's' : ''}</span>
              {totalDuration > 0 && (
                <>
                  <span>•</span>
                  <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3" />
                    {totalDuration} min
                  </span>
                </>
              )}
            </div>
          </div>
        </div>
        {isOpen ? (
          <ChevronDown className="w-5 h-5 text-gray-400" />
        ) : (
          <ChevronRight className="w-5 h-5 text-gray-400" />
        )}
      </button>

      {isOpen && (
        <div className="border-t border-[#2a2a2a]">
          {lessons.length === 0 ? (
            <div className="p-4 text-center text-gray-500 text-sm">
              Nenhuma aula disponível neste módulo
            </div>
          ) : (
            <div className="divide-y divide-[#2a2a2a]">
              {lessons.map((lesson, index) => (
                <button
                  key={lesson.id}
                  onClick={() => navigate(`/courses/${module.id}/${lesson.id}`)}
                  className="w-full flex items-center gap-3 p-4 hover:bg-[#222] transition-colors text-left"
                >
                  <div className="w-8 h-8 rounded-full bg-[#2a2a2a] flex items-center justify-center text-xs font-medium text-gray-400">
                    {index + 1}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-medium text-white truncate">{lesson.title}</h4>
                    {lesson.description && (
                      <p className="text-xs text-gray-400 truncate mt-0.5">{lesson.description}</p>
                    )}
                  </div>
                  <div className="flex items-center gap-2">
                    {lesson.duration_minutes > 0 && (
                      <span className="text-xs text-gray-500 flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {lesson.duration_minutes} min
                      </span>
                    )}
                    <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center">
                      <Play className="w-4 h-4 text-primary" />
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default function Courses() {
  const { data: modules, isLoading } = useModulesWithLessons();
  const [openModules, setOpenModules] = useState<Set<string>>(new Set());

  const toggleModule = (moduleId: string) => {
    setOpenModules(prev => {
      const next = new Set(prev);
      if (next.has(moduleId)) {
        next.delete(moduleId);
      } else {
        next.add(moduleId);
      }
      return next;
    });
  };

  const publishedModules = modules?.filter(m => m.is_published) || [];

  return (
    <MainLayout>
      <div className="container max-w-2xl mx-auto px-4 py-6 pb-24">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <span className="text-3xl">📚</span>
            Área de Membros
          </h1>
          <p className="text-gray-400 text-sm mt-1">
            Acesse todas as aulas e materiais exclusivos
          </p>
        </div>

        {isLoading ? (
          <div className="space-y-4">
            {[1, 2, 3].map(i => (
              <Skeleton key={i} className="h-20 w-full bg-[#1a1a1a]" />
            ))}
          </div>
        ) : publishedModules.length === 0 ? (
          <div className="text-center py-12 bg-[#1a1a1a] rounded-xl border border-[#2a2a2a]">
            <Lock className="w-12 h-12 text-gray-600 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">Conteúdo em breve</h3>
            <p className="text-gray-400 text-sm">
              Novos módulos e aulas estão sendo preparados para você
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {publishedModules.map(module => (
              <ModuleAccordion
                key={module.id}
                module={module}
                isOpen={openModules.has(module.id)}
                onToggle={() => toggleModule(module.id)}
              />
            ))}
          </div>
        )}
      </div>
    </MainLayout>
  );
}
