import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip';
import { Badge } from '@/components/ui/badge';

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
      <div className="flex items-center gap-1 flex-wrap">
        {displayBadges.map((badge) => (
          <Tooltip key={badge.badge_id}>
            <TooltipTrigger asChild>
              <Badge 
                variant="secondary"
                className="text-[10px] px-1.5 py-0.5 flex items-center gap-1 cursor-pointer"
              >
                <span className="text-sm leading-none">{badge.badges.icon}</span>
                <span>{badge.badges.name}</span>
              </Badge>
            </TooltipTrigger>
            <TooltipContent side="top" className="text-xs">
              <p className="font-medium">{badge.badges.icon} {badge.badges.name}</p>
              {badge.badges.points_required && (
                <p className="text-muted-foreground text-[10px] mt-0.5">
                  {badge.badges.points_required} pontos necessários
                </p>
              )}
            </TooltipContent>
          </Tooltip>
        ))}
        {remainingCount > 0 && (
          <Tooltip>
            <TooltipTrigger asChild>
              <Badge 
                variant="outline" 
                className="text-[10px] px-1.5 py-0.5 cursor-pointer"
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
