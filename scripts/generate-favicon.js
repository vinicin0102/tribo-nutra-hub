#!/usr/bin/env node

/**
 * Script para gerar favicon.ico a partir do logo
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function generateFavicon() {
  try {
    const sharp = (await import('sharp')).default;

    // Tentar encontrar o arquivo de logo
    const possibleInputs = [
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
        break;
      }
    }

    if (!inputFile) {
      console.error('❌ Nenhum arquivo de logo encontrado!');
      process.exit(1);
    }

    const outputDir = path.join(__dirname, '../public');
    
    // Gerar favicon em múltiplos tamanhos (16x16, 32x32)
    const sizes = [16, 32];
    
    console.log('🎨 Gerando favicons...\n');

    for (const size of sizes) {
      const outputFile = path.join(outputDir, `favicon-${size}x${size}.png`);
      
      try {
        // Configurar fundo baseado no tipo de arquivo
        const isSVG = inputFile.endsWith('.svg');
        const isSociedadeNutra = inputFile.includes('sociedade-nutra');
        const background = isSVG 
          ? (isSociedadeNutra 
              ? null // Manter fundo laranja do SVG
              : { r: 0, g: 0, b: 0, alpha: 1 }) // Fundo preto para outros SVGs
          : null; // Manter fundo original para PNG/JPG
        
        const resizeOptions = {
          fit: 'contain',
          ...(background && { background })
        };

        await sharp(inputFile)
          .resize(size, size, resizeOptions)
          .png()
          .toFile(outputFile);
        
        console.log(`✅ Gerado: favicon-${size}x${size}.png`);
      } catch (error) {
        console.error(`❌ Erro ao gerar ${size}x${size}:`, error.message);
      }
    }

    // Gerar favicon.ico (usando 32x32 como base)
    const icoFile = path.join(outputDir, 'favicon.ico');
    try {
      // Configurar fundo
      const isSVG = inputFile.endsWith('.svg');
      const isSociedadeNutra = inputFile.includes('sociedade-nutra');
      const background = isSVG 
        ? (isSociedadeNutra 
            ? null // Manter fundo laranja do SVG
            : { r: 0, g: 0, b: 0, alpha: 1 }) // Fundo preto para outros SVGs
        : null;
      
      const resizeOptions = {
        fit: 'contain',
        ...(background && { background })
      };

      await sharp(inputFile)
        .resize(32, 32, resizeOptions)
        .toFormat('png')
        .toFile(icoFile.replace('.ico', '-temp.png'));
      
      // Renomear para .ico (na prática, muitos navegadores aceitam PNG como .ico)
      fs.renameSync(icoFile.replace('.ico', '-temp.png'), icoFile);
      console.log(`✅ Gerado: favicon.ico`);
    } catch (error) {
      console.error(`❌ Erro ao gerar favicon.ico:`, error.message);
    }

    console.log('\n🎉 Favicons gerados com sucesso!');
    console.log('💡 Nota: Para um .ico real com múltiplos tamanhos, use uma ferramenta online');

  } catch (error) {
    console.error('❌ Erro ao gerar favicons:', error);
    process.exit(1);
  }
}

generateFavicon();

