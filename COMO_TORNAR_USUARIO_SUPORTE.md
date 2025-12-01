# 🔧 Como Tornar um Usuário em Suporte

## Passo a Passo

### 1. Criar o Usuário Normalmente

1. Acesse: `http://localhost:8080/auth`
2. Clique em "Cadastre-se" (se não tiver conta)
3. Preencha:
   - **Email:** (ex: suporte@gmail.com)
   - **Senha:** (ex: suporte123)
   - **Nome de usuário:** (ex: suporte)
4. Clique em "Cadastrar"

### 2. Tornar o Usuário em Suporte

Após criar o usuário, execute este SQL no Supabase:

```sql
-- Substitua 'SEU_EMAIL_AQUI' pelo email que você usou no cadastro
UPDATE profiles 
SET role = 'support'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'SEU_EMAIL_AQUI');
```

**Exemplo:** Se você usou `suporte@gmail.com`:
```sql
UPDATE profiles 
SET role = 'support'
WHERE user_id = (SELECT id FROM auth.users WHERE email = 'suporte@gmail.com');
```

### 3. Verificar se Funcionou

Execute este SQL para verificar:

```sql
SELECT 
  u.email,
  p.username,
  p.role,
  CASE 
    WHEN p.role = 'support' THEN '✅ É suporte'
    ELSE '❌ NÃO é suporte'
  END as status
FROM auth.users u
JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'SEU_EMAIL_AQUI';
```

### 4. Testar o Acesso

1. Faça logout (se estiver logado)
2. Acesse: `http://localhost:8080/support/login`
3. Faça login com o email e senha que você criou
4. Você deve ser redirecionado para `/support/dashboard`

## ✅ Funcionalidades que o Suporte Terá

Após tornar o usuário em suporte, ele terá acesso a:

1. ✅ **Dashboard de Suporte** (`/support/dashboard`)
   - Chat de Suporte
   - Gerenciamento de Usuários

2. ✅ **Posts com Destaque**
   - Posts do suporte aparecem destacados
   - Badge "Suporte" visível

3. ✅ **Moderação**
   - Pode deletar qualquer post
   - Pode deletar qualquer comentário
   - Pode deletar mensagens do chat

4. ✅ **Gerenciamento de Usuários**
   - Pode banir/desbanir usuários
   - Pode ver todos os perfis

5. ✅ **Chat de Suporte**
   - Pode responder mensagens dos alunos
   - Acesso a todas as conversas

## 🆘 Se Não Funcionar

1. Verifique se o email está correto no SQL
2. Verifique se o usuário foi criado (veja em Authentication > Users)
3. Verifique se o perfil existe (execute o SQL de verificação)
4. Abra o Console do navegador (F12) e veja os erros
5. Certifique-se de que executou a migração `apply-support-migration.sql`

