import { useBadges, useUserBadges } from '@/hooks/useRanking';
import { useProfile } from '@/hooks/useProfile';
import { MedalIcon, getMedalTypeByName } from './MedalIcon';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Star, Info } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Progress } from '@/components/ui/progress';
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';

const getBadgeRequirement = (badgeName: string, pointsRequired: number) => {
  switch (badgeName) {
    case 'Iniciante':
      return {
        description: 'Seja bem-vindo à comunidade!',
        requirement: 'Cadastre-se na plataforma',
        tooltip: '🎉 Todos começam aqui! Bem-vindo à comunidade!'
      };
    case 'Ativo':
      return {
        description: `Alcance ${pointsRequired} pontos`,
        requirement: 'Participe ativamente da comunidade',
        tooltip: '💡 Dica: Faça login diário (+8 pts) e publique no feed (+5 pts)'
      };
    case 'Engajado':
      return {
        description: `Alcance ${pointsRequired} pontos`,
        requirement: 'Interaja com publicações e membros',
        tooltip: '💬 Dica: Curta e comente nas publicações dos colegas!'
      };
    case 'Influenciador':
      return {
        description: `Alcance ${pointsRequired} pontos`,
        requirement: 'Crie conteúdo e engaje a comunidade',
        tooltip: '✨ Dica: Crie conteúdo de qualidade que gere engajamento!'
      };
    case 'Lenda':
      return {
        description: `Alcance ${pointsRequired} pontos`,
        requirement: 'Torne-se uma referência na comunidade!',
        tooltip: '🏆 O objetivo final! Seja consistente e você chegará lá!'
      };
    default:
      return {
        description: `Alcance ${pointsRequired} pontos`,
        requirement: '',
        tooltip: ''
      };
  }
};

const getPointsProgress = (userPoints: number, badgePointsRequired: number) => {
  if (badgePointsRequired === 0) {
    return { current: userPoints, target: 0, percentage: 100 };
  }
  return {
    current: userPoints,
    target: badgePointsRequired,
    percentage: Math.min((userPoints / badgePointsRequired) * 100, 100)
  };
};

export function BadgesList() {
  const { data: badges, isLoading: badgesLoading } = useBadges();
  const { data: currentProfile } = useProfile();
  const { data: userBadges } = useUserBadges();
  
  const earnedBadgeIds = new Set(userBadges?.map(ub => ub.badge_id) || []);
  const userPoints = currentProfile?.points || 0;

  return (
    <TooltipProvider>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Star className="h-5 w-5 text-secondary" />
            Conquistas
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Info de como ganhar pontos */}
          <div className="bg-muted/50 rounded-lg p-3 text-xs space-y-1">
            <div className="flex items-center gap-1 font-medium text-foreground">
              <Info className="h-3.5 w-3.5" />
              Como ganhar pontos:
            </div>
            <div className="grid grid-cols-2 gap-x-4 gap-y-0.5 text-muted-foreground">
              <span>• Login diário: <span className="text-secondary font-medium">8 pts</span></span>
              <span>• Publicação: <span className="text-secondary font-medium">5 pts</span></span>
              <span>• Curtida: <span className="text-secondary font-medium">1 pt</span></span>
              <span>• Comentário: <span className="text-secondary font-medium">1 pt</span></span>
            </div>
            <div className="text-muted-foreground pt-1 border-t border-border/50 mt-1">
              📊 Limite diário: <span className="text-secondary font-medium">100 pontos</span>
            </div>
          </div>

          {/* Seus pontos atuais */}
          <div className="bg-secondary/10 rounded-lg p-3 text-center">
            <span className="text-sm text-muted-foreground">Seus pontos:</span>
            <span className="ml-2 text-lg font-bold text-secondary">{userPoints}</span>
          </div>

          {badgesLoading ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {[1, 2, 3, 4].map((i) => (
                <Skeleton key={i} className="h-40 rounded-lg" />
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {badges?.map((badge) => {
                const isEarned = earnedBadgeIds.has(badge.id);
                const medalType = getMedalTypeByName(badge.name);
                const badgeInfo = getBadgeRequirement(badge.name, badge.points_required || 0);
                const progress = getPointsProgress(userPoints, badge.points_required || 0);
                const pointsRemaining = Math.max(0, progress.target - progress.current);
                
                return (
                  <div
                    key={badge.id}
                    className={cn(
                      'rounded-lg border p-4 transition-all flex flex-col gap-3',
                      isEarned 
                        ? 'border-secondary/50 bg-secondary/5 shadow-lg ring-2 ring-secondary/20' 
                        : 'border-border bg-card'
                    )}
                  >
                    <div className="flex items-start gap-3">
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <div className="cursor-pointer">
                            <MedalIcon 
                              type={medalType} 
                              size={56}
                              className={cn(
                                'transition-all flex-shrink-0',
                                isEarned ? 'scale-110' : 'scale-100 opacity-60'
                              )}
                            />
                          </div>
                        </TooltipTrigger>
                        <TooltipContent side="top" className="max-w-[220px] text-center">
                          <p className="text-sm font-medium">{badge.name}</p>
                          {isEarned ? (
                            <p className="text-xs text-green-500 mt-1">✓ Você já conquistou!</p>
                          ) : (
                            <>
                              <p className="text-xs text-muted-foreground mt-1">
                                Faltam {pointsRemaining} pts
                              </p>
                              <p className="text-xs mt-1">{badgeInfo.tooltip}</p>
                            </>
                          )}
                        </TooltipContent>
                      </Tooltip>
                      <div className="flex-1 min-w-0">
                        <h3 className={cn(
                          "font-semibold text-base",
                          isEarned ? "text-secondary" : "text-foreground"
                        )}>
                          {badge.name}
                        </h3>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {badgeInfo.description}
                        </p>
                        {badgeInfo.requirement && (
                          <p className="text-[10px] text-muted-foreground/70 mt-1 italic">
                            {badgeInfo.requirement}
                          </p>
                        )}
                      </div>
                    </div>
                    
                    {isEarned ? (
                      <div className="text-center py-2 bg-green-500/10 rounded-md">
                        <p className="text-sm text-green-600 font-semibold">✓ Conquistada!</p>
                      </div>
                    ) : (
                      <div className="space-y-1.5">
                        <Progress value={progress.percentage} className="h-2" />
                        <div className="flex justify-between items-center text-[10px] text-muted-foreground">
                          <span>Progresso</span>
                          <span className="font-medium">
                            {progress.current}/{progress.target} pts
                          </span>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </TooltipProvider>
  );
}
