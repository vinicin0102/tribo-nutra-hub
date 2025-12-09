import { supabase } from '@/integrations/supabase/client';

/**
 * Upload de áudio para o Supabase Storage
 */
export async function uploadAudio(
  audioBlob: Blob,
  userId: string
): Promise<string> {
  try {
    // Verificar se o bucket existe primeiro
    const { data: buckets, error: listError } = await supabase.storage.listBuckets();
    
    if (listError) {
      console.error('Erro ao listar buckets:', listError);
    } else {
      const imagesBucket = buckets?.find(b => b.id === 'images');
      if (!imagesBucket) {
        throw new Error('O bucket "images" não existe. Acesse: Supabase Dashboard → Storage → New bucket → Nome: "images" → Marque "Public bucket" → Create');
      }
      console.log('Bucket encontrado:', imagesBucket);
    }

    // Gerar nome único para o arquivo
    const fileName = `${userId}-${Date.now()}.webm`;
    const filePath = `audios/${fileName}`;

    // Fazer upload
    const { error: uploadError } = await supabase.storage
      .from('images')
      .upload(filePath, audioBlob, {
        cacheControl: '3600',
        upsert: false,
        contentType: 'audio/webm',
      });

    if (uploadError) {
      console.error('Erro no upload de áudio:', uploadError);
      console.error('Mensagem completa:', uploadError.message);
      
      // Erro específico: bucket não existe
      if (uploadError.message?.includes('Bucket not found') || 
          uploadError.message?.includes('not found') ||
          uploadError.message?.includes('does not exist')) {
        throw new Error('O bucket "images" não existe. Configure o storage primeiro.');
      }
      
      // Outros erros de permissão
      if (uploadError.message?.includes('permission') || 
          uploadError.message?.includes('policy')) {
        throw new Error('Erro de permissão. Verifique as políticas RLS.');
      }
      
      throw new Error(`Erro ao fazer upload: ${uploadError.message || 'Erro desconhecido'}`);
    }

    // Obter URL pública
    const { data } = supabase.storage
      .from('images')
      .getPublicUrl(filePath);

    return data.publicUrl;
  } catch (error: any) {
    console.error('Erro ao fazer upload de áudio:', error);
    throw error;
  }
}

/**
 * Deletar áudio do Supabase Storage
 */
export async function deleteAudio(url: string): Promise<void> {
  try {
    // Extrair o caminho do arquivo da URL
    const urlParts = url.split('/storage/v1/object/public/images/');
    if (urlParts.length !== 2) {
      return; // URL não é do nosso storage
    }

    const filePath = urlParts[1];

    const { error } = await supabase.storage
      .from('images')
      .remove([filePath]);

    if (error) {
      console.error('Erro ao deletar áudio:', error);
    }
  } catch (error) {
    console.error('Erro ao deletar áudio:', error);
  }
}

