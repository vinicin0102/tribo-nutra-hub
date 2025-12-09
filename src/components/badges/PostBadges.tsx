import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { getMedalTypeByName } from './MedalIcon';
import { Medal, Award, Trophy, Crown, Star } from 'lucide-react';
import { cn } from '@/lib/utils';

interface Badge {
  badge_id: string;
  badges: {
    name: string;
    icon: string;
    points_required: number | null;
  };
}

interface PostBadgesProps {
  badges: Badge[];
  maxDisplay?: number;
}

const medalIcons = {
  beginner: Star,
  active: Medal,
  engaged: Award,
  influencer: Trophy,
  legend: Crown,
};

const medalColors = {
  beginner: 'text-green-500',
  active: 'text-blue-500',
  engaged: 'text-orange-500',
  influencer: 'text-purple-500',
  legend: 'text-yellow-500',
};

export function PostBadges({ badges, maxDisplay = 3 }: PostBadgesProps) {
  if (!badges || badges.length === 0) return null;

  // Sort by points_required descending to show highest achievements first
  const sortedBadges = [...badges].sort(
    (a, b) => (b.badges.points_required || 0) - (a.badges.points_required || 0)
  );

  const displayBadges = sortedBadges.slice(0, maxDisplay);
  const remainingCount = sortedBadges.length - maxDisplay;

  return (
    <TooltipProvider>
      <div className="flex items-center gap-0.5">
        {displayBadges.map((badge) => {
          const medalType = getMedalTypeByName(badge.badges.name);
          const Icon = medalIcons[medalType];
          const colorClass = medalColors[medalType];

          return (
            <Tooltip key={badge.badge_id}>
              <TooltipTrigger asChild>
                <div className="cursor-pointer">
                  <Icon className={cn('h-3.5 w-3.5', colorClass)} />
                </div>
              </TooltipTrigger>
              <TooltipContent side="top" className="text-xs">
                <p className="font-medium">{badge.badges.name}</p>
              </TooltipContent>
            </Tooltip>
          );
        })}
        {remainingCount > 0 && (
          <Tooltip>
            <TooltipTrigger asChild>
              <span className="text-[10px] text-muted-foreground ml-0.5 cursor-pointer">
                +{remainingCount}
              </span>
            </TooltipTrigger>
            <TooltipContent side="top" className="text-xs">
              <p>+{remainingCount} conquistas</p>
            </TooltipContent>
          </Tooltip>
        )}
      </div>
    </TooltipProvider>
  );
}
