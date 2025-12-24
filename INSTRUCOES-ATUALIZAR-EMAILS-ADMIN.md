# 📧 Instruções para Atualizar Emails Admin no Banco de Dados

## Problema
O email `auxiliodp1@gmail.com` foi adicionado às listas de admin no frontend (`useAdmin.ts` e `useSupport.ts`), mas as funções RPC no Supabase ainda verificam apenas emails antigos, causando erro de permissão ao tentar alterar planos ou realizar outras ações administrativas.

## Solução
Execute o script SQL `atualizar-emails-admin-funcoes-rpc.sql` no Supabase para atualizar todas as funções RPC e políticas RLS.

## Passo a Passo

### 1. Acessar o Supabase Dashboard
1. Acesse https://supabase.com/dashboard
2. Selecione o projeto da Sociedade Nutra
3. No menu lateral, clique em **SQL Editor**

### 2. Executar o Script
1. No SQL Editor, clique em **New query**
2. Abra o arquivo `atualizar-emails-admin-funcoes-rpc.sql` deste repositório
3. Copie TODO o conteúdo do arquivo
4. Cole no SQL Editor do Supabase
5. Clique em **Run** (ou pressione `Ctrl+Enter` / `Cmd+Enter`)

### 3. Verificar Resultado
Após executar, você deve ver:
- Uma mensagem de sucesso
- Uma lista das funções atualizadas:
  - `change_user_plan_admin`
  - `update_user_points_admin`
  - `unlock_mentoria_for_user`
  - `unban_user_admin`
  - `unmute_user_admin`
  - `is_admin`

## O que o Script Faz

O script atualiza as seguintes verificações de admin em todas as funções RPC:

**Emails Admin Atualizados:**
- ✅ `admin02@gmail.com`
- ✅ `vv9250400@gmail.com`
- ✅ `auxiliodp1@gmail.com`

**Funções Atualizadas:**
1. `change_user_plan_admin` - Permite alterar planos de usuários
2. `update_user_points_admin` - Permite atualizar pontos de usuários
3. `unlock_mentoria_for_user` - Permite liberar mentoria para usuários
4. `unban_user_admin` - Permite desbanir usuários
5. `unmute_user_admin` - Permite desmutar usuários
6. `is_admin()` - Função auxiliar usada em políticas RLS

**Políticas RLS Atualizadas:**
- Política de deleção de mensagens de suporte (`support_chat`)

## Teste Após Executar

1. Faça logout e login novamente com o email `auxiliodp1@gmail.com`
2. Tente alterar o plano de um usuário no painel administrativo
3. Verifique se a ação é concluída com sucesso (sem erro de permissão)

## Importante

⚠️ **Execute este script apenas uma vez!** O script usa `CREATE OR REPLACE FUNCTION`, então é seguro executar múltiplas vezes, mas não é necessário.

✅ **O deploy no Vercel já foi feito automaticamente** quando fizemos o push das alterações do frontend. Agora só falta atualizar o banco de dados.

## Notas

- As funções `ban_user_temporary` e `mute_user` não têm verificações de email porque usam `SECURITY DEFINER` e a verificação é feita no frontend (que já foi atualizada).
- As verificações também consideram o campo `role` do perfil, então usuários com `role = 'admin'` continuarão funcionando normalmente.

