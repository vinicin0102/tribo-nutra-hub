/**
 * Utilitários para verificação de horário de funcionamento
 * Feed e Chat funcionam das 9h às 21h (horário de Brasília) por padrão
 * Mas pode ser configurado no painel admin
 */

// Cache das configurações (atualizado quando necessário)
let cachedStartHour = 9;
let cachedEndHour = 21;

/**
 * Atualiza o cache das horas de funcionamento
 */
export function updateOperatingHours(startHour: number, endHour: number) {
  cachedStartHour = startHour;
  cachedEndHour = endHour;
}

/**
 * Verifica se está dentro do horário de funcionamento
 * Usa as configurações do banco de dados se disponíveis, senão usa padrão (9h-21h)
 * @returns true se está dentro do horário permitido, false caso contrário
 */
export function isWithinOperatingHours(): boolean {
  // Criar data no fuso horário de Brasília
  const brasiliaTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'America/Sao_Paulo' }));
  const currentHour = brasiliaTime.getHours();
  
  // Usar horas configuradas (ou padrão se não configurado)
  return currentHour >= cachedStartHour && currentHour < cachedEndHour;
}

/**
 * Obtém o horário atual em Brasília formatado
 * @returns String com o horário formatado (ex: "14:30")
 */
export function getBrasiliaTime(): string {
  const brasiliaTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'America/Sao_Paulo' }));
  const hours = brasiliaTime.getHours().toString().padStart(2, '0');
  const minutes = brasiliaTime.getMinutes().toString().padStart(2, '0');
  return `${hours}:${minutes}`;
}

/**
 * Obtém mensagem de erro para quando está fora do horário de funcionamento
 * @returns String com a mensagem de erro
 */
export function getOperatingHoursMessage(): string {
  const currentTime = getBrasiliaTime();
  return `O feed e o chat estão disponíveis apenas das ${cachedStartHour}h às ${cachedEndHour}h (horário de Brasília). Horário atual: ${currentTime}. Tente novamente durante o horário de funcionamento.`;
}

/**
 * Obtém as horas de funcionamento formatadas
 * @returns String com as horas de funcionamento
 */
export function getOperatingHours(): string {
  return `${cachedStartHour}h às ${cachedEndHour}h (horário de Brasília)`;
}

