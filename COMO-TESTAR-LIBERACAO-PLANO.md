# 🧪 Como Testar a Liberação Imediata do Plano

## 📋 PASSO A PASSO COMPLETO:

### 1. **Execute o SQL Primeiro (OBRIGATÓRIO):**

1. Abra o Supabase Dashboard: https://supabase.com/dashboard
2. Selecione seu projeto
3. Clique em **"SQL Editor"**
4. Abra o arquivo: `permitir-usuario-atualizar-proprio-plano.sql`
5. Copie TODO o conteúdo (Ctrl+A, Ctrl+C)
6. Cole no SQL Editor (Ctrl+V)
7. Execute (RUN ou Ctrl+Enter)
8. Verifique se apareceu: **"✅ Policy criada!"**

---

### 2. **Aguarde o Deploy do Código:**

- Aguarde 2-3 minutos para o Vercel fazer o deploy
- Você pode verificar em: https://vercel.com/dashboard

---

### 3. **Limpe o Cache do Navegador:**

- Pressione **Ctrl+Shift+R** (Windows/Linux)
- Ou **Cmd+Shift+R** (Mac)
- Isso força o navegador a carregar a versão mais recente

---

### 4. **Faça Login no App:**

- Acesse: `sociedadenutra.com`
- Faça login com sua conta

---

### 5. **Teste o Pagamento:**

#### Opção A: Teste Real (Recomendado)
1. Vá para a página de Upgrade: `/upgrade`
2. Selecione um plano (ex: Mensal)
3. Clique em **"Assinar"**
4. Complete o pagamento no Stripe
5. Você será redirecionado para `/payment/success`

#### Opção B: Teste com Cartão de Teste do Stripe
1. Vá para `/upgrade`
2. Clique em **"Assinar"**
3. No Stripe, use um cartão de teste:
   - **Número:** `4242 4242 4242 4242`
   - **Validade:** Qualquer data futura (ex: 12/25)
   - **CVC:** Qualquer 3 dígitos (ex: 123)
   - **CEP:** Qualquer CEP válido (ex: 12345-678)
4. Complete o pagamento
5. Você será redirecionado para `/payment/success`

---

### 6. **O Que Deve Acontecer:**

Quando você chegar na página `/payment/success`:

1. **Deve aparecer:**
   - "Atualizando seu plano..." (com ícone girando)
   - Depois: "Plano Diamond ativado com sucesso!" (toast verde)

2. **No Console (F12):**
   - "🔄 Verificando e atualizando plano imediatamente..."
   - "💎 Atualizando plano para Diamond imediatamente..."
   - "✅ Plano atualizado para Diamond com sucesso!"

3. **Você deve ter acesso:**
   - Chat da comunidade (pode enviar mensagens)
   - IAs de Copy e Criativo
   - Resgate de prêmios
   - Badge Diamond no perfil

---

### 7. **Verificar se Funcionou:**

#### A. Verificar no Banco de Dados:

Execute este SQL no Supabase SQL Editor:

```sql
-- Substitua 'SEU_EMAIL_AQUI' pelo seu email
SELECT 
  u.email,
  p.subscription_plan,
  p.subscription_expires_at,
  p.updated_at
FROM auth.users u
JOIN profiles p ON p.user_id = u.id
WHERE u.email = 'SEU_EMAIL_AQUI';
```

**Deve mostrar:**
- `subscription_plan = 'diamond'`
- `subscription_expires_at = data futura`
- `updated_at = data/hora recente`

#### B. Verificar no App:

1. Vá para o seu perfil (`/profile`)
2. Deve aparecer "💎 Diamond" no seu perfil
3. Vá para o chat (`/chat`)
4. Deve conseguir enviar mensagens
5. Vá para as IAs
6. Deve conseguir usar as IAs

---

### 8. **Se Não Funcionar:**

#### Verifique o Console (F12):

Procure por:
- **"❌ Erro ao atualizar plano"**
- Veja o código do erro:
  - `42501` = Erro de permissão (RLS)
  - `PGRST116` = Registro não encontrado
  - Outro código = Ver mensagem de erro

#### Se o erro for 42501 (permissão):

1. Execute o SQL `permitir-usuario-atualizar-proprio-plano.sql` novamente
2. Verifique se a policy foi criada:
   ```sql
   SELECT policyname 
   FROM pg_policies 
   WHERE tablename = 'profiles' 
   AND policyname = 'Users can update own subscription plan';
   ```
3. Deve retornar uma linha

#### Se não houver erro mas não atualizar:

1. Verifique se você está logado com a mesma conta que fez o pagamento
2. Verifique se o `user_id` está correto
3. Verifique se a tabela `profiles` tem o registro do usuário

---

### 9. **Teste Rápido (Sem Pagamento Real):**

Se você quiser testar sem fazer um pagamento real:

1. Execute este SQL no Supabase (substitua `SEU_EMAIL_AQUI`):

```sql
-- Atualizar plano manualmente para testar
UPDATE profiles
SET 
  subscription_plan = 'diamond',
  subscription_expires_at = NOW() + INTERVAL '30 days',
  updated_at = NOW()
WHERE user_id = (
  SELECT id FROM auth.users WHERE email = 'SEU_EMAIL_AQUI'
);
```

2. Limpe o cache (Ctrl+Shift+R)
3. Recarregue a página
4. Deve aparecer "💎 Diamond" no seu perfil

---

## ✅ CHECKLIST DE TESTE:

- [ ] SQL `permitir-usuario-atualizar-proprio-plano.sql` executado
- [ ] Policy criada verificada
- [ ] Cache limpo
- [ ] Login feito
- [ ] Pagamento realizado (ou teste manual)
- [ ] Página `/payment/success` carregou
- [ ] Toast "Plano Diamond ativado" apareceu
- [ ] Console mostra "✅ Plano atualizado"
- [ ] Perfil mostra "💎 Diamond"
- [ ] Chat funciona (pode enviar mensagens)
- [ ] IAs funcionam

---

## 🎯 RESULTADO ESPERADO:

Após o pagamento, você deve:
1. ✅ Ver "Plano Diamond ativado com sucesso!" imediatamente
2. ✅ Ter acesso ao chat da comunidade
3. ✅ Ter acesso às IAs
4. ✅ Ver badge Diamond no perfil
5. ✅ Poder resgatar prêmios

---

**🚀 Execute o SQL primeiro, depois teste fazendo um pagamento!**

