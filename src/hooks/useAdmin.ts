import { useAuth } from '@/contexts/AuthContext';

const ADMIN_EMAIL = 'admin@gmail.com';

export function useIsAdmin() {
  const { user } = useAuth();
  return user?.email === ADMIN_EMAIL;
}

