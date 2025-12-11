import { useState } from 'react';
import { MainLayout } from '@/components/layout/MainLayout';
import { useModulesWithLessons } from '@/hooks/useCourses';
import { HeroBanner } from '@/components/courses/HeroBanner';
import { ContinueWatching } from '@/components/courses/ContinueWatching';
import { ModuleCarousel } from '@/components/courses/ModuleCarousel';
import { ModuleLessons } from '@/components/courses/ModuleLessons';
import { Skeleton } from '@/components/ui/skeleton';
import { Lock } from 'lucide-react';

export default function Courses() {
  const { data: modules, isLoading } = useModulesWithLessons();
  const [selectedModuleId, setSelectedModuleId] = useState<string | null>(null);

  const publishedModules = modules?.filter(m => m.is_published) || [];
  const selectedModule = selectedModuleId 
    ? publishedModules.find(m => m.id === selectedModuleId) 
    : null;

  return (
    <MainLayout>
      <div className="min-h-screen bg-[#0a0a0a]">
        <div className="container max-w-5xl mx-auto px-4 py-4 sm:py-6 pb-24">
          {isLoading ? (
            <div className="space-y-4 sm:space-y-6">
              <Skeleton className="h-32 sm:h-40 w-full bg-[#1a1a1a] rounded-2xl" />
              <Skeleton className="h-48 sm:h-64 w-full bg-[#1a1a1a] rounded-xl" />
              <div className="flex gap-3 sm:gap-4 overflow-hidden">
                {[1, 2, 3].map(i => (
                  <Skeleton key={i} className="h-56 sm:h-64 w-64 sm:w-72 shrink-0 bg-[#1a1a1a] rounded-xl" />
                ))}
              </div>
            </div>
          ) : selectedModule ? (
            // Module detail view
            <ModuleLessons 
              module={selectedModule}
              onBack={() => setSelectedModuleId(null)}
            />
          ) : publishedModules.length === 0 ? (
            // Empty state
            <div className="text-center py-16 sm:py-20">
              <div className="w-16 h-16 sm:w-20 sm:h-20 bg-[#1a1a1a] rounded-2xl flex items-center justify-center mx-auto mb-4 sm:mb-6">
                <Lock className="w-8 h-8 sm:w-10 sm:h-10 text-gray-600" />
              </div>
              <h1 className="text-xl sm:text-2xl font-bold text-white mb-2 sm:mb-3">Conteúdo em breve</h1>
              <p className="text-sm sm:text-base text-gray-400 max-w-md mx-auto">
                Novos módulos e aulas estão sendo preparados especialmente para você. Fique atento!
              </p>
            </div>
          ) : (
            // Main courses view
            <div className="space-y-6 sm:space-y-8">
              {/* Hero Banner */}
              <HeroBanner />
              
              {/* Continue Watching */}
              <ContinueWatching />
              
              {/* Modules Carousel */}
              <ModuleCarousel 
                modules={publishedModules}
                onModuleClick={(moduleId) => setSelectedModuleId(moduleId)}
              />
            </div>
          )}
        </div>
      </div>
    </MainLayout>
  );
}
