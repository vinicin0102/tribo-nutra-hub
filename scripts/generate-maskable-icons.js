#!/usr/bin/env node

/**
 * Script para gerar ícones maskable (com padding seguro)
 * Ícones maskable precisam ter conteúdo seguro dentro de 80% da área
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Tamanhos necessários para maskable
const sizes = [192, 512];

async function generateMaskableIcons() {
  try {
    const sharp = (await import('sharp')).default;

    // Tentar encontrar o arquivo de logo (prioridade: PNG/JPG, depois SVG)
    const possibleInputs = [
      path.join(__dirname, '../public/logo-sociedade-nutra.png'),
      path.join(__dirname, '../public/logo-sociedade-nutra.jpg'),
      path.join(__dirname, '../public/logo-sociedade-nutra.jpeg'),
      path.join(__dirname, '../public/logo.png'),
      path.join(__dirname, '../public/logo.jpg'),
      path.join(__dirname, '../public/logo.jpeg'),
      path.join(__dirname, '../public/logo-sociedade-nutra-simple.svg'),
      path.join(__dirname, '../public/logo-sociedade-nutra.svg'),
      path.join(__dirname, '../public/logo-nutra-club.svg'),
      path.join(__dirname, '../public/logo.svg'),
    ];

    let inputFile = null;
    for (const file of possibleInputs) {
      if (fs.existsSync(file)) {
        inputFile = file;
        break;
      }
    }

    if (!inputFile) {
      console.error('❌ Nenhum arquivo de logo encontrado!');
      process.exit(1);
    }

    const outputDir = path.join(__dirname, '../public/icons');
    
    console.log('🎨 Gerando ícones maskable (com padding seguro)...\n');

    for (const size of sizes) {
      const outputFile = path.join(outputDir, `icon-maskable-${size}x${size}.png`);
      
      try {
        // Criar ícone com padding seguro (80% da área)
        // O conteúdo importante deve estar dentro de 80% do centro
        const padding = Math.floor(size * 0.1); // 10% de padding em cada lado = 80% área segura
        const contentSize = Math.floor(size * 0.8);
        
        // Configurar fundo baseado no tipo de arquivo
        const isSVG = inputFile.endsWith('.svg');
        const isSociedadeNutraSimple = inputFile.includes('sociedade-nutra-simple');
        const isSociedadeNutra = inputFile.includes('sociedade-nutra') && !isSociedadeNutraSimple;
        const isPNG = inputFile.endsWith('.png') || inputFile.endsWith('.jpg') || inputFile.endsWith('.jpeg');
        
        // Se for PNG/JPG, manter fundo original; se for SVG sociedade nutra, usar laranja; caso contrário, preto
        const bgColor = isPNG
          ? null // Manter fundo original para PNG/JPG
          : (isSociedadeNutraSimple || isSociedadeNutra)
            ? { r: 255, g: 107, b: 0, alpha: 1 } // Fundo laranja
            : { r: 0, g: 0, b: 0, alpha: 1 }; // Fundo preto
        
        const resizeOptions = {
          fit: 'contain',
          kernel: sharp.kernel.lanczos3,
          ...(bgColor && { background: bgColor })
        };
        
        await sharp(inputFile)
          .resize(contentSize, contentSize, resizeOptions)
          .extend({
            top: padding,
            bottom: padding,
            left: padding,
            right: padding,
            background: bgColor || { r: 255, g: 255, b: 255, alpha: 1 }
          })
          .png({
            quality: 100,
            compressionLevel: 9,
          })
          .toFile(outputFile);
        
        console.log(`✅ Gerado: icon-maskable-${size}x${size}.png`);
      } catch (error) {
        console.error(`❌ Erro ao gerar ${size}x${size}:`, error.message);
      }
    }

    console.log('\n🎉 Ícones maskable gerados com sucesso!');
    console.log('💡 Estes ícones têm padding seguro para Android');

  } catch (error) {
    console.error('❌ Erro ao gerar ícones maskable:', error);
    process.exit(1);
  }
}

generateMaskableIcons();

