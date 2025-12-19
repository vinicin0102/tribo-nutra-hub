import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';

// Lista de emails admin
const ADMIN_EMAILS = ['admin@gmail.com', 'admin02@gmail.com'];

// Função helper para verificar se é admin por email
export function isAdminEmail(email: string | undefined | null): boolean {
  if (!email) return false;
  return ADMIN_EMAILS.includes(email.toLowerCase());
}

export function useIsAdmin() {
  const { user } = useAuth();
  const { data: profile, isLoading } = useProfile();
  
  // Se for um dos emails admin, sempre retorna true
  if (user?.email && isAdminEmail(user.email)) {
    return true;
  }
  
  // Se o perfil ainda está carregando, retorna false temporariamente
  if (isLoading || !profile) {
    return false;
  }
  
  // Verificar se o perfil tem role admin
  const profileData = profile as { role?: string } | undefined;
  return profileData?.role === 'admin';
}

