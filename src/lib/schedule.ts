/**
 * Utilitários para verificação de horário de funcionamento
 * Feed e Chat funcionam das 9h às 21h (horário de Brasília) por padrão
 * Plano Free tem horário restrito (10h às 15h por padrão)
 * Plano Diamond tem acesso 24h
 * Pode ser configurado no painel admin
 */

// Cache das configurações (atualizado quando necessário)
// Horário geral do chat/feed
let cachedStartHour = 9;
let cachedEndHour = 21;

// Horário específico para plano Free
let cachedFreeStartHour = 10;
let cachedFreeEndHour = 15;

/**
 * Atualiza o cache das horas de funcionamento gerais
 */
export function updateOperatingHours(startHour: number, endHour: number) {
  cachedStartHour = startHour;
  cachedEndHour = endHour;
}

/**
 * Atualiza o cache das horas de funcionamento do plano Free
 */
export function updateFreeOperatingHours(startHour: number, endHour: number) {
  cachedFreeStartHour = startHour;
  cachedFreeEndHour = endHour;
}

/**
 * Obtém as horas de funcionamento do plano Free
 */
export function getFreeOperatingHours(): { startHour: number; endHour: number } {
  return {
    startHour: cachedFreeStartHour,
    endHour: cachedFreeEndHour
  };
}

/**
 * Verifica se está dentro do horário de funcionamento geral
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
 * Verifica se está dentro do horário de funcionamento para plano Free
 * @returns true se está dentro do horário permitido para Free, false caso contrário
 */
export function isWithinFreeOperatingHours(): boolean {
  // Criar data no fuso horário de Brasília
  const brasiliaTime = new Date(new Date().toLocaleString('en-US', { timeZone: 'America/Sao_Paulo' }));
  const currentHour = brasiliaTime.getHours();

  // Usar horas configuradas para Free (ou padrão 10h-15h se não configurado)
  return currentHour >= cachedFreeStartHour && currentHour < cachedFreeEndHour;
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
 * Obtém mensagem de erro para quando está fora do horário de funcionamento geral
 * @returns String com a mensagem de erro
 */
export function getOperatingHoursMessage(): string {
  const currentTime = getBrasiliaTime();
  return `O feed e o chat estão disponíveis apenas das ${cachedStartHour}h às ${cachedEndHour}h (horário de Brasília). Horário atual: ${currentTime}. Tente novamente durante o horário de funcionamento.`;
}

/**
 * Obtém mensagem de erro para plano Free quando está fora do horário
 * @returns String com a mensagem de erro
 */
export function getFreeOperatingHoursMessage(): string {
  const currentTime = getBrasiliaTime();
  return `O chat para o plano Free está disponível apenas das ${cachedFreeStartHour}h às ${cachedFreeEndHour}h (horário de Brasília). Horário atual: ${currentTime}. Assine o plano Diamond para ter acesso 24 horas!`;
}

/**
 * Obtém as horas de funcionamento formatadas
 * @returns String com as horas de funcionamento
 */
export function getOperatingHours(): string {
  return `${cachedStartHour}h às ${cachedEndHour}h (horário de Brasília)`;
}

/**
 * Obtém as horas de funcionamento do Free formatadas
 * @returns String com as horas de funcionamento do Free
 */
export function getFreeOperatingHoursFormatted(): string {
  return `${cachedFreeStartHour}h às ${cachedFreeEndHour}h (horário de Brasília)`;
}

