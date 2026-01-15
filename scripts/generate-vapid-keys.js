// Script para gerar chaves VAPID para push notifications
// Execute: node scripts/generate-vapid-keys.js

import crypto from 'crypto';

// Gerar chaves VAPID
function generateVAPIDKeys() {
  const curve = crypto.createECDH('prime256v1');
  curve.generateKeys();
  
  const publicKey = curve.getPublicKey();
  const privateKey = curve.getPrivateKey();
  
  // Converter para base64 URL-safe
  const publicKeyBase64 = publicKey.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
  
  const privateKeyBase64 = privateKey.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
  
  return {
    publicKey: publicKeyBase64,
    privateKey: privateKeyBase64
  };
}

const keys = generateVAPIDKeys();

console.log('\n🔑 Chaves VAPID geradas com sucesso!\n');
console.log('═══════════════════════════════════════════════════════════');
console.log('\n📋 PUBLIC KEY (use no frontend - .env):');
console.log('═══════════════════════════════════════════════════════════');
console.log(keys.publicKey);
console.log('\n📋 PRIVATE KEY (use no backend - Supabase Secrets):');
console.log('═══════════════════════════════════════════════════════════');
console.log(keys.privateKey);
console.log('\n═══════════════════════════════════════════════════════════\n');
console.log('📝 Próximos passos:');
console.log('1. Adicione a PUBLIC KEY no arquivo .env:');
console.log(`   VITE_VAPID_PUBLIC_KEY=${keys.publicKey}`);
console.log('\n2. Adicione a PRIVATE KEY nas Supabase Secrets:');
console.log('   supabase secrets set VAPID_PRIVATE_KEY=' + keys.privateKey);
console.log('\n3. Adicione também o VAPID_SUBJECT (seu email):');
console.log('   supabase secrets set VAPID_SUBJECT=mailto:seu-email@exemplo.com');
console.log('\n⚠️  IMPORTANTE: Mantenha a PRIVATE KEY segura! Nunca compartilhe ou commite no Git.\n');

