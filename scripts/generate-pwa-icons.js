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

    const inputFile = path.join(__dirname, '../public/favicon.svg');
    const outputDir = path.join(__dirname, '../public/icons');

    // Verificar se o arquivo SVG existe
    if (!fs.existsSync(inputFile)) {
      console.error(`❌ Arquivo não encontrado: ${inputFile}`);
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
        await sharp(inputFile)
          .resize(size, size, {
            fit: 'contain',
            background: { r: 26, g: 26, b: 26, alpha: 1 } // Fundo #1a1a1a
          })
          .png()
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

