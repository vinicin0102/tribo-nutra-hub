/**
 * Serviço de integração com a API do OpenAI (ChatGPT)
 */

// A chave da API deve ser configurada em .env.local como VITE_OPENAI_API_KEY
const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY || '';

interface ChatMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}

interface ChatCompletionResponse {
    id: string;
    object: string;
    created: number;
    model: string;
    choices: {
        index: number;
        message: {
            role: string;
            content: string;
        };
        finish_reason: string;
    }[];
    usage: {
        prompt_tokens: number;
        completion_tokens: number;
        total_tokens: number;
    };
}

/**
 * Envia uma mensagem para o ChatGPT e retorna a resposta
 */
export async function sendChatMessage(
    messages: ChatMessage[],
    model: string = 'gpt-4o-mini'
): Promise<string> {
    try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${OPENAI_API_KEY}`,
            },
            body: JSON.stringify({
                model,
                messages,
                temperature: 0.7,
                max_tokens: 2000,
            }),
        });

        if (!response.ok) {
            const errorData = await response.json();
            console.error('Erro da API OpenAI:', errorData);
            throw new Error(errorData.error?.message || 'Erro ao chamar a API do OpenAI');
        }

        const data: ChatCompletionResponse = await response.json();
        return data.choices[0]?.message?.content || '';
    } catch (error) {
        console.error('Erro ao enviar mensagem para ChatGPT:', error);
        throw error;
    }
}

/**
 * Gera uma copy de vendas para um produto
 */
export async function generateCopy(
    productName: string,
    targetAudience?: string
): Promise<string> {
    const systemPrompt = `Você é um copywriter brasileiro expert em vendas de produtos naturais e nutraceuticos. 
Você cria copies persuasivas, emocionantes e que convertem muito bem.
Use emojis de forma estratégica para chamar atenção.
Use português brasileiro natural e informal, como se estivesse conversando.
Crie urgência e escassez de forma ética.`;

    const userPrompt = `Crie uma copy de vendas completa para o seguinte produto:

PRODUTO: ${productName}
${targetAudience ? `PÚBLICO-ALVO: ${targetAudience}` : ''}

A copy deve ter:
1. Um gancho inicial impactante (ATENÇÃO!)
2. Uma seção "O QUE TORNA ESPECIAL"
3. Lista de BENEFÍCIOS COMPROVADOS com bullets ✅
4. Seção "POR QUE ESCOLHER"
5. OFERTA ESPECIAL com urgência
6. Call to action forte
7. Garantia de satisfação
8. Hashtags relevantes

Use emojis como 🔥, ✨, 💪, ⚡, 🎯, 👉, 🛡️ de forma estratégica.
A copy deve ser adaptada para posts de redes sociais.`;

    const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
    ];

    return sendChatMessage(messages);
}

/**
 * Gera um script de vídeo para redes sociais
 */
export async function generateVideoScript(
    productName: string,
    platform: 'instagram' | 'facebook' | 'tiktok',
    contentType: string,
    targetAudience: string,
    mainObjective: string,
    tone: string,
    duration: 'curto' | 'medio' | 'longo',
    mainBenefits: string,
    callToAction: string
): Promise<string> {
    const durationMap = {
        curto: '15-30 segundos',
        medio: '30-60 segundos',
        longo: '60-90 segundos',
    };

    const systemPrompt = `Você é um roteirista brasileiro especializado em vídeos virais para ${platform}.
Você cria roteiros que prendem a atenção, geram engajamento e convertem em vendas.
Seus roteiros são práticos, com instruções claras de cena, texto e dicas de gravação.
Use português brasileiro natural e envolvente.`;

    const userPrompt = `Crie um roteiro de vídeo completo para ${platform.toUpperCase()} com as seguintes especificações:

📋 BRIEFING:
• Produto: ${productName}
• Tipo de Conteúdo: ${contentType}
• Público-Alvo: ${targetAudience}
• Objetivo: ${mainObjective}
• Tom: ${tone}
• Duração: ${durationMap[duration]}
• Benefícios: ${mainBenefits}
• CTA: ${callToAction}

O roteiro deve ter:
1. 🎬 INFORMAÇÕES DO BRIEFING no início
2. Divisão clara por CENAS com tempo
3. Instruções de câmera [entre colchetes]
4. Falas/texto exato entre aspas
5. Dicas de gravação específicas para ${platform}
6. Sugestão de música/áudio
7. Hashtags relevantes

Use a estrutura:
- CENA 1 - GANCHO (primeiros segundos são cruciais!)
- CENA 2 - PROBLEMA/SITUAÇÃO
- CENA 3 - APRESENTAÇÃO DO PRODUTO
- CENA 4 - PROVA SOCIAL/BENEFÍCIOS
- CENA 5 - CALL TO ACTION

Use separadores visuais e emojis para organizar melhor.
${platform === 'tiktok' ? 'Para TikTok: cortes rápidos, energia alta, hooks agressivos!' : ''}
${platform === 'instagram' ? 'Para Instagram: visual bonito, storytelling, autenticidade!' : ''}
${platform === 'facebook' ? 'Para Facebook: conexão emocional, depoimentos, urgência!' : ''}`;

    const messages: ChatMessage[] = [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userPrompt },
    ];

    return sendChatMessage(messages);
}
