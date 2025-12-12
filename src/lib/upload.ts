import { supabase } from '@/integrations/supabase/client';
import { processAvatarImage, processPostImage, processCoverImage } from './imageProcessing';

export type UploadFolder = 'avatars' | 'posts' | 'modules' | 'lessons' | 'banners' | 'pdfs';

/**
 * Upload de imagem para o Supabase Storage
 */
export async function uploadImage(
  file: File,
  folder: UploadFolder,
  userId: string
): Promise<string> {
  try {
    // Validar tipo de arquivo
    if (!file.type.startsWith('image/')) {
      throw new Error('Arquivo deve ser uma imagem');
    }

    // Validar tamanho (máximo 5MB antes do processamento)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      throw new Error('Imagem muito grande. Tamanho máximo: 5MB');
    }

    // Processar imagem antes do upload
    let processedFile: File;
    if (folder === 'avatars') {
      // Processar avatar: formato quadrado, 512x512, alta qualidade
      processedFile = await processAvatarImage(file);
    } else if (folder === 'modules' || folder === 'lessons' || folder === 'banners') {
      // Processar capa: 16:9, max 1920x1080
      processedFile = await processCoverImage(file);
    } else {
      // Processar post: manter proporção, redimensionar se necessário
      processedFile = await processPostImage(file);
    }

    // Gerar nome único para o arquivo (sempre JPG após processamento)
    const fileName = `${userId}-${Date.now()}.jpg`;
    const filePath = `${folder}/${fileName}`;

    // Fazer upload do arquivo processado
    const { error: uploadError } = await supabase.storage
      .from('images')
      .upload(filePath, processedFile, {
        cacheControl: '3600',
        upsert: false,
        contentType: 'image/jpeg',
      });

    if (uploadError) {
      // Verificar se é erro de bucket não encontrado
      if (uploadError.message?.includes('Bucket not found') || uploadError.message?.includes('not found')) {
        throw new Error('Bucket de imagens não configurado no Supabase. Configure o bucket "images" no Storage.');
      }
      throw uploadError;
    }

    // Obter URL pública
    const { data } = supabase.storage
      .from('images')
      .getPublicUrl(filePath);

    return data.publicUrl;
  } catch (error) {
    console.error('Erro ao fazer upload:', error);
    throw error;
  }
}

/**
 * Upload de PDF para o Supabase Storage
 */
export async function uploadPDF(
  file: File,
  folder: 'pdfs',
  userId: string
): Promise<string> {
  try {
    // Validar tipo de arquivo
    if (file.type !== 'application/pdf') {
      throw new Error('Arquivo deve ser um PDF');
    }

    // Validar tamanho (máximo 10MB)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSize) {
      throw new Error('PDF muito grande. Tamanho máximo: 10MB');
    }

    // Gerar nome único para o arquivo
    const fileName = `${userId}-${Date.now()}.pdf`;
    const filePath = `${folder}/${fileName}`;

    // Tentar primeiro com bucket "documents" (recomendado)
    // Se não existir, tentar com "images"
    let bucketName = 'documents';
    let uploadError = null;
    let uploadResult = null;

    // Tentar upload no bucket "documents"
    uploadResult = await supabase.storage
      .from('documents')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false,
        contentType: 'application/pdf',
      });

    uploadError = uploadResult.error;

    // Se o bucket "documents" não existir, tentar "images"
    if (uploadError && (uploadError.message?.includes('Bucket not found') || uploadError.message?.includes('not found'))) {
      bucketName = 'images';
      uploadResult = await supabase.storage
        .from('images')
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false,
          contentType: 'application/pdf',
        });
      
      uploadError = uploadResult.error;
    }

    if (uploadError) {
      if (uploadError.message?.includes('mime type') || uploadError.message?.includes('not supported')) {
        throw new Error('O bucket não está configurado para aceitar PDFs. Execute o script configurar-storage-pdf.sql e configure o bucket no Supabase Dashboard.');
      }
      throw uploadError;
    }

    // Obter URL pública
    const { data } = supabase.storage
      .from(bucketName)
      .getPublicUrl(filePath);

    return data.publicUrl;
  } catch (error: any) {
    console.error('Erro ao fazer upload do PDF:', error);
    throw error;
  }
}

/**
 * Deletar imagem do Supabase Storage
 */
export async function deleteImage(url: string): Promise<void> {
  try {
    // Extrair o caminho do arquivo da URL
    const urlParts = url.split('/storage/v1/object/public/images/');
    if (urlParts.length !== 2) {
      return; // URL não é do nosso storage, não precisa deletar
    }

    const filePath = urlParts[1];

    const { error } = await supabase.storage
      .from('images')
      .remove([filePath]);

    if (error) {
      console.error('Erro ao deletar imagem:', error);
    }
  } catch (error) {
    console.error('Erro ao deletar imagem:', error);
  }
}

