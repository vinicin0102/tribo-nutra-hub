/**
 * Valida e converte chave VAPID para Uint8Array
 * Esta função garante que a chave está no formato correto para push notifications
 */

export function validateAndConvertVAPIDKey(vapidKey: string): Uint8Array {
  if (!vapidKey) {
    throw new Error('Chave VAPID não fornecida');
  }

  // Remover espaços, quebras de linha e caracteres inválidos
  const cleanKey = vapidKey
    .trim()
    .replace(/\s/g, '')
    .replace(/\n/g, '')
    .replace(/\r/g, '');

  // Validar formato base64 URL-safe
  if (!/^[A-Za-z0-9_-]+$/.test(cleanKey)) {
    throw new Error('Chave VAPID contém caracteres inválidos. Deve ser base64 URL-safe.');
  }

  // Validar tamanho mínimo (chave P-256 deve ter ~87 caracteres em base64)
  if (cleanKey.length < 80 || cleanKey.length > 200) {
    throw new Error(`Chave VAPID tem tamanho inválido: ${cleanKey.length} caracteres (esperado: ~87)`);
  }

  // Adicionar padding se necessário
  const padding = '='.repeat((4 - (cleanKey.length % 4)) % 4);
  
  // Converter de URL-safe base64 para base64 padrão
  const base64 = (cleanKey + padding)
    .replace(/-/g, '+')
    .replace(/_/g, '/');

  // Decodificar base64
  let rawData: string;
  try {
    rawData = window.atob(base64);
  } catch (e) {
    throw new Error('Falha ao decodificar base64. Chave pode estar corrompida.');
  }

  // Validar tamanho decodificado (chave P-256 deve ter 65 bytes)
  if (rawData.length !== 65) {
    throw new Error(`Chave VAPID decodificada tem tamanho incorreto: ${rawData.length} bytes (esperado: 65 bytes para P-256)`);
  }

  // Validar primeiro byte (deve ser 0x04 para formato não comprimido)
  const firstByte = rawData.charCodeAt(0);
  if (firstByte !== 0x04) {
    console.error(`❌ ERRO CRÍTICO: Primeiro byte da chave VAPID não é 0x04: ${firstByte}. Chave inválida!`);
    throw new Error(`Chave VAPID inválida: primeiro byte é ${firstByte}, esperado 4 (0x04). A chave pode estar corrompida ou no formato errado.`);
  }

  // Converter para Uint8Array - FORMA MAIS ROBUSTA
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  
  // Verificação final rigorosa
  if (outputArray.length !== 65) {
    throw new Error(`Uint8Array tem tamanho incorreto: ${outputArray.length} bytes (esperado: 65)`);
  }
  
  if (outputArray[0] !== 0x04) {
    throw new Error(`Primeiro byte incorreto: ${outputArray[0]} (esperado: 4). Chave VAPID inválida.`);
  }
  
  // Verificar se é realmente um Uint8Array válido
  if (!(outputArray instanceof Uint8Array)) {
    throw new Error('Falha ao criar Uint8Array. Tipo incorreto.');
  }

  return outputArray;
}

