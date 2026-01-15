import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useIsAdmin } from './useAdmin';
import { toast } from 'sonner';

export interface ExternalLink {
  title: string;
  url: string;
}

export interface Lesson {
  id: string;
  module_id: string;
  title: string;
  description: string | null;
  vturb_code: string | null;
  // removed pdf_url, is_locked, etc as they are not in the schema
  external_links: ExternalLink[];
  order_index: number;
  is_published: boolean;
  duration_minutes: number;
  cover_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface Module {
  id: string;
  title: string;
  description: string | null;
  course_id: string | null;
  order_index: number;
  is_published: boolean;
  is_locked: boolean;
  unlock_after_days?: number; // Dias para liberar (legacy)
  unlock_date?: string | null; // Data fixa de liberação (definida pelo admin)
  cover_url: string | null;
  created_at: string;
  updated_at: string;
  lessons?: Lesson[];
}

export function useModules() {
  const isAdmin = useIsAdmin();

  return useQuery({
    queryKey: ['modules', isAdmin],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('modules')
        .select('*')
        .order('order_index', { ascending: true });

      if (error) throw error;
      return data as Module[];
    },
  });
}

export function useLessons(moduleId?: string) {
  const isAdmin = useIsAdmin();

  return useQuery({
    queryKey: ['lessons', moduleId, isAdmin],
    queryFn: async () => {
      let query = supabase
        .from('lessons')
        .select('*')
        .order('order_index', { ascending: true });

      if (moduleId) {
        query = query.eq('module_id', moduleId);
      }

      const { data, error } = await query;
      if (error) throw error;

      return data.map(lesson => ({
        ...lesson,
        external_links: (lesson.external_links as unknown as ExternalLink[]) || []
      })) as Lesson[];
    },
    enabled: !!moduleId || isAdmin,
  });
}

export function useModulesWithLessons() {
  const isAdmin = useIsAdmin();

  return useQuery({
    queryKey: ['modules-with-lessons', isAdmin],
    queryFn: async () => {
      const { data: modules, error: modulesError } = await supabase
        .from('modules')
        .select('*')
        .order('order_index', { ascending: true });

      if (modulesError) throw modulesError;

      const { data: lessons, error: lessonsError } = await supabase
        .from('lessons')
        .select('*')
        .order('order_index', { ascending: true });

      if (lessonsError) throw lessonsError;

      const modulesWithLessons = (modules as Module[]).map(module => ({
        ...module,
        lessons: (lessons as any[])
          .filter(lesson => lesson.module_id === module.id)
          .map(lesson => ({
            ...lesson,
            external_links: (lesson.external_links as unknown as ExternalLink[]) || []
          })) as Lesson[]
      }));

      return modulesWithLessons;
    },
  });
}

export function useLesson(lessonId: string) {
  return useQuery({
    queryKey: ['lesson', lessonId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('lessons')
        .select('*')
        .eq('id', lessonId)
        .single();

      if (error) throw error;
      return {
        ...data,
        external_links: (data.external_links as unknown as ExternalLink[]) || []
      } as Lesson;
    },
    enabled: !!lessonId,
  });
}

// Admin mutations
export function useCreateModule() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (module: Omit<Module, 'id' | 'created_at' | 'updated_at'>) => {
      const moduleData = {
        title: module.title,
        description: module.description || null,
        course_id: module.course_id || null,
        order_index: module.order_index || 0,
        is_published: module.is_published || false,
        is_locked: module.is_locked || false,
        cover_url: module.cover_url || null
      };

      const { data, error } = await supabase
        .from('modules')
        .insert(moduleData)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['modules'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Módulo criado com sucesso!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao criar módulo: ' + error.message);
    },
  });
}

export function useUpdateModule() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, ...module }: Partial<Module> & { id: string }) => {
      const moduleData: Record<string, any> = {};

      if (module.title !== undefined) moduleData.title = module.title;
      if (module.description !== undefined) moduleData.description = module.description;
      if (module.course_id !== undefined) moduleData.course_id = module.course_id || null;
      if (module.order_index !== undefined) moduleData.order_index = module.order_index;
      if (module.is_published !== undefined) moduleData.is_published = module.is_published;
      if (module.is_locked !== undefined) moduleData.is_locked = module.is_locked;
      if (module.cover_url !== undefined) moduleData.cover_url = module.cover_url;

      const { data, error } = await supabase
        .from('modules')
        .update(moduleData)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['modules'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Módulo atualizado!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao atualizar módulo: ' + error.message);
    },
  });
}

export function useDeleteModule() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('modules')
        .delete()
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['modules'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Módulo excluído!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao excluir módulo: ' + error.message);
    },
  });
}

export function useCreateLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (lesson: Omit<Lesson, 'id' | 'created_at' | 'updated_at'>) => {
      // Create a clean object with only allowed fields
      const lessonData = {
        module_id: lesson.module_id,
        title: lesson.title,
        description: lesson.description || null,
        vturb_code: lesson.vturb_code || null,
        order_index: lesson.order_index || 0,
        is_published: lesson.is_published || false,
        duration_minutes: lesson.duration_minutes || 0,
        cover_url: lesson.cover_url || null,
        external_links: lesson.external_links as any
      };

      const { data, error } = await supabase
        .from('lessons')
        .insert(lessonData)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Aula criada com sucesso!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao criar aula: ' + error.message);
    },
  });
}

export function useUpdateLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, ...lesson }: Partial<Lesson> & { id: string }) => {
      // Build update object only with defined fields
      const lessonData: Record<string, any> = {};

      if (lesson.module_id !== undefined) lessonData.module_id = lesson.module_id;
      if (lesson.title !== undefined) lessonData.title = lesson.title;
      if (lesson.description !== undefined) lessonData.description = lesson.description;
      if (lesson.vturb_code !== undefined) lessonData.vturb_code = lesson.vturb_code;
      if (lesson.order_index !== undefined) lessonData.order_index = lesson.order_index;
      if (lesson.is_published !== undefined) lessonData.is_published = lesson.is_published;
      if (lesson.duration_minutes !== undefined) lessonData.duration_minutes = lesson.duration_minutes;
      if (lesson.cover_url !== undefined) lessonData.cover_url = lesson.cover_url;
      if (lesson.external_links !== undefined) lessonData.external_links = lesson.external_links;

      const { data, error } = await supabase
        .from('lessons')
        .update(lessonData)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      queryClient.invalidateQueries({ queryKey: ['lesson'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Aula atualizada!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao atualizar aula: ' + error.message);
    },
  });
}

export function useDeleteLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from('lessons')
        .delete()
        .eq('id', id);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
      queryClient.invalidateQueries({ queryKey: ['modules-with-lessons'] });
      toast.success('Aula excluída!');
    },
    onError: (error: Error) => {
      toast.error('Erro ao excluir aula: ' + error.message);
    },
  });
}
