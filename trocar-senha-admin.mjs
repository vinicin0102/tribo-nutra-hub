#!/usr/bin/env node

/**
 * Script para trocar a senha do admin
 * 
 * Uso:
 *   node trocar-senha-admin.mjs
 * 
 * Ou configure as variáveis de ambiente:
 *   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... node trocar-senha-admin.mjs
 */

import { createClient } from '@supabase/supabase-js';
import * as readline from 'readline';

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://oglakfbpuosrhhtbyprw.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const ADMIN_EMAIL = 'admin@gmail.com';
const NEW_PASSWORD = '@@Rod2004';

// Criar interface para ler input do usuário
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

function validateServiceRoleKey(key) {
  if (!key || typeof key !== 'string') return false;
  
  // Limpar espaços e quebras de linha
  const cleanKey = key.trim().replace(/\s/g, '');
  
  // SERVICE_ROLE_KEY geralmente começa com "eyJ" (JWT) e tem mais de 100 caracteres
  if (cleanKey.length < 100) return false;
  if (!cleanKey.startsWith('eyJ')) return false;
  
  return cleanKey;
}

async function main() {
  console.log('\n🔐 ============================================');
  console.log('   TROCAR SENHA DO ADMIN');
  console.log('============================================\n');

  // Verificar se SERVICE_ROLE_KEY foi fornecida
  let serviceRoleKey = SUPABASE_SERVICE_ROLE_KEY;
  
  if (!serviceRoleKey) {
    console.log('⚠️  Variável SUPABASE_SERVICE_ROLE_KEY não encontrada.');
    console.log('\n💡 Como obter a SERVICE_ROLE_KEY:');
    console.log('   1. Acesse: https://supabase.com/dashboard');
    console.log('   2. Selecione seu projeto');
    console.log('   3. Vá em: Settings → API');
    console.log('   4. Role até encontrar "Project API keys"');
    console.log('   5. Copie a chave "service_role" (⚠️ NÃO copie a "anon" key!)');
    console.log('   6. A service_role key é muito longa (mais de 100 caracteres)');
    console.log('   7. Ela começa com "eyJ..."\n');
    console.log('   Você pode:');
    console.log('   1. Fornecer via variável de ambiente:');
    console.log('      SUPABASE_SERVICE_ROLE_KEY=eyJ... node trocar-senha-admin.mjs');
    console.log('   2. Ou fornecer agora:\n');
    
    serviceRoleKey = await question('   Cole a SERVICE_ROLE_KEY aqui: ');
  }

  // Limpar e validar a key
  serviceRoleKey = validateServiceRoleKey(serviceRoleKey);
  
  if (!serviceRoleKey) {
    console.error('\n❌ SERVICE_ROLE_KEY inválida!');
    console.log('\n💡 A SERVICE_ROLE_KEY deve:');
    console.log('   - Ter mais de 100 caracteres');
    console.log('   - Começar com "eyJ"');
    console.log('   - Ser a chave "service_role" (NÃO a "anon" key)');
    console.log('\n📋 Como obter corretamente:');
    console.log('   1. Dashboard → Settings → API');
    console.log('   2. Procure por "service_role" (não "anon")');
    console.log('   3. Clique em "Reveal" para mostrar a key completa');
    console.log('   4. Copie TUDO (é uma string muito longa)\n');
    process.exit(1);
  }

  console.log(`\n✅ SERVICE_ROLE_KEY validada (${serviceRoleKey.length} caracteres)`);
  console.log(`📧 URL do Supabase: ${SUPABASE_URL}`);

  // Criar cliente Supabase com service_role (tem permissões admin)
  const supabaseAdmin = createClient(SUPABASE_URL, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  console.log(`\n📧 Email do admin: ${ADMIN_EMAIL}`);
  console.log(`🔑 Nova senha: ${NEW_PASSWORD}`);
  console.log('\n⏳ Testando conexão e atualizando senha...\n');

  try {
    // 1. Testar conexão primeiro (tentar listar usuários)
    console.log('🔍 Testando conexão com Supabase...');
    const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
    
    if (listError) {
      if (listError.message?.includes('Invalid API key') || listError.message?.includes('JWT')) {
        console.error('\n❌ ERRO: API Key inválida!');
        console.log('\n💡 Possíveis causas:');
        console.log('   1. Você copiou a "anon" key ao invés da "service_role" key');
        console.log('   2. A key foi cortada ou está incompleta');
        console.log('   3. A key tem espaços ou caracteres extras');
        console.log('\n📋 Como corrigir:');
        console.log('   1. Vá em: Dashboard → Settings → API');
        console.log('   2. Procure por "service_role" (não "anon")');
        console.log('   3. Clique em "Reveal" para mostrar a key completa');
        console.log('   4. Copie TUDO (é uma string muito longa, começa com "eyJ")');
        console.log('   5. Execute novamente: node trocar-senha-admin.mjs\n');
        throw new Error(`API Key inválida: ${listError.message}`);
      }
      throw new Error(`Erro ao listar usuários: ${listError.message}`);
    }

    console.log(`✅ Conexão estabelecida! Encontrados ${users.users.length} usuários no total.\n`);

    const adminUser = users.users.find(u => u.email === ADMIN_EMAIL);

    if (!adminUser) {
      console.error(`❌ Usuário com email ${ADMIN_EMAIL} não encontrado!`);
      console.log('\n💡 O usuário admin precisa existir primeiro.');
      console.log('   Você pode criar via Dashboard do Supabase ou criar manualmente.\n');
      process.exit(1);
    }

    console.log(`✅ Usuário encontrado: ${adminUser.id}`);
    console.log(`   Email: ${adminUser.email}`);
    console.log(`   Criado em: ${adminUser.created_at}\n`);

    // 2. Atualizar a senha usando admin.updateUserById
    const { data: updatedUser, error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      adminUser.id,
      { password: NEW_PASSWORD }
    );

    if (updateError) {
      throw new Error(`Erro ao atualizar senha: ${updateError.message}`);
    }

    console.log('✅ ============================================');
    console.log('   SENHA ATUALIZADA COM SUCESSO!');
    console.log('============================================\n');
    console.log(`📧 Email: ${ADMIN_EMAIL}`);
    console.log(`🔑 Nova senha: ${NEW_PASSWORD}`);
    console.log(`\n💡 Agora você pode fazer login com essas credenciais.\n`);

  } catch (error) {
    console.error('\n❌ Erro ao atualizar senha:', error.message);
    
    if (error.message?.includes('API Key inválida') || error.message?.includes('Invalid API key')) {
      console.log('\n💡 DICA: Use o método via Dashboard que é mais simples:');
      console.log('   1. Dashboard → Authentication → Users');
      console.log('   2. Encontre admin@gmail.com');
      console.log('   3. Clique → Update User → Defina senha: @@Rod2004\n');
    }
    
    console.error('\n📋 Detalhes do erro:');
    console.error(error);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main();

