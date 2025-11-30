import { Trophy, Medal, Crown, Star } from 'lucide-react';
import { MainLayout } from '@/components/layout/MainLayout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { useRanking, useBadges } from '@/hooks/useRanking';
import { useProfile } from '@/hooks/useProfile';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';

const getRankIcon = (rank: number) => {
  switch (rank) {
    case 1:
      return <Crown className="h-5 w-5 text-yellow-500" />;
    case 2:
      return <Medal className="h-5 w-5 text-gray-400" />;
    case 3:
      return <Medal className="h-5 w-5 text-amber-600" />;
    default:
      return <span className="text-sm font-bold text-muted-foreground">{rank}º</span>;
  }
};

const getRankBg = (rank: number) => {
  switch (rank) {
    case 1:
      return 'bg-gradient-to-r from-yellow-500/10 to-yellow-500/5 border-yellow-500/20';
    case 2:
      return 'bg-gradient-to-r from-gray-400/10 to-gray-400/5 border-gray-400/20';
    case 3:
      return 'bg-gradient-to-r from-amber-600/10 to-amber-600/5 border-amber-600/20';
    default:
      return '';
  }
};

export default function Ranking() {
  const { data: ranking, isLoading: rankingLoading } = useRanking();
  const { data: badges, isLoading: badgesLoading } = useBadges();
  const { data: currentProfile } = useProfile();

  const currentUserRank = ranking?.find(r => r.user_id === currentProfile?.user_id);

  return (
    <MainLayout>
      <div className="max-w-2xl mx-auto space-y-6">
        {/* User Stats */}
        {currentProfile && (
          <Card className="overflow-hidden">
            <div className="gradient-primary p-4">
              <div className="flex items-center gap-4">
                <Avatar className="h-16 w-16 border-4 border-primary-foreground/20">
                  <AvatarImage src={currentProfile.avatar_url || ''} />
                  <AvatarFallback className="bg-primary-foreground/20 text-primary-foreground text-xl font-bold">
                    {currentProfile.username?.charAt(0).toUpperCase() || 'U'}
                  </AvatarFallback>
                </Avatar>
                <div className="text-primary-foreground">
                  <h2 className="font-display text-xl font-bold">{currentProfile.username}</h2>
                  <p className="text-primary-foreground/80">
                    {currentUserRank ? `${currentUserRank.rank}º lugar` : 'Sem ranking'}
                  </p>
                </div>
                <div className="ml-auto text-right">
                  <p className="text-3xl font-display font-bold text-primary-foreground">
                    {currentProfile.points}
                  </p>
                  <p className="text-sm text-primary-foreground/80">pontos</p>
                </div>
              </div>
            </div>
          </Card>
        )}

        {/* Badges */}
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
                  const isEarned = currentProfile && currentProfile.points >= badge.points_required;
                  
                  return (
                    <div
                      key={badge.id}
                      className={cn(
                        'rounded-lg border p-3 text-center transition-all',
                        isEarned 
                          ? 'border-secondary/50 bg-secondary/5' 
                          : 'border-border opacity-50'
                      )}
                    >
                      <span className="text-2xl">{badge.icon}</span>
                      <p className="text-xs font-semibold mt-1">{badge.name}</p>
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

        {/* Ranking List */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-primary" />
              Ranking Global
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {rankingLoading ? (
              <div className="space-y-2 p-4">
                {[1, 2, 3, 4, 5].map((i) => (
                  <Skeleton key={i} className="h-16 w-full rounded-lg" />
                ))}
              </div>
            ) : ranking && ranking.length > 0 ? (
              <div className="divide-y divide-border">
                {ranking.map((user) => (
                  <div
                    key={user.id}
                    className={cn(
                      'flex items-center gap-3 p-4 transition-colors hover:bg-muted/50',
                      user.user_id === currentProfile?.user_id && 'bg-accent/50',
                      getRankBg(user.rank)
                    )}
                  >
                    <div className="w-8 flex items-center justify-center">
                      {getRankIcon(user.rank)}
                    </div>
                    <Avatar className="h-10 w-10">
                      <AvatarImage src={user.avatar_url || ''} />
                      <AvatarFallback className="gradient-primary text-primary-foreground text-sm font-semibold">
                        {user.username?.charAt(0).toUpperCase() || 'U'}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1">
                      <p className="font-semibold text-sm">
                        {user.username}
                        {user.user_id === currentProfile?.user_id && (
                          <span className="ml-2 text-xs text-primary">(você)</span>
                        )}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {user.full_name || 'Membro da Tribo'}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-display font-bold text-primary">{user.points}</p>
                      <p className="text-xs text-muted-foreground">pontos</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12">
                <Trophy className="h-12 w-12 text-muted-foreground mx-auto mb-3" />
                <p className="text-muted-foreground">
                  Nenhum ranking disponível
                </p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
}
