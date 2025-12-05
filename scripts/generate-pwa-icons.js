#!/usr/bin/env node

/**
 * Script para gerar ícones PWA a partir do favicon.svg
 * 
 * Requisitos:
 * npm install sharp --save-dev
 * 
 * Uso:
 * node scripts/generate-pwa-icons.js
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Tamanhos necessários para PWA
const sizes = [72, 96, 128, 144, 152, 192, 384, 512];

async function generateIcons() {
  try {
    // Importar sharp
    let sharp;
    try {
      sharp = (await import('sharp')).default;
    } catch (error) {
      console.error('❌ Erro: sharp não está instalado!');
      console.log('\n📦 Instale com: npm install sharp --save-dev');
      process.exit(1);
    }

    // Tentar encontrar o arquivo de logo (prioridade: logo-sociedade-nutra-simple.svg, logo-sociedade-nutra.svg, logo-nutra-club.svg, logo.png, logo.svg, favicon.svg)
    const possibleInputs = [
      path.join(__dirname, '../public/logo-sociedade-nutra-simple.svg'),
      path.join(__dirname, '../public/logo-sociedade-nutra.svg'),
      path.join(__dirname, '../public/logo-nutra-club.svg'),
      path.join(__dirname, '../public/logo.png'),
      path.join(__dirname, '../public/logo.svg'),
      path.join(__dirname, '../public/favicon.svg'),
    ];

    let inputFile = null;
    for (const file of possibleInputs) {
      if (fs.existsSync(file)) {
        inputFile = file;
        console.log(`📸 Usando: ${path.basename(file)}\n`);
        break;
      }
    }

    const outputDir = path.join(__dirname, '../public/icons');

    // Verificar se encontrou algum arquivo
    if (!inputFile) {
      console.error('❌ Nenhum arquivo de logo encontrado!');
      console.error('   Procurando por: logo-nutra-club.svg, logo.png, logo.svg ou favicon.svg');
      console.error('   Coloque um desses arquivos em: public/');
      process.exit(1);
    }

    // Criar diretório de saída se não existir
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
      console.log('✅ Diretório criado: public/icons');
    }

    console.log('🎨 Gerando ícones PWA...\n');

    // Gerar cada tamanho
    for (const size of sizes) {
      const outputFile = path.join(outputDir, `icon-${size}x${size}.png`);
      
      try {
        // Configurar fundo baseado no tipo de arquivo e nome
        const isSVG = inputFile.endsWith('.svg');
        const isSociedadeNutraSimple = inputFile.includes('sociedade-nutra-simple');
        const isSociedadeNutra = inputFile.includes('sociedade-nutra') && !isSociedadeNutraSimple;
        // Se for sociedade nutra simple, manter fundo preto; se for sociedade nutra normal, manter laranja; caso contrário, usar preto
        const background = isSVG 
          ? (isSociedadeNutraSimple
              ? null // Manter fundo preto do SVG
              : isSociedadeNutra 
                ? null // Manter fundo laranja do SVG
                : { r: 0, g: 0, b: 0, alpha: 1 }) // Fundo preto para outros SVGs
          : null; // Manter fundo original para PNG/JPG
        
        const resizeOptions = {
          fit: 'contain',
          ...(background && { background })
        };

        await sharp(inputFile)
          .resize(size, size, {
            ...resizeOptions,
            kernel: sharp.kernel.lanczos3, // Melhor qualidade de redimensionamento
          })
          .png({
            quality: 100,
            compressionLevel: 9,
            palette: false, // Sem paleta para melhor qualidade
          })
          .toFile(outputFile);
        
        console.log(`✅ Gerado: icon-${size}x${size}.png`);
      } catch (error) {
        console.error(`❌ Erro ao gerar ${size}x${size}:`, error.message);
      }
    }

    console.log('\n🎉 Todos os ícones foram gerados com sucesso!');
    console.log(`📁 Localização: ${outputDir}`);
    console.log('\n📋 Próximos passos:');
    console.log('1. Verifique se os arquivos foram criados corretamente');
    console.log('2. Execute: npm run build');
    console.log('3. Teste o PWA no navegador');

  } catch (error) {
    console.error('❌ Erro ao gerar ícones:', error);
    process.exit(1);
  }
}

// Executar
generateIcons();

