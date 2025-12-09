import { supabase } from '@/integrations/supabase/client';

/**
 * Upload de áudio para o Supabase Storage
 */
export async function uploadAudio(
  audioBlob: Blob,
  userId: string
): Promise<string> {
  // Gerar nome único para o arquivo
  const fileName = `${userId}-${Date.now()}.webm`;
  const filePath = `audios/${fileName}`;

  // Fazer upload diretamente
  const { error: uploadError } = await supabase.storage
    .from('images')
    .upload(filePath, audioBlob, {
      cacheControl: '3600',
      upsert: false,
      contentType: 'audio/webm',
    });

  if (uploadError) {
    console.error('Erro no upload de áudio:', uploadError);
    throw new Error(`Erro ao enviar áudio: ${uploadError.message}`);
  }

  // Obter URL pública
  const { data } = supabase.storage
    .from('images')
    .getPublicUrl(filePath);

  return data.publicUrl;
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

