import { useState, useEffect } from 'react';
import { Bell, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useOneSignal } from '@/hooks/useOneSignal';

export function PushPromptPortugues() {
    const { isSupported, isSubscribed, isInitialized, subscribe } = useOneSignal();
    const [showPrompt, setShowPrompt] = useState(false);
    const [dismissed, setDismissed] = useState(false);

    useEffect(() => {
        // Verificar se o usuário já viu o prompt
        const hasSeenPrompt = localStorage.getItem('push_prompt_dismissed');
        const hasSeenThisSession = sessionStorage.getItem('push_prompt_shown');

        if (hasSeenPrompt || hasSeenThisSession) {
            setDismissed(true);
            return;
        }

        // Mostrar o prompt após 3 segundos se OneSignal estiver disponível
        // e o usuário ainda não estiver inscrito
        const timer = setTimeout(() => {
            if (isInitialized && isSupported && !isSubscribed) {
                setShowPrompt(true);
                sessionStorage.setItem('push_prompt_shown', 'true');
            }
        }, 3000);

        return () => clearTimeout(timer);
    }, [isInitialized, isSupported, isSubscribed]);

    const handleAccept = async () => {
        setShowPrompt(false);
        await subscribe();
    };

    const handleDismiss = () => {
        setShowPrompt(false);
        setDismissed(true);
        localStorage.setItem('push_prompt_dismissed', 'true');
    };

    const handleLater = () => {
        setShowPrompt(false);
        // Não salva no localStorage para mostrar novamente na próxima sessão
    };

    if (!showPrompt || dismissed || isSubscribed || !isSupported) {
        return null;
    }

    return (
        <div className="fixed inset-0 z-[200] flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-in fade-in duration-300">
            <div className="relative w-full max-w-sm bg-gradient-to-br from-[#1a1a1a] to-[#0f0f0f] rounded-2xl border border-[#2a2a2a] shadow-2xl overflow-hidden animate-in zoom-in-95 duration-300">
                {/* Botão de fechar */}
                <button
                    onClick={handleDismiss}
                    className="absolute top-3 right-3 z-10 p-2 rounded-full bg-black/50 hover:bg-black/70 transition-colors"
                    aria-label="Fechar"
                >
                    <X className="h-4 w-4 text-gray-400" />
                </button>

                {/* Ícone */}
                <div className="flex justify-center pt-8">
                    <div className="p-4 rounded-full bg-primary/20 ring-4 ring-primary/10">
                        <Bell className="h-10 w-10 text-primary animate-pulse" />
                    </div>
                </div>

                {/* Conteúdo */}
                <div className="p-6 pt-4 text-center space-y-4">
                    <h2 className="text-xl font-bold text-white">
                        Ativar Notificações?
                    </h2>

                    <p className="text-gray-300 text-sm leading-relaxed">
                        Receba avisos importantes sobre <span className="text-primary font-medium">novos conteúdos</span>,
                        <span className="text-primary font-medium"> promoções exclusivas</span> e
                        <span className="text-primary font-medium"> atualizações</span> diretamente no seu dispositivo!
                    </p>

                    <div className="flex flex-col gap-2 pt-2">
                        <Button
                            onClick={handleAccept}
                            className="w-full bg-primary hover:bg-primary/90 text-white font-semibold py-3 rounded-xl"
                        >
                            Sim, quero receber!
                        </Button>

                        <Button
                            onClick={handleLater}
                            variant="ghost"
                            className="w-full text-gray-400 hover:text-white hover:bg-white/10"
                        >
                            Agora não
                        </Button>
                    </div>

                    <p className="text-xs text-gray-500">
                        Você pode alterar isso depois nas configurações do perfil
                    </p>
                </div>

                {/* Glow effect */}
                <div className="absolute -top-20 -right-20 w-40 h-40 bg-primary/20 rounded-full blur-3xl pointer-events-none" />
                <div className="absolute -bottom-20 -left-20 w-40 h-40 bg-primary/10 rounded-full blur-3xl pointer-events-none" />
            </div>
        </div>
    );
}
