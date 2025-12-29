import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';

// Interface simplificada da aula para verificação de tempo
interface LessonForTimeCheck {
    id: string;
    is_locked?: boolean;
    unlock_after_days?: number;
}

/**
 * Calcula quantos dias faltam para uma aula ser liberada
 * Retorna 0 se já está liberada, ou número de dias restantes
 */
export function getDaysUntilLessonUnlock(
    lesson: LessonForTimeCheck,
    subscriptionStartDate: string | null | undefined
): number {
    // Se aula não está bloqueada ou não tem dias configurados, já está liberada
    if (!lesson.is_locked || !lesson.unlock_after_days || lesson.unlock_after_days === 0) {
        return 0;
    }

    // Se não tem data de início de assinatura, está bloqueada indefinidamente
    if (!subscriptionStartDate) {
        return -1; // -1 indica bloqueada permanentemente
    }

    const startDate = new Date(subscriptionStartDate);
    const unlockDate = new Date(startDate);
    unlockDate.setDate(unlockDate.getDate() + lesson.unlock_after_days);

    const now = new Date();
    const diffTime = unlockDate.getTime() - now.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    return diffDays > 0 ? diffDays : 0;
}

/**
 * Verifica se uma aula está disponível considerando tempo
 */
export function isLessonAvailableByTime(
    lesson: LessonForTimeCheck,
    subscriptionStartDate: string | null | undefined,
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

    // Verifica se já passou tempo suficiente
    const daysRemaining = getDaysUntilLessonUnlock(lesson, subscriptionStartDate);
    return daysRemaining === 0;
}

export function useUnlockedLessons() {
    const { user } = useAuth();
    const { data: profile } = useProfile();

    // Dados do perfil para verificação de tempo
    const hasDiamondPlan = profile?.subscription_plan === 'diamond';
    // Usamos first_login_at como data base para liberação das aulas
    // first_login_at é definido no primeiro login do usuário e nunca muda
    // Fallback para created_at caso first_login_at não exista ainda
    const subscriptionStartDate = profile?.first_login_at || profile?.created_at;

    /**
     * Verifica se uma aula está completamente disponível
     * Considera: bloqueio individual e tempo de liberação
     */
    const isLessonFullyAvailable = (lesson: LessonForTimeCheck): boolean => {
        // Se não está bloqueada
        if (!lesson.is_locked) {
            return true;
        }

        // Verifica disponibilidade por tempo
        return isLessonAvailableByTime(lesson, subscriptionStartDate, hasDiamondPlan);
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
        return getDaysUntilLessonUnlock(lesson, subscriptionStartDate);
    };

    return {
        isLessonFullyAvailable,
        getLessonDaysRemaining,
        hasDiamondPlan,
        subscriptionStartDate,
    };
}
