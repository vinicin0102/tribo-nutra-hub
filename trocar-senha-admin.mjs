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

async function main() {
  console.log('\n🔐 ============================================');
  console.log('   TROCAR SENHA DO ADMIN');
  console.log('============================================\n');

  // Verificar se SERVICE_ROLE_KEY foi fornecida
  let serviceRoleKey = SUPABASE_SERVICE_ROLE_KEY;
  
  if (!serviceRoleKey) {
    console.log('⚠️  Variável SUPABASE_SERVICE_ROLE_KEY não encontrada.');
    console.log('   Você pode:');
    console.log('   1. Fornecer via variável de ambiente:');
    console.log('      SUPABASE_SERVICE_ROLE_KEY=... node trocar-senha-admin.mjs');
    console.log('   2. Ou fornecer agora:\n');
    
    serviceRoleKey = await question('   Digite a SERVICE_ROLE_KEY do Supabase: ');
    
    if (!serviceRoleKey || serviceRoleKey.trim() === '') {
      console.error('\n❌ SERVICE_ROLE_KEY é obrigatória!');
      console.log('\n💡 Como obter:');
      console.log('   1. Acesse: https://supabase.com/dashboard');
      console.log('   2. Vá em: Settings → API');
      console.log('   3. Copie a "service_role" key (NÃO a anon key!)\n');
      process.exit(1);
    }
  }

  // Criar cliente Supabase com service_role (tem permissões admin)
  const supabaseAdmin = createClient(SUPABASE_URL, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  });

  console.log(`\n📧 Email do admin: ${ADMIN_EMAIL}`);
  console.log(`🔑 Nova senha: ${NEW_PASSWORD}`);
  console.log('\n⏳ Atualizando senha...\n');

  try {
    // 1. Buscar o usuário pelo email
    const { data: users, error: listError } = await supabaseAdmin.auth.admin.listUsers();
    
    if (listError) {
      throw new Error(`Erro ao listar usuários: ${listError.message}`);
    }

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
    console.error('\n📋 Detalhes do erro:');
    console.error(error);
    process.exit(1);
  } finally {
    rl.close();
  }
}

main();

