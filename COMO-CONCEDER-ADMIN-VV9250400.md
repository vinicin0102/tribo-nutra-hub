# ✅ Conceder Admin e 70.000 Pontos para vv9250400@gmail.com

## 🎯 O que será feito:

1. ✅ **70.000 pontos** para o usuário
2. ✅ **Role: admin** (acesso ao painel admin e suporte)
3. ✅ **Plano: diamond** (acesso completo)
4. ✅ **Email sincronizado** no perfil

---

## 📋 Passo a Passo:

### 1. Acesse o Supabase SQL Editor
- Vá para: https://supabase.com/dashboard
- Selecione seu projeto
- Vá em **SQL Editor** (menu lateral)

### 2. Execute o Script
- Abra o arquivo: `conceder-admin-e-pontos-vv9250400.sql`
- Copie todo o conteúdo
- Cole no SQL Editor do Supabase
- Clique em **"Run"** ou pressione **Ctrl+Enter**

### 3. Verifique o Resultado
- O script mostrará uma mensagem de sucesso
- A última query mostrará os dados atualizados:
  - User ID
  - Email
  - Pontos: 70.000
  - Role: admin
  - Plano: diamond

---

## ✅ O que o script faz:

1. **Busca o usuário** pelo email `vv9250400@gmail.com` na tabela `auth.users`
2. **Verifica se o perfil existe** na tabela `profiles`
3. **Se não existe:** Cria o perfil com:
   - 70.000 pontos
   - Role: admin
   - Plano: diamond
4. **Se existe:** Atualiza o perfil com:
   - 70.000 pontos
   - Role: admin
   - Plano: diamond
5. **Mostra o resultado** final

---

## 🔍 Verificação:

Depois de executar, você verá algo assim:

```
user_id                              | username | email                | points | role  | subscription_plan
-------------------------------------+----------+----------------------+--------+-------+------------------
abc123-def456-ghi789-...            | vv9250400| vv9250400@gmail.com | 70000  | admin | diamond
```

---

## 🎉 Pronto!

Após executar o script:
- ✅ O usuário terá **70.000 pontos**
- ✅ Terá acesso ao **painel admin** (menu no header)
- ✅ Terá acesso ao **painel de suporte** (`/support/dashboard`)
- ✅ Terá **plano diamond** (acesso completo)

---

## ⚠️ Importante:

- O usuário precisa **fazer logout e login novamente** para ver as mudanças
- O cache do navegador pode precisar ser limpo
- Se o email não existir em `auth.users`, o script mostrará um erro

---

**📋 Execute o script `conceder-admin-e-pontos-vv9250400.sql` no Supabase SQL Editor!**

