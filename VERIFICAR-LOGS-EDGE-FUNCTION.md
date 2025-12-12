# 📋 Como Verificar Logs da Edge Function

## 🎯 Objetivo:
Ver os logs da Edge Function `create-stripe-checkout` para identificar o erro exato.

---

## 📍 Passo a Passo:

### 1. Acesse o Supabase Dashboard
- Vá para: https://supabase.com/dashboard
- Faça login na sua conta

### 2. Selecione seu Projeto
- Clique no projeto: **vinicin0102's Project**

### 3. Vá para Edge Functions
- No menu lateral esquerdo, clique em **"Edge Functions"**
- Ou acesse diretamente: https://supabase.com/dashboard/project/[SEU_PROJECT_ID]/functions

### 4. Abra a Função
- Clique em **"create-stripe-checkout"** na lista de funções

### 5. Veja os Logs
- Clique na aba **"Logs"** (ou **"Invoke"** para testar)
- Você verá uma lista de execuções recentes
- Clique em uma execução para ver os detalhes

### 6. Procure por Erros
- Procure por mensagens em **vermelho** ou com **"error"**
- Procure por mensagens como:
  - `"Variáveis de ambiente faltando"`
  - `"Erro Stripe: ..."`
  - `"Erro de autenticação"`
  - `"Configuração do servidor incompleta"`

---

## 📸 O que procurar:

### ✅ Logs Normais:
```
[INFO] Criando checkout Stripe para: { planType: 'diamond', userId: '...' }
[INFO] Checkout criado com sucesso: { checkout_url: 'https://...' }
```

### ❌ Logs com Erro:
```
[ERROR] Variáveis de ambiente faltando: STRIPE_SECRET_KEY, STRIPE_PRICE_ID
[ERROR] Erro Stripe: Invalid API Key provided
[ERROR] Erro de autenticação: Token inválido
```

---

## 🔍 Depois de ver os logs:

1. **Copie a mensagem de erro completa**
2. **Veja o timestamp** (quando aconteceu)
3. **Verifique o status code** (400, 401, 500, etc.)
4. **Me envie essas informações** para eu ajudar a resolver!

---

## 💡 Dica:

Se não houver logs recentes:
- Tente fazer uma nova tentativa de assinatura
- Os logs aparecerão em tempo real
- Atualize a página para ver novos logs

---

**📋 Depois de verificar os logs, me envie a mensagem de erro exata!**

