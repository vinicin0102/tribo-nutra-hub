import { supabase } from '@/integrations/supabase/client';

/**
 * Upload de áudio para o Supabase Storage
 */
export async function uploadAudio(
  audioBlob: Blob,
  userId: string
): Promise<string> {
  try {
    // Gerar nome único para o arquivo
    const fileName = `${userId}-${Date.now()}.webm`;
    const filePath = `audios/${fileName}`;

    // Fazer upload
    const { error: uploadError } = await supabase.storage
      .from('images') // Usando o mesmo bucket 'images' por enquanto
      .upload(filePath, audioBlob, {
        cacheControl: '3600',
        upsert: false,
        contentType: 'audio/webm',
      });

    if (uploadError) {
      console.error('Erro no upload de áudio:', uploadError);
      console.error('Código do erro:', uploadError.statusCode);
      console.error('Mensagem completa:', uploadError.message);
      
      // Erro específico: bucket não existe
      if (uploadError.message?.includes('Bucket not found') || 
          uploadError.message?.includes('not found') ||
          uploadError.message?.includes('does not exist') ||
          uploadError.statusCode === '404' ||
          uploadError.error === 'Bucket not found') {
        throw new Error('O bucket "images" não existe no Supabase Storage. Execute o SQL: EXECUTAR-ESTE-SQL-BUCKET.sql no Supabase SQL Editor');
      }
      
      // Outros erros de permissão
      if (uploadError.message?.includes('permission') || 
          uploadError.message?.includes('policy') ||
          uploadError.statusCode === '403') {
        throw new Error('Erro de permissão. Verifique se as políticas RLS foram criadas. Execute: VERIFICAR-BUCKET-COMPLETO.sql');
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

