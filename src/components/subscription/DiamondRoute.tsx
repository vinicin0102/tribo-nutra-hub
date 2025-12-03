import { ReactNode } from 'react';
import { Navigate } from 'react-router-dom';
import { useHasDiamondAccess } from '@/hooks/useSubscription';
import { useAuth } from '@/contexts/AuthContext';

interface DiamondRouteProps {
  children: ReactNode;
}

export function DiamondRoute({ children }: DiamondRouteProps) {
  const { user, loading } = useAuth();
  const hasDiamondAccess = useHasDiamondAccess();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#0a0a0a]">
        <div className="bg-primary rounded-2xl p-4 animate-pulse">
          <span className="text-4xl">💎</span>
        </div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/auth" replace />;
  }

  if (!hasDiamondAccess) {
    return <Navigate to="/upgrade" replace />;
  }

  return <>{children}</>;
}

