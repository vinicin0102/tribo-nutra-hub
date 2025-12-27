/**
 * Serviço de geração de conteúdo com IA (usando templates inteligentes)
 * Funciona sem dependência de API externa
 */

// Templates de variações para criar copies únicas
const ganchos = [
    "🔥 ATENÇÃO! Você que está cansado(a) de promessas vazias...",
    "⚡ PARE TUDO! Isso vai mudar sua vida!",
    "🚨 DESCOBERTA INCRÍVEL! Finalmente a solução que você esperava!",
    "💥 CHEGA DE SOFRER! A transformação começa agora!",
    "✨ EXCLUSIVO! O segredo que ninguém te conta...",
];

const beneficiosBase = [
    "✅ Resultados visíveis desde as primeiras semanas",
    "✅ Fórmula 100% natural e segura",
    "✅ Aprovado por milhares de clientes satisfeitos",
    "✅ Sem efeitos colaterais",
    "✅ Fácil de usar no dia a dia",
    "✅ Qualidade premium garantida",
    "✅ Produzido com os melhores ingredientes",
    "✅ Absorção rápida pelo organismo",
];

const ctasBase = [
    "👉 CLIQUE AGORA e garanta o seu antes que acabe!",
    "🛒 APROVEITE! Estoque limitadíssimo!",
    "💪 Comece sua transformação HOJE mesmo!",
    "🎯 Não perca essa oportunidade única!",
    "🔥 COMPRE AGORA e mude sua vida!",
];

const garantias = [
    "🛡️ GARANTIA TOTAL: Se não gostar, devolvemos seu dinheiro. Risco ZERO!",
    "✅ SATISFAÇÃO GARANTIDA ou seu dinheiro de volta em até 30 dias!",
    "🔒 COMPRA 100% SEGURA com garantia incondicional!",
];

/**
 * Função auxiliar para embaralhar e selecionar itens aleatórios
 */
function selectRandom<T>(arr: T[], count: number): T[] {
    const shuffled = [...arr].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, count);
}

function getRandomItem<T>(arr: T[]): T {
    return arr[Math.floor(Math.random() * arr.length)];
}

/**
 * Gera uma copy de vendas para um produto usando templates inteligentes
 */
export async function generateCopy(
    productName: string,
    targetAudience?: string
): Promise<string> {
    // Simular um pequeno delay para parecer que está "processando"
    await new Promise(resolve => setTimeout(resolve, 1500));

    const gancho = getRandomItem(ganchos);
    const beneficios = selectRandom(beneficiosBase, 5);
    const cta = getRandomItem(ctasBase);
    const garantia = getRandomItem(garantias);

    const audienciaTexto = targetAudience
        ? `Especialmente desenvolvido para ${targetAudience}!`
        : "Para todas as pessoas que buscam qualidade de vida!";

    const copy = `${gancho}

🎯 Apresentamos: **${productName.toUpperCase()}**

${audienciaTexto}

━━━━━━━━━━━━━━━━━━━━
✨ O QUE TORNA ${productName.toUpperCase()} ESPECIAL?
━━━━━━━━━━━━━━━━━━━━

Desenvolvido com a mais alta tecnologia e ingredientes selecionados, ${productName} chegou para revolucionar o mercado!

💎 Enquanto outros produtos prometem e não entregam, nós GARANTIMOS resultados!

━━━━━━━━━━━━━━━━━━━━
🏆 BENEFÍCIOS COMPROVADOS:
━━━━━━━━━━━━━━━━━━━━

${beneficios.join('\n')}

━━━━━━━━━━━━━━━━━━━━
💡 POR QUE ESCOLHER ${productName.toUpperCase()}?
━━━━━━━━━━━━━━━━━━━━

🔹 Qualidade incomparável
🔹 Milhares de clientes satisfeitos
🔹 Resultados comprovados
🔹 Melhor custo-benefício do mercado

━━━━━━━━━━━━━━━━━━━━
🎁 OFERTA ESPECIAL - TEMPO LIMITADO!
━━━━━━━━━━━━━━━━━━━━

⏰ Oferta válida apenas HOJE!
📦 Frete GRÁTIS para todo o Brasil!
💳 Parcelamos em até 12x sem juros!

${cta}

${garantia}

━━━━━━━━━━━━━━━━━━━━

#${productName.replace(/\s+/g, '')} #SaudeNatural #BemEstar #Qualidade #VidaSaudavel #Transformacao #ResultadosReais #MelhorEscolha #Nutraceuticos`;

    return copy;
}

/**
 * Gera um script de vídeo para redes sociais usando templates inteligentes
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
    // Simular um pequeno delay para parecer que está "processando"
    await new Promise(resolve => setTimeout(resolve, 2000));

    const durationMap = {
        curto: '15-30 segundos',
        medio: '30-60 segundos',
        longo: '60-90 segundos',
    };

    const timePerScene = {
        curto: ['0-5s', '5-10s', '10-20s', '20-25s', '25-30s'],
        medio: ['0-8s', '8-20s', '20-35s', '35-50s', '50-60s'],
        longo: ['0-10s', '10-25s', '25-45s', '45-70s', '70-90s'],
    };

    const platformTips = {
        instagram: `
📱 DICAS PARA INSTAGRAM:
• Use filtros suaves e iluminação natural
• Mantenha o visual limpo e estético
• Adicione legendas para quem assiste sem som
• Use transições suaves entre cenas
• Publique nos melhores horários (12h e 19h)`,
        tiktok: `
📱 DICAS PARA TIKTOK:
• Cortes RÁPIDOS e dinâmicos
• Energia ALTA desde o primeiro segundo
• Use trends e músicas virais
• Seja autêntico e espontâneo
• Hook agressivo nos primeiros 3 segundos`,
        facebook: `
📱 DICAS PARA FACEBOOK:
• Foque em conexão emocional
• Conte uma história real
• Use depoimentos se possível
• Vídeos mais longos funcionam bem
• Inclua legendas (85% assiste sem som)`,
    };

    const times = timePerScene[duration];

    const script = `━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎬 ROTEIRO DE VÍDEO - ${platform.toUpperCase()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 BRIEFING:
━━━━━━━━━━━━━━━━━━━━
• 📦 Produto: ${productName}
• 🎯 Tipo: ${contentType}
• 👥 Público: ${targetAudience}
• 🎯 Objetivo: ${mainObjective}
• 🎭 Tom: ${tone}
• ⏱️ Duração: ${durationMap[duration]}
• ✨ Benefícios: ${mainBenefits}
• 📢 CTA: ${callToAction}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📹 ROTEIRO DETALHADO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎬 CENA 1 - GANCHO (${times[0]})
━━━━━━━━━━━━━━━━━━━━

[Câmera focada no rosto, close-up]

🗣️ FALA:
"Você já se perguntou por que tanta gente está falando sobre ${productName}?"

📌 Ação: Olhar diretamente para a câmera com expressão curiosa/intrigante

━━━━━━━━━━━━━━━━━━━━

🎬 CENA 2 - PROBLEMA/SITUAÇÃO (${times[1]})
━━━━━━━━━━━━━━━━━━━━

[Câmera média, mostrar ambiente relacionado ao problema]

🗣️ FALA:
"Eu sei como é difícil encontrar algo que REALMENTE funcione. Passei por isso também..."

📌 Ação: Expressão empática, gesticular suavemente

━━━━━━━━━━━━━━━━━━━━

🎬 CENA 3 - APRESENTAÇÃO DO PRODUTO (${times[2]})
━━━━━━━━━━━━━━━━━━━━

[Close no produto, iluminação bonita]

🗣️ FALA:
"Até que descobri ${productName}! E nossa... mudou TUDO pra mim!"

📌 Ação: Mostrar o produto, destacar embalagem, sorrir genuinamente

💡 Dica: ${mainBenefits}

━━━━━━━━━━━━━━━━━━━━

🎬 CENA 4 - PROVA SOCIAL/BENEFÍCIOS (${times[3]})
━━━━━━━━━━━━━━━━━━━━

[Câmera média, gesticulando positivamente]

🗣️ FALA:
"Os resultados foram incríveis! E não sou só eu, milhares de pessoas estão tendo a mesma experiência!"

📌 Ação: Contar benefícios nos dedos, expressão animada

━━━━━━━━━━━━━━━━━━━━

🎬 CENA 5 - CALL TO ACTION (${times[4]})
━━━━━━━━━━━━━━━━━━━━

[Close-up, energia alta]

🗣️ FALA:
"${callToAction} Corre lá que você não vai se arrepender! Link na bio! 👇"

📌 Ação: Apontar para baixo (link), sorrir, energia ALTA!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${platformTips[platform]}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎵 SUGESTÃO DE ÁUDIO:
• Música trending do momento
• Tom ${tone} que combine com a mensagem
• Volume baixo quando houver fala

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

#${productName.replace(/\s+/g, '')} #${platform} #Viral #Transformacao #ResultadosReais #DicasDo${platform.charAt(0).toUpperCase() + platform.slice(1)}`;

    return script;
}
