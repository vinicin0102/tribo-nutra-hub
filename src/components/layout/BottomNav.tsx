import { Home, MessageCircle, Trophy, Bell, HelpCircle } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';
import { cn } from '@/lib/utils';
import { useUnreadCount } from '@/hooks/useNotifications';

const navItems = [
  { icon: Home, label: 'Feed', path: '/' },
  { icon: MessageCircle, label: 'Chat', path: '/chat' },
  { icon: Trophy, label: 'Ranking', path: '/ranking' },
  { icon: Bell, label: 'Notificações', path: '/notifications', showBadge: true },
  { icon: HelpCircle, label: 'Suporte', path: '/support' },
];

export function BottomNav() {
  const location = useLocation();
  const navigate = useNavigate();
  const { data: unreadCount = 0 } = useUnreadCount();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-card/95 backdrop-blur-md">
      <div className="container flex h-16 items-center justify-around px-2">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          const Icon = item.icon;

          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={cn(
                'relative flex flex-col items-center justify-center gap-0.5 rounded-lg px-3 py-2 transition-all duration-200',
                isActive
                  ? 'text-primary'
                  : 'text-muted-foreground hover:text-foreground'
              )}
            >
              <div className={cn(
                'relative rounded-full p-1.5 transition-all duration-200',
                isActive && 'bg-accent'
              )}>
                <Icon className="h-5 w-5" />
                {item.showBadge && unreadCount > 0 && (
                  <span className="absolute -right-1 -top-1 flex h-4 w-4 items-center justify-center rounded-full bg-destructive text-[10px] font-bold text-destructive-foreground">
                    {unreadCount > 9 ? '9+' : unreadCount}
                  </span>
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
