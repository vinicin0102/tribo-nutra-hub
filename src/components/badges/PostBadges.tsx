import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { getMedalTypeByName } from './MedalIcon';
import { Medal, Award, Trophy, Crown, Star } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';

interface BadgeData {
  badge_id: string;
  badges: {
    name: string;
    icon: string;
    points_required: number | null;
  };
}

interface PostBadgesProps {
  badges: BadgeData[];
  maxDisplay?: number;
}

const medalIcons = {
  beginner: Star,
  active: Medal,
  engaged: Award,
  influencer: Trophy,
  legend: Crown,
};

const medalBadgeStyles = {
  beginner: 'bg-green-500/20 border-green-500/50 text-green-400',
  active: 'bg-blue-500/20 border-blue-500/50 text-blue-400',
  engaged: 'bg-orange-500/20 border-orange-500/50 text-orange-400',
  influencer: 'bg-purple-500/20 border-purple-500/50 text-purple-400',
  legend: 'bg-yellow-500/20 border-yellow-500/50 text-yellow-400',
};

export function PostBadges({ badges, maxDisplay = 3 }: PostBadgesProps) {
  if (!badges || badges.length === 0) {
    return null;
  }

  // Sort by points_required descending to show highest achievements first
  const sortedBadges = [...badges].sort(
    (a, b) => (b.badges.points_required || 0) - (a.badges.points_required || 0)
  );

  const displayBadges = sortedBadges.slice(0, maxDisplay);
  const remainingCount = sortedBadges.length - maxDisplay;

  return (
    <TooltipProvider>
      <div className="flex items-center gap-0.5 flex-wrap">
        {displayBadges.map((badge) => {
          const medalType = getMedalTypeByName(badge.badges.name);
          const Icon = medalIcons[medalType];
          const badgeStyle = medalBadgeStyles[medalType];

          return (
            <Tooltip key={badge.badge_id}>
              <TooltipTrigger asChild>
                <Badge 
                  className={cn(
                    "border text-[9px] px-1 py-0 flex items-center gap-0.5 cursor-pointer h-4",
                    badgeStyle
                  )}
                >
                  <Icon className="h-2.5 w-2.5" />
                  <span className="leading-none">{badge.badges.name}</span>
                </Badge>
              </TooltipTrigger>
              <TooltipContent side="top" className="text-xs">
                <p className="font-medium">{badge.badges.name}</p>
                {badge.badges.points_required && (
                  <p className="text-muted-foreground text-[10px] mt-0.5">
                    {badge.badges.points_required} pontos necessários
                  </p>
                )}
              </TooltipContent>
            </Tooltip>
          );
        })}
        {remainingCount > 0 && (
          <Tooltip>
            <TooltipTrigger asChild>
              <Badge 
                variant="outline" 
                className="text-[9px] px-1 py-0 h-4 cursor-pointer border-gray-600/50 text-gray-400 leading-none"
              >
                +{remainingCount}
              </Badge>
            </TooltipTrigger>
            <TooltipContent side="top" className="text-xs">
              <p>+{remainingCount} conquistas adicionais</p>
            </TooltipContent>
          </Tooltip>
        )}
      </div>
    </TooltipProvider>
  );
}
