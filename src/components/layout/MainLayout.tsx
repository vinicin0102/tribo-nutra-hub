import { ReactNode } from 'react';
import { Navbar } from './Navbar';
import { BottomNav } from './BottomNav';

interface MainLayoutProps {
  children: ReactNode;
}

export function MainLayout({ children }: MainLayoutProps) {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="container pb-20 pt-20">
        {children}
      </main>
      <BottomNav />
    </div>
  );
}
