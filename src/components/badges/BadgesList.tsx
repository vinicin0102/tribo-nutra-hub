import { useBadges } from '@/hooks/useRanking';
import { useProfile } from '@/hooks/useProfile';
import { MedalIcon, getMedalTypeByName } from './MedalIcon';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Star } from 'lucide-react';
import { cn } from '@/lib/utils';

export function BadgesList() {
  const { data: badges, isLoading: badgesLoading } = useBadges();
  const { data: currentProfile } = useProfile();

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
          <div className="grid grid-cols-3 gap-3">
            {[1, 2, 3].map((i) => (
              <Skeleton key={i} className="h-24 rounded-lg" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-3 gap-3">
            {badges?.map((badge) => {
              const isEarned = currentProfile && (currentProfile.points || 0) >= badge.points_required;
              const medalType = getMedalTypeByName(badge.name);
              
              return (
                <div
                  key={badge.id}
                  className={cn(
                    'rounded-lg border p-3 text-center transition-all flex flex-col items-center gap-2',
                    isEarned 
                      ? 'border-secondary/50 bg-secondary/5' 
                      : 'border-border opacity-50'
                  )}
                >
                  <MedalIcon 
                    type={medalType} 
                    size={40}
                    className={!isEarned ? 'opacity-50' : ''}
                  />
                  <p className="text-xs font-semibold">{badge.name}</p>
                  <p className="text-[10px] text-muted-foreground">
                    {badge.points_required} pts
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

