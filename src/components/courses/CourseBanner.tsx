import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { ExternalLink, Image as ImageIcon } from 'lucide-react';

export function CourseBanner() {
  const { data: banner, isLoading } = useQuery({
    queryKey: ['course-banner'],
    queryFn: async () => {
      // Tentar buscar banner do banco de dados
      try {
        const { data, error } = await supabase
          .from('course_banners')
          .select('*')
          .eq('is_active', true)
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle();

        if (error && error.code !== 'PGRST116') { // PGRST116 = table doesn't exist
          throw error;
        }

        if (data) {
          return data;
        }
      } catch (e) {
        // Tabela não existe, usar localStorage
        const stored = localStorage.getItem('course_banner');
        if (stored) {
          return JSON.parse(stored);
        }
      }

      return null;
    },
  });

  const BannerContent = () => {
    if (!banner) {
      // Placeholder quando não há banner
      return (
        <div className="relative overflow-hidden rounded-2xl border border-dashed border-border/50 aspect-[3/1] min-h-[120px] sm:min-h-[160px] bg-muted/30 flex items-center justify-center">
          <div className="text-center">
            <ImageIcon className="w-12 h-12 text-muted-foreground/50 mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">
              Espaço para banner promocional
            </p>
            <p className="text-xs text-muted-foreground/70 mt-1">
              Configure no painel admin
            </p>
          </div>
        </div>
      );
    }

    return (
      <div className="relative overflow-hidden rounded-2xl border border-border aspect-[3/1] min-h-[120px] sm:min-h-[160px]">
        {banner.image_url ? (
          <img 
            src={banner.image_url} 
            alt={banner.title || 'Banner'} 
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full bg-gradient-to-r from-primary/20 to-orange-500/20" />
        )}
        
        {/* Overlay para texto se houver */}
        {(banner.title || banner.description) && (
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent flex items-end">
            <div className="p-4 sm:p-6 w-full">
              {banner.title && (
                <h3 className="text-xl sm:text-2xl font-bold text-white mb-2">
                  {banner.title}
                </h3>
              )}
              {banner.description && (
                <p className="text-sm sm:text-base text-gray-200">
                  {banner.description}
                </p>
              )}
              {banner.link_url && (
                <a
                  href={banner.link_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-2 mt-3 text-primary hover:text-primary/80 font-medium text-sm"
                >
                  Saiba mais
                  <ExternalLink className="w-4 h-4" />
                </a>
              )}
            </div>
          </div>
        )}
      </div>
    );
  };

  if (isLoading) {
    return (
      <div className="relative overflow-hidden rounded-2xl border border-border aspect-[3/1] min-h-[120px] sm:min-h-[160px] bg-muted animate-pulse" />
    );
  }

  if (banner && banner.link_url && !banner.title && !banner.description) {
    // Se só tem link e não tem texto, o banner inteiro é clicável
    return (
      <a
        href={banner.link_url}
        target="_blank"
        rel="noopener noreferrer"
        className="block"
      >
        <BannerContent />
      </a>
    );
  }

  return <BannerContent />;
}

