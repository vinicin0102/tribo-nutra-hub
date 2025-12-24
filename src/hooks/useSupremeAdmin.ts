import { useAuth } from '@/contexts/AuthContext';

// Email do Admin Supremo
const SUPREME_ADMIN_EMAIL = 'auxiliodp1@gmail.com';

export function useIsSupremeAdmin() {
    const { user } = useAuth();

    if (!user?.email) return false;

    return user.email.toLowerCase().trim() === SUPREME_ADMIN_EMAIL;
}
