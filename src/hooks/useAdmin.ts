import { useAuth } from '@/contexts/AuthContext';
import { useProfile } from './useProfile';

// Lista de emails admin
const ADMIN_EMAILS = ['admin02@gmail.com', 'auxiliodp1@gmail.com', 'vv9250400@gmail.com'];

// Função helper para verificar se é admin por email
export function isAdminEmail(email: string | undefined | null): boolean {
  if (!email) return false;
  const normalizedEmail = email.toLowerCase().trim();
  console.log('🔐 [useAdmin] Verificando email:', { email, normalizedEmail, isAdmin: ADMIN_EMAILS.includes(normalizedEmail) });
  return ADMIN_EMAILS.includes(normalizedEmail);
}

export function useIsAdmin() {
  const { user } = useAuth();
  const { data: profile, isLoading } = useProfile();

  // Debug: mostrar informações do usuário
  console.log('🔐 [useIsAdmin] Estado:', {
    userEmail: user?.email,
    profileLoading: isLoading,
    profileRole: (profile as any)?.role,
    isAdminByEmail: user?.email ? isAdminEmail(user.email) : false
  });

  // Se for um dos emails admin, sempre retorna true
  if (user?.email && isAdminEmail(user.email)) {
    console.log('✅ [useIsAdmin] Usuário reconhecido como admin por email');
    return true;
  }

  // Se o perfil ainda está carregando, retorna false temporariamente
  if (isLoading || !profile) {
    console.log('⏳ [useIsAdmin] Perfil ainda carregando, retornando false temporariamente');
    return false;
  }

  // Verificar se o perfil tem role admin
  const profileData = profile as { role?: string } | undefined;
  const isAdminByRole = profileData?.role === 'admin';
  console.log('🔐 [useIsAdmin] Verificação por role:', { role: profileData?.role, isAdminByRole });
  return isAdminByRole;
}
