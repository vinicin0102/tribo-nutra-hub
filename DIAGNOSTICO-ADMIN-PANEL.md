# 🔍 Diagnóstico do Painel Admin

## Passo 1: Verificar se o SQL foi executado

1. Abra o **Supabase Dashboard**
2. Vá em **SQL Editor**
3. Execute o arquivo `test-admin-functions.sql`
4. Verifique se retorna resultados:
   - ✅ Se retornar dados = funções existem
   - ❌ Se retornar vazio = funções não foram criadas

## Passo 2: Executar o SQL de correção

1. No **Supabase SQL Editor**, execute o arquivo `fix-admin-panel-functions-v2.sql`
2. Verifique se aparece a mensagem: "Funções do painel administrativo corrigidas com sucesso!"

## Passo 3: Verificar no Console do Navegador

1. Abra o app no navegador
2. Pressione **F12** para abrir o DevTools
3. Vá na aba **Console**
4. Tente banir/mutar um usuário
5. Veja os logs:
   - `Banindo usuário:` - mostra os parâmetros
   - `Erro ao banir usuário:` - mostra o erro (se houver)
   - `Detalhes do erro:` - mostra detalhes completos

## Passo 4: Verificar Permissões

1. Certifique-se de estar logado com `admin@gmail.com`
2. Verifique se o email está correto (sem espaços, case-sensitive)

## Passo 5: Testar Manualmente no SQL

Execute no Supabase SQL Editor (substitua `USER_ID_AQUI` por um ID real):

```sql
-- Ver usuários disponíveis
SELECT user_id, username FROM profiles LIMIT 5;

-- Testar banir (substitua pelo user_id real)
SELECT ban_user_temporary('USER_ID_AQUI'::UUID, 3);

-- Verificar se foi banido
SELECT user_id, username, is_banned, banned_until 
FROM profiles 
WHERE user_id = 'USER_ID_AQUI'::UUID;
```

## Problemas Comuns

### ❌ Erro: "function does not exist"
**Solução:** Execute `fix-admin-panel-functions-v2.sql`

### ❌ Erro: "permission denied"
**Solução:** Verifique se está logado com `admin@gmail.com`

### ❌ Erro: "column does not exist"
**Solução:** Execute `fix-admin-panel-functions-v2.sql` (ele cria as colunas automaticamente)

### ❌ Função executa mas não atualiza
**Solução:** 
1. Verifique se o `user_id` está correto
2. Verifique se o usuário existe na tabela `profiles`
3. Verifique RLS policies

## Verificar RLS Policies

Execute no SQL Editor:

```sql
-- Ver políticas da tabela profiles
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'profiles';
```

## Teste Completo

1. Execute `fix-admin-panel-functions-v2.sql`
2. Execute `test-admin-functions.sql` para verificar
3. Tente banir/mutar um usuário no painel admin
4. Verifique o console do navegador para erros
5. Se ainda não funcionar, envie:
   - Screenshot do erro no console
   - Resultado do `test-admin-functions.sql`
   - Mensagem de erro completa

