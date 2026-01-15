import { X, ExternalLink } from 'lucide-react';
import { useAppPopup } from '@/hooks/useAppPopup';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { useEffect, useState } from 'react';

const AUTO_CLOSE_SECONDS = 5;

export function AppPopup() {
    const { popup, markAsViewed } = useAppPopup();
    const [timeLeft, setTimeLeft] = useState(AUTO_CLOSE_SECONDS);

    // Timer para auto-fechar após 5 segundos
    useEffect(() => {
        if (!popup) return;

        setTimeLeft(AUTO_CLOSE_SECONDS);

        const timer = setInterval(() => {
            setTimeLeft((prev) => {
                if (prev <= 1) {
                    clearInterval(timer);
                    markAsViewed(popup.id);
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        return () => clearInterval(timer);
    }, [popup?.id]);

    if (!popup) {
        return null;
    }

    const handleClose = () => {
        markAsViewed(popup.id);
    };

    const handleButtonClick = () => {
        if (popup.button_link) {
            // Abrir link em nova aba
            window.open(popup.button_link, '_blank', 'noopener,noreferrer');
        }
        handleClose();
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-in fade-in duration-300">
            <div className="relative w-full max-w-md bg-gradient-to-br from-[#1a1a1a] to-[#0f0f0f] rounded-2xl border border-[#2a2a2a] shadow-2xl overflow-hidden animate-in zoom-in-95 duration-300">
                {/* Botão de fechar */}
                <button
                    onClick={handleClose}
                    className="absolute top-3 right-3 z-10 p-2 rounded-full bg-black/50 hover:bg-black/70 transition-colors"
                >
                    <X className="h-5 w-5 text-white" />
                </button>

                {/* Imagem */}
                {popup.image_url && (
                    <div className="relative w-full aspect-video overflow-hidden">
                        <img
                            src={popup.image_url}
                            alt={popup.title}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                                // Esconder se imagem falhar
                                (e.target as HTMLImageElement).style.display = 'none';
                            }}
                        />
                        {/* Gradient overlay */}
                        <div className="absolute inset-0 bg-gradient-to-t from-[#1a1a1a] to-transparent" />
                    </div>
                )}

                {/* Conteúdo */}
                <div className={cn(
                    "p-6 space-y-4",
                    popup.image_url && "-mt-8 relative z-10"
                )}>
                    <h2 className="text-2xl font-bold text-white leading-tight">
                        {popup.title}
                    </h2>

                    {popup.message && (
                        <p className="text-gray-300 text-base leading-relaxed whitespace-pre-line">
                            {popup.message}
                        </p>
                    )}

                    <div className="flex flex-col gap-3 pt-2">
                        {/* Indicador de tempo restante */}
                        <div className="space-y-2">
                            <div className="flex items-center justify-between text-xs text-gray-400">
                                <span>Fechando automaticamente</span>
                                <span>{timeLeft}s</span>
                            </div>
                            <div className="w-full h-1 bg-gray-700 rounded-full overflow-hidden">
                                <div
                                    className="h-full bg-primary transition-all duration-1000 ease-linear"
                                    style={{ width: `${(timeLeft / AUTO_CLOSE_SECONDS) * 100}%` }}
                                />
                            </div>
                        </div>

                        {popup.button_text && popup.button_link && (
                            <Button
                                onClick={handleButtonClick}
                                className="w-full bg-primary hover:bg-primary/90 text-white font-semibold py-3 rounded-xl flex items-center justify-center gap-2"
                            >
                                {popup.button_text}
                                <ExternalLink className="h-4 w-4" />
                            </Button>
                        )}

                        <Button
                            onClick={handleClose}
                            variant="ghost"
                            className="w-full text-gray-400 hover:text-white hover:bg-white/10"
                        >
                            Fechar
                        </Button>
                    </div>
                </div>

                {/* Glow effect */}
                <div className="absolute -top-20 -right-20 w-40 h-40 bg-primary/20 rounded-full blur-3xl pointer-events-none" />
                <div className="absolute -bottom-20 -left-20 w-40 h-40 bg-primary/10 rounded-full blur-3xl pointer-events-none" />
            </div>
        </div>
    );
}
