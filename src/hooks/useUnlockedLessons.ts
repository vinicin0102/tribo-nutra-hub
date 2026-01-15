import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';

// Interface simplificada da aula para verificação de tempo
interface LessonForTimeCheck {
    id: string;
    is_locked?: boolean;
    unlock_after_days?: number;
    unlock_date?: string | null; // Data fixa de liberação
}

/**
 * Calcula quantos dias faltam para uma aula ser liberada
 * Agora usa unlock_date (data fixa definida pelo admin)
 * Retorna 0 se já está liberada, ou número de dias restantes
 */
export function getDaysUntilLessonUnlock(
    lesson: LessonForTimeCheck
): number {
    // Se aula não está bloqueada, já está liberada
    if (!lesson.is_locked) {
        return 0;
    }

    // Se tem data fixa de liberação (unlock_date), usar ela
    if (lesson.unlock_date) {
        const unlockDate = new Date(lesson.unlock_date);
        const now = new Date();
        const diffTime = unlockDate.getTime() - now.getTime();
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return diffDays > 0 ? diffDays : 0;
    }

    // Se não tem data de liberação definida, está bloqueada indefinidamente
    return -1;
}

/**
 * Verifica se uma aula está disponível considerando tempo
 */
export function isLessonAvailableByTime(
    lesson: LessonForTimeCheck,
    hasDiamondPlan: boolean
): boolean {
    // Se aula não está bloqueada, sempre disponível
    if (!lesson.is_locked) {
        return true;
    }

    // Se não tem plano Diamond, não está disponível
    if (!hasDiamondPlan) {
        return false;
    }

    // Verifica se já passou a data de liberação
    const daysRemaining = getDaysUntilLessonUnlock(lesson);
    return daysRemaining === 0;
}

export function useUnlockedLessons() {
    const { user } = useAuth();
    const { data: profile } = useProfile();

    // Dados do perfil para verificação
    const hasDiamondPlan = profile?.subscription_plan === 'diamond';

    /**
     * Verifica se uma aula está completamente disponível
     * Considera: bloqueio individual e data de liberação
     */
    const isLessonFullyAvailable = (lesson: LessonForTimeCheck): boolean => {
        // Se não está bloqueada
        if (!lesson.is_locked) {
            return true;
        }

        // Verifica disponibilidade por data
        return isLessonAvailableByTime(lesson, hasDiamondPlan);
    };

    /**
     * Retorna dias restantes para uma aula específica
     */
    const getLessonDaysRemaining = (lesson: LessonForTimeCheck): number => {
        if (!lesson.is_locked) {
            return 0;
        }
        if (!hasDiamondPlan) {
            return -1; // Bloqueada permanentemente (sem plano)
        }
        return getDaysUntilLessonUnlock(lesson);
    };

    /**
     * Retorna a data de liberação formatada
     */
    const getLessonUnlockDateFormatted = (lesson: LessonForTimeCheck): string | null => {
        if (!lesson.unlock_date) return null;
        const date = new Date(lesson.unlock_date);
        return date.toLocaleDateString('pt-BR');
    };

    return {
        isLessonFullyAvailable,
        getLessonDaysRemaining,
        getLessonUnlockDateFormatted,
        hasDiamondPlan,
    };
}
