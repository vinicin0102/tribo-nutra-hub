import { useBadges, useUserBadges } from '@/hooks/useRanking';
import { useProfile } from '@/hooks/useProfile';
import { MedalIcon, getMedalTypeByName } from './MedalIcon';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Star } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Progress } from '@/components/ui/progress';

const getBadgeProgress = (badgeName: string, profile: any) => {
  if (!profile) return { current: 0, target: 0, percentage: 0 };
  
  switch (badgeName) {
    case 'Influenciador':
      return {
        current: profile.posts_count || 0,
        target: 20,
        percentage: Math.min(((profile.posts_count || 0) / 20) * 100, 100)
      };
    case 'Ativo':
      return {
        current: profile.consecutive_days || 0,
        target: 7,
        percentage: Math.min(((profile.consecutive_days || 0) / 7) * 100, 100)
      };
    case 'Engajado':
      const likes = profile.likes_given_count || 0;
      const comments = profile.comments_given_count || 0;
      const minAction = Math.min(likes, comments);
      return {
        current: minAction,
        target: 7,
        percentage: Math.min((minAction / 7) * 100, 100),
        details: `Curtidas: ${likes}/7, Comentários: ${comments}/7`
      };
    case 'Lenda':
      const posts = profile.posts_count || 0;
      const likesLegend = profile.likes_given_count || 0;
      const commentsLegend = profile.comments_given_count || 0;
      const minLegend = Math.min(posts, likesLegend, commentsLegend);
      return {
        current: minLegend,
        target: 100,
        percentage: Math.min((minLegend / 100) * 100, 100),
        details: `Posts: ${posts}/100, Curtidas: ${likesLegend}/100, Comentários: ${commentsLegend}/100`
      };
    default:
      return { current: 0, target: 0, percentage: 0 };
  }
};

export function BadgesList() {
  const { data: badges, isLoading: badgesLoading } = useBadges();
  const { data: currentProfile } = useProfile();
  const { data: userBadges } = useUserBadges();
  
  const earnedBadgeIds = new Set(userBadges?.map(ub => ub.badge_id) || []);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Star className="h-5 w-5 text-secondary" />
          Conquistas
        </CardTitle>
      </CardHeader>
      <CardContent>
        {badgesLoading ? (
          <div className="grid grid-cols-2 gap-3">
            {[1, 2, 3, 4].map((i) => (
              <Skeleton key={i} className="h-32 rounded-lg" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-4">
            {badges?.map((badge) => {
              const isEarned = earnedBadgeIds.has(badge.id);
              const medalType = getMedalTypeByName(badge.name);
              const progress = getBadgeProgress(badge.name, currentProfile);
              
              return (
                <div
                  key={badge.id}
                  className={cn(
                    'rounded-lg border p-4 transition-all flex flex-col items-center gap-3',
                    isEarned 
                      ? 'border-secondary/50 bg-secondary/5' 
                      : 'border-border'
                  )}
                >
                  <MedalIcon 
                    type={medalType} 
                    size={48}
                    className={!isEarned ? 'opacity-50' : ''}
                  />
                  <div className="text-center w-full">
                    <p className="text-sm font-semibold mb-1">{badge.name}</p>
                    <p className="text-xs text-muted-foreground mb-2">{badge.description}</p>
                    {!isEarned && (
                      <div className="space-y-1">
                        <Progress value={progress.percentage} className="h-2" />
                        <p className="text-[10px] text-muted-foreground">
                          {progress.current}/{progress.target}
                        </p>
                        {progress.details && (
                          <p className="text-[9px] text-muted-foreground mt-1">
                            {progress.details}
                          </p>
                        )}
                      </div>
                    )}
                    {isEarned && (
                      <p className="text-xs text-green-500 font-semibold">✓ Conquistada!</p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

