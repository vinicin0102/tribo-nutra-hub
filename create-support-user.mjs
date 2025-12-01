/**
 * Script para criar usuário de suporte
 * Execute: node create-support-user.mjs
 * 
 * IMPORTANTE: Este script requer a SERVICE_ROLE_KEY do Supabase
 * Para obter: Supabase Dashboard > Settings > API > service_role key
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Carregar variáveis de ambiente do .env
let SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY;

try {
  const envFile = readFileSync(join(__dirname, '.env'), 'utf-8');
  const envVars = envFile.split('\n').reduce((acc, line) => {
    const [key, ...valueParts] = line.split('=');
    if (key && valueParts.length > 0) {
      acc[key.trim()] = valueParts.join('=').trim().replace(/^["']|["']$/g, '');
    }
    return acc;
  }, {});

  SUPABASE_URL = envVars.VITE_SUPABASE_URL;
  SUPABASE_SERVICE_ROLE_KEY = envVars.SUPABASE_SERVICE_ROLE_KEY;
} catch (error) {
  console.error('❌ Erro ao ler arquivo .env:', error.message);
  console.log('\n💡 Você pode definir as variáveis diretamente no código ou usar:');
  console.log('   SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... node create-support-user.mjs\n');
}

// Permitir variáveis de ambiente do sistema
SUPABASE_URL = SUPABASE_URL || process.env.SUPABASE_URL;
SUPABASE_SERVICE_ROLE_KEY = SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('❌ Variáveis de ambiente não encontradas!');
  console.error('\n📋 Você precisa:');
  console.error('   1. Adicionar SUPABASE_SERVICE_ROLE_KEY no arquivo .env');
  console.error('   2. Ou executar: SUPABASE_SERVICE_ROLE_KEY=... node create-support-user.mjs');
  console.error('\n💡 Para obter a SERVICE_ROLE_KEY:');
  console.error('   Supabase Dashboard > Settings > API > service_role key');
  process.exit(1);
}

// Criar cliente com service role (tem permissões admin)
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function createSupportUser() {
  console.log('🔧 Criando usuário de suporte...\n');
  console.log('📧 Email: suporte@gmail.com');
  console.log('🔑 Senha: suporte123\n');

  try {
    // Verificar se o usuário já existe
    const { data: existingUsers, error: listError } = await supabase.auth.admin.listUsers();
    
    if (listError) {
      console.error('❌ Erro ao listar usuários:', listError.message);
      return;
    }

    const existingUser = existingUsers?.users?.find(u => u.email === 'suporte@gmail.com');

    if (existingUser) {
      console.log('⚠️  Usuário já existe. Atualizando perfil...');
      console.log(`   User ID: ${existingUser.id}\n`);

      // Atualizar role do perfil
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ 
          role: 'support',
          username: 'suporte',
          full_name: 'Equipe de Suporte'
        })
        .eq('user_id', existingUser.id);

      if (updateError) {
        console.error('❌ Erro ao atualizar perfil:', updateError.message);
        console.log('\n💡 Execute manualmente no SQL Editor:');
        console.log(`   UPDATE profiles SET role = 'support' WHERE user_id = '${existingUser.id}';`);
        return;
      }

      console.log('✅ Perfil atualizado com sucesso!');
      console.log('\n📋 Credenciais:');
      console.log('   Email: suporte@gmail.com');
      console.log('   Senha: suporte123');
      console.log('\n🔗 Acesse: http://localhost:8080/support/login');
      return;
    }

    // Criar novo usuário usando admin API
    console.log('👤 Criando novo usuário...');
    const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
      email: 'suporte@gmail.com',
      password: 'suporte123',
      email_confirm: true,
      user_metadata: {
        username: 'suporte',
        full_name: 'Equipe de Suporte'
      }
    });

    if (createError) {
      console.error('❌ Erro ao criar usuário:', createError.message);
      return;
    }

    if (!newUser.user) {
      console.error('❌ Usuário não foi criado');
      return;
    }

    console.log('✅ Usuário criado com sucesso!');
    console.log(`   User ID: ${newUser.user.id}\n`);

    // Aguardar um pouco para o trigger criar o perfil
    console.log('⏳ Aguardando criação do perfil...');
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Atualizar perfil com role de suporte
    const { error: updateError } = await supabase
      .from('profiles')
      .update({ 
        role: 'support',
        username: 'suporte',
        full_name: 'Equipe de Suporte'
      })
      .eq('user_id', newUser.user.id);

    if (updateError) {
      console.error('❌ Erro ao atualizar perfil:', updateError.message);
      console.log('\n💡 Execute manualmente no SQL Editor:');
      console.log(`   UPDATE profiles SET role = 'support' WHERE user_id = '${newUser.user.id}';`);
      return;
    }

    console.log('✅ Perfil de suporte configurado!');
    console.log('\n📋 Credenciais:');
    console.log('   Email: suporte@gmail.com');
    console.log('   Senha: suporte123');
    console.log('\n🔗 Acesse: http://localhost:8080/support/login');

  } catch (error) {
    console.error('❌ Erro:', error.message);
    console.log('\n💡 Alternativa: Use o arquivo create-support-user.sql no SQL Editor do Supabase');
  }
}

createSupportUser();

