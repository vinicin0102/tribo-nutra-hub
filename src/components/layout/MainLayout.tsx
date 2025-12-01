import { ReactNode } from 'react';
import { Navbar } from './Navbar';
import { BottomNav } from './BottomNav';
import { AIButton } from '@/components/feed/AIButton';

interface MainLayoutProps {
  children: ReactNode;
}

export function MainLayout({ children }: MainLayoutProps) {
  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      <Navbar />
      <main className="container pb-20 pt-20 bg-[#0a0a0a]">
        {children}
      </main>
      <BottomNav />
      <AIButton
        onCopyAI={() => {
          // Aqui você pode adicionar a lógica da IA de Copy
        }}
        onCreativeAI={() => {
          // Aqui você pode adicionar a lógica da IA de Criativo
        }}
      />
    </div>
  );
}
