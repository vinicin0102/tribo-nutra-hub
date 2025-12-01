import { useState } from 'react';
import { FileText, Palette } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { CopyAIDialog } from '@/components/ai/CopyAIDialog';
import { CreativeAIDialog } from '@/components/ai/CreativeAIDialog';
import { toast } from 'sonner';

// Ícone de estrela rosa/roxo
const StarIcon = ({ className }: { className?: string }) => (
  <svg
    viewBox="0 0 24 24"
    fill="currentColor"
    className={className}
    xmlns="http://www.w3.org/2000/svg"
  >
    <path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z" />
  </svg>
);

interface AIButtonProps {
  onCopyAI?: () => void;
  onCreativeAI?: () => void;
}

export function AIButton({ onCopyAI, onCreativeAI }: AIButtonProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [isCopyAIOpen, setIsCopyAIOpen] = useState(false);
  const [isCreativeAIOpen, setIsCreativeAIOpen] = useState(false);

  const handleCopyAI = () => {
    setIsOpen(false);
    setIsCopyAIOpen(true);
    if (onCopyAI) {
      onCopyAI();
    }
  };

  const handleCreativeAI = () => {
    setIsOpen(false);
    setIsCreativeAIOpen(true);
    if (onCreativeAI) {
      onCreativeAI();
    }
  };

  return (
    <>
      <div className="fixed bottom-24 right-4 z-40">
        <DropdownMenu open={isOpen} onOpenChange={setIsOpen}>
          <DropdownMenuTrigger asChild>
            <Button
              size="icon"
              className="h-14 w-14 rounded-full bg-primary hover:bg-primary/90 shadow-lg hover:shadow-xl transition-all duration-200 hover:scale-105 active:scale-95"
            >
              <div className="relative flex items-center justify-center">
                <StarIcon className="h-6 w-6 fill-white text-white" />
                <div className="absolute -top-0.5 -right-0.5 h-1.5 w-1.5 bg-white rounded-full" />
              </div>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" side="top" className="w-48 mb-3">
            <DropdownMenuItem
              onClick={handleCopyAI}
              className="cursor-pointer focus:bg-primary/10"
            >
              <FileText className="mr-2 h-4 w-4 text-primary" />
              <span>IA de Copy</span>
            </DropdownMenuItem>
            <DropdownMenuItem
              onClick={handleCreativeAI}
              className="cursor-pointer focus:bg-primary/10"
            >
              <Palette className="mr-2 h-4 w-4 text-primary" />
              <span>IA de Criativo</span>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
      <CopyAIDialog open={isCopyAIOpen} onOpenChange={setIsCopyAIOpen} />
      <CreativeAIDialog open={isCreativeAIOpen} onOpenChange={setIsCreativeAIOpen} />
    </>
  );
}

