import { ReactNode } from 'react';
import { useLocation } from 'react-router-dom';
import { Navbar } from './Navbar';
import { BottomNav } from './BottomNav';
import { AIButton } from '@/components/feed/AIButton';

interface MainLayoutProps {
  children: ReactNode;
}

export function MainLayout({ children }: MainLayoutProps) {
  const location = useLocation();
  
  // Páginas onde o botão de IA NÃO deve aparecer
  const hideAIButton = location.pathname === '/chat' || location.pathname === '/support';
  
  return (
    <div className="min-h-screen bg-[#0a0a0a]">
      <Navbar />
      <main className="container pb-20 pt-20 bg-[#0a0a0a]">
        {children}
      </main>
      <BottomNav />
      {!hideAIButton && (
        <AIButton
          onCopyAI={() => {
            // Aqui você pode adicionar a lógica da IA de Copy
          }}
          onCreativeAI={() => {
            // Aqui você pode adicionar a lógica da IA de Criativo
          }}
        />
      )}
    </div>
  );
}
