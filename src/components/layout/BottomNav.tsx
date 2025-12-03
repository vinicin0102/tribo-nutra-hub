import { Home, MessageCircle, Trophy, Gift, HelpCircle, Lock } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { cn } from '@/lib/utils';
import { useHasDiamondAccess } from '@/hooks/useSubscription';
import { useIsSupport } from '@/hooks/useSupport';

const navItems = [
  { icon: Home, label: 'Feed', path: '/', requiresDiamond: false },
  { icon: MessageCircle, label: 'Chat', path: '/chat', requiresDiamond: true },
  { icon: Trophy, label: 'Ranking', path: '/ranking', requiresDiamond: true },
  { icon: Gift, label: 'Premiação', path: '/rewards', requiresDiamond: true },
  { icon: HelpCircle, label: 'Suporte', path: '/support', requiresDiamond: false },
];

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const hasDiamondAccess = useHasDiamondAccess();
  const isSupport = useIsSupport();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-[#2a2a2a] bg-[#1a1a1a]/95 backdrop-blur-md">
      <div className="container flex h-16 items-center justify-around px-2">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          const Icon = item.icon;
          // Suporte sempre tem acesso total
          const isLocked = item.requiresDiamond && !hasDiamondAccess && !isSupport;

          return (
            <button
              key={item.path}
              onClick={() => navigate(isLocked ? '/upgrade' : item.path)}
              className={cn(
                'relative flex flex-col items-center justify-center gap-0.5 rounded-lg px-3 py-2 transition-all duration-200',
                isActive
                  ? 'text-primary'
                  : isLocked
                  ? 'text-gray-600 hover:text-gray-500'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <div className={cn(
                'relative rounded-full p-1.5 transition-all duration-200',
                isActive && 'bg-accent'
              )}>
                {isLocked ? (
                  <Lock className="h-5 w-5" />
                ) : (
                  <Icon className="h-5 w-5" />
                )}
              </div>
              <span className={cn(
                'text-[10px] font-medium transition-all duration-200',
                isActive && 'font-semibold'
              )}>
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
