import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';

// Carregar variáveis de ambiente do arquivo .env
const envFile = readFileSync('.env', 'utf-8');
const envVars = {};
envFile.split('\n').forEach(line => {
  const match = line.match(/^([^=]+)="?([^"]+)"?$/);
  if (match) {
    envVars[match[1].trim()] = match[2].trim();
  }
});

const SUPABASE_URL = envVars.VITE_SUPABASE_URL;
const SUPABASE_PUBLISHABLE_KEY = envVars.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!SUPABASE_URL || !SUPABASE_PUBLISHABLE_KEY) {
  console.error('❌ Erro: Variáveis de ambiente não encontradas!');
  console.log('Certifique-se de que o arquivo .env contém:');
  console.log('VITE_SUPABASE_URL=...');
  console.log('VITE_SUPABASE_PUBLISHABLE_KEY=...');
  process.exit(1);
}

console.log('🔌 Conectando ao Supabase...');
console.log('URL:', SUPABASE_URL);

const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);

async function testPost() {
  try {
    // 1. Testar conexão - listar posts existentes
    console.log('\n📋 Testando conexão - listando posts existentes...');
    const { data: existingPosts, error: listError } = await supabase
      .from('posts')
      .select('id, content, created_at')
      .order('created_at', { ascending: false })
      .limit(5);

    if (listError) {
      console.error('❌ Erro ao listar posts:', listError.message);
      return;
    }

    console.log(`✅ Conexão estabelecida! Encontrados ${existingPosts?.length || 0} posts.`);
    if (existingPosts && existingPosts.length > 0) {
      console.log('\n📝 Últimos posts:');
      existingPosts.forEach((post, index) => {
        console.log(`  ${index + 1}. ${post.content.substring(0, 50)}... (${post.id.substring(0, 8)}...)`);
      });
    }

    // 2. Criar usuário de teste e fazer login
    console.log('\n👤 Criando usuário de teste...');
    const testEmail = `teste-${Date.now()}@example.com`;
    const testPassword = 'teste123456';
    const testUsername = `usuario_teste_${Date.now()}`;

    const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
      email: testEmail,
      password: testPassword,
      options: {
        data: {
          username: testUsername,
        }
      }
    });

    if (signUpError) {
      console.error('❌ Erro ao criar usuário:', signUpError.message);
      
      // Tentar fazer login com um usuário existente
      console.log('\n🔄 Tentando fazer login...');
      const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email: testEmail,
        password: testPassword,
      });

      if (signInError) {
        console.error('❌ Erro ao fazer login:', signInError.message);
        console.log('\n💡 Dica: Para criar um post de teste, você precisa:');
        console.log('   1. Iniciar a aplicação com: npm run dev');
        console.log('   2. Criar uma conta ou fazer login');
        console.log('   3. Usar a interface para criar um post');
        return;
      }

      console.log('✅ Login realizado com sucesso!');
    } else {
      console.log('✅ Usuário de teste criado!');
      console.log('   Email:', testEmail);
      console.log('   Username:', testUsername);
    }

    // 3. Aguardar um pouco para o perfil ser criado
    await new Promise(resolve => setTimeout(resolve, 2000));

    // 4. Verificar sessão atual
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      console.error('❌ Nenhuma sessão ativa encontrada');
      return;
    }

    console.log('\n✅ Sessão ativa:', session.user.email);

    // 5. Criar post de teste
    console.log('\n📝 Criando post de teste...');
    const testPostContent = `🚀 Post de teste criado em ${new Date().toLocaleString('pt-BR')}\n\nEste é um post de teste para verificar a conexão com o banco de dados!`;

    const { data: newPost, error: postError } = await supabase
      .from('posts')
      .insert({
        user_id: session.user.id,
        content: testPostContent,
      })
      .select()
      .single();

    if (postError) {
      console.error('❌ Erro ao criar post:', postError.message);
      console.error('Detalhes:', postError);
      return;
    }

    console.log('✅ Post criado com sucesso!');
    console.log('\n📄 Detalhes do post:');
    console.log('   ID:', newPost.id);
    console.log('   Conteúdo:', newPost.content);
    console.log('   Criado em:', new Date(newPost.created_at).toLocaleString('pt-BR'));
    console.log('   Likes:', newPost.likes_count || 0);
    console.log('   Comentários:', newPost.comments_count || 0);

    // 6. Verificar se o post aparece na listagem
    console.log('\n🔍 Verificando se o post aparece na listagem...');
    const { data: verifyPosts } = await supabase
      .from('posts')
      .select('id, content')
      .eq('id', newPost.id)
      .single();

    if (verifyPosts) {
      console.log('✅ Post confirmado no banco de dados!');
    }

    console.log('\n🎉 Teste concluído com sucesso!');
    console.log('\n💡 Você pode ver o post na aplicação ao executar: npm run dev');

  } catch (error) {
    console.error('❌ Erro inesperado:', error);
  }
}

testPost();

