# 💳 Sistema de Pagamentos - Configuração Completa

## 📋 Índice
1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração do Banco de Dados](#configuração-do-banco-de-dados)
4. [Configuração do Mercado Pago](#configuração-do-mercado-pago)
5. [Criação das Edge Functions](#criação-das-edge-functions)
6. [Configuração de Webhooks](#configuração-de-webhooks)
7. [Variáveis de Ambiente](#variáveis-de-ambiente)
8. [Testando o Sistema](#testando-o-sistema)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Sistema completo de assinatura Diamond (R$ 197/mês) integrado com Mercado Pago.

### Fluxo do Pagamento:
1. Usuário clica em "Assinar Diamond"
2. Edge Function cria preferência no Mercado Pago
3. Usuário é redirecionado para checkout do Mercado Pago
4. Após pagamento, Mercado Pago envia webhook
5. Sistema atualiza assinatura e libera acesso

---

## ✅ Pré-requisitos

- [ ] Conta no [Mercado Pago](https://www.mercadopago.com.br)
- [ ] Projeto no Supabase configurado
- [ ] Supabase CLI instalado (`npm install -g supabase`)
- [ ] Node.js e npm instalados

---

## 🗄️ Configuração do Banco de Dados

### 1. Executar Migration SQL

No Supabase SQL Editor, execute o arquivo `setup-payments.sql`:

```bash
# Copiar conteúdo de setup-payments.sql e executar no Supabase SQL Editor
```

Isso criará:
- ✅ Tabela `subscriptions`
- ✅ Tabela `payments`
- ✅ Políticas RLS
- ✅ Funções de sincronização
- ✅ Triggers automáticos

### 2. Verificar Criação

Execute no SQL Editor:

```sql
SELECT * FROM subscriptions LIMIT 1;
SELECT * FROM payments LIMIT 1;
```

---

## 💰 Configuração do Mercado Pago

### 1. Criar Conta e Obter Credenciais

1. Acesse: https://www.mercadopago.com.br/developers/
2. Faça login ou crie uma conta
3. Vá em: **Suas integrações > Credenciais**
4. Copie suas credenciais de **Produção** e **Teste**

### 2. Credenciais Necessárias

Você precisará de:

```
Access Token (Produção): APP-XXXXXXXXXXXX
Access Token (Teste): TEST-XXXXXXXXXXXX
Public Key (Produção): APP_USR-XXXXXXXXXXXX
Public Key (Teste): TEST-XXXXXXXXXXXX
```

⚠️ **IMPORTANTE**: Use as credenciais de **TESTE** durante desenvolvimento!

### 3. Configurar Webhook no Mercado Pago

1. Vá em: **Suas integrações > Webhooks**
2. Clique em "Criar novo webhook"
3. Cole a URL do webhook:
   ```
   https://[seu-project-id].supabase.co/functions/v1/payment-webhook
   ```
4. Selecione eventos:
   - ✅ `payment`
   - ✅ `merchant_order`
5. Salve o webhook

---

## ⚡ Criação das Edge Functions

### 1. Estrutura de Pastas

Crie a estrutura:

```bash
supabase/
  functions/
    create-payment/
      index.ts
    payment-webhook/
      index.ts
```

### 2. Edge Function: `create-payment`

Crie `supabase/functions/create-payment/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { planType, userId } = await req.json();
    
    // Configuração do plano
    const plans = {
      diamond: {
        title: 'Plano Diamond - Nutra Elite',
        description: 'Acesso total à plataforma premium',
        unit_price: 197.00,
      }
    };

    const plan = plans[planType as keyof typeof plans];
    if (!plan) {
      throw new Error('Plano inválido');
    }

    // Criar preferência no Mercado Pago
    const mercadoPagoAccessToken = Deno.env.get('MERCADOPAGO_ACCESS_TOKEN')!;
    
    const preference = {
      items: [
        {
          title: plan.title,
          description: plan.description,
          unit_price: plan.unit_price,
          quantity: 1,
          currency_id: 'BRL',
        },
      ],
      payer: {
        email: req.headers.get('x-user-email') || 'user@example.com',
      },
      back_urls: {
        success: `${Deno.env.get('APP_URL')}/payment/success`,
        failure: `${Deno.env.get('APP_URL')}/payment/failure`,
        pending: `${Deno.env.get('APP_URL')}/payment/pending`,
      },
      auto_return: 'approved',
      external_reference: userId,
      notification_url: `${Deno.env.get('SUPABASE_URL')}/functions/v1/payment-webhook`,
    };

    const response = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${mercadoPagoAccessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(preference),
    });

    const data = await response.json();

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

### 3. Edge Function: `payment-webhook`

Crie `supabase/functions/payment-webhook/index.ts`:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  try {
    const { type, data } = await req.json();
    
    console.log('Webhook recebido:', type, data);

    if (type !== 'payment') {
      return new Response('OK', { status: 200 });
    }

    const mercadoPagoAccessToken = Deno.env.get('MERCADOPAGO_ACCESS_TOKEN')!;
    
    // Buscar informações do pagamento
    const paymentResponse = await fetch(
      `https://api.mercadopago.com/v1/payments/${data.id}`,
      {
        headers: {
          'Authorization': `Bearer ${mercadoPagoAccessToken}`,
        },
      }
    );

    const payment = await paymentResponse.json();
    
    if (payment.status === 'approved') {
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      );

      const userId = payment.external_reference;
      const now = new Date();
      const nextMonth = new Date(now);
      nextMonth.setMonth(nextMonth.getMonth() + 1);

      // Criar/atualizar assinatura
      const { error: subError } = await supabase
        .from('subscriptions')
        .upsert({
          user_id: userId,
          plan_type: 'diamond',
          status: 'active',
          payment_provider: 'mercadopago',
          payment_provider_payment_id: payment.id.toString(),
          payment_provider_subscription_id: payment.id.toString(),
          current_period_start: now.toISOString(),
          current_period_end: nextMonth.toISOString(),
          cancel_at_period_end: false,
        });

      if (subError) throw subError;

      // Registrar pagamento
      const { error: payError } = await supabase
        .from('payments')
        .insert({
          user_id: userId,
          amount: payment.transaction_amount,
          currency: payment.currency_id,
          status: 'approved',
          payment_provider: 'mercadopago',
          payment_provider_payment_id: payment.id.toString(),
          payment_method: payment.payment_method_id,
          metadata: payment,
        });

      if (payError) throw payError;

      console.log('Assinatura ativada com sucesso para user:', userId);
    }

    return new Response('OK', { status: 200 });
  } catch (error) {
    console.error('Erro no webhook:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
});
```

### 4. Deploy das Functions

```bash
# Login no Supabase
supabase login

# Link ao projeto
supabase link --project-ref [seu-project-id]

# Deploy das functions
supabase functions deploy create-payment
supabase functions deploy payment-webhook
```

---

## 🔧 Variáveis de Ambiente

### 1. No Supabase (Edge Functions)

Vá em: **Project Settings > Edge Functions > Secrets**

Adicione **APENAS ESTAS 2 VARIÁVEIS**:

```env
MERCADOPAGO_ACCESS_TOKEN=TEST-XXXXXXXXXX (use TEST- para desenvolvimento)
APP_URL=https://seuapp.vercel.app (ou seu domínio customizado)
```

⚠️ **IMPORTANTE**: 
- `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` **JÁ ESTÃO DISPONÍVEIS automaticamente** nas Edge Functions
- NÃO adicione variáveis com prefixo `SUPABASE_` - o sistema não permite e não é necessário!

### 2. No Arquivo .env.local (Frontend)

```env
VITE_SUPABASE_URL=https://[project-id].supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sua-anon-key
```

---

## 🧪 Testando o Sistema

### 1. Teste em Desenvolvimento

Use as credenciais de **TESTE** do Mercado Pago:

```env
MERCADOPAGO_ACCESS_TOKEN=TEST-XXXXXXXXXX
```

### 2. Cartões de Teste

Cartões fornecidos pelo Mercado Pago para teste:

| Cartão | Número | CVV | Validade | Resultado |
|--------|--------|-----|----------|-----------|
| VISA | 4509 9535 6623 3704 | 123 | 11/25 | APROVADO |
| Mastercard | 5031 7557 3453 0604 | 123 | 11/25 | APROVADO |
| VISA | 4013 5406 8274 6260 | 123 | 11/25 | RECUSADO |

### 3. Fluxo de Teste

1. Faça login na aplicação
2. Vá em `/upgrade`
3. Clique em "Assinar Plano Diamond"
4. Use um cartão de teste
5. Complete o pagamento
6. Verifique se foi redirecionado para `/payment/success`
7. Confirme que o badge Diamond apareceu
8. Teste acessos (Chat, IAs, Prêmios)

### 4. Verificar no Banco

```sql
-- Ver assinatura criada
SELECT * FROM subscriptions WHERE user_id = '[user-id]';

-- Ver pagamento registrado
SELECT * FROM payments WHERE user_id = '[user-id]';

-- Ver profile atualizado
SELECT subscription_plan, subscription_expires_at 
FROM profiles WHERE user_id = '[user-id]';
```

---

## 🐛 Troubleshooting

### Erro: "Access Token inválido"
- ✅ Verifique se copiou o token correto
- ✅ Use TEST-xxx para ambiente de teste
- ✅ Use APP-xxx para produção

### Webhook não está sendo chamado
- ✅ Verifique a URL do webhook no Mercado Pago
- ✅ Confirme que a Edge Function foi deployada
- ✅ Verifique logs: `supabase functions logs payment-webhook`

### Pagamento aprovado mas assinatura não ativada
- ✅ Verifique logs do webhook
- ✅ Confirme que `SUPABASE_SERVICE_ROLE_KEY` está correta
- ✅ Verifique políticas RLS das tabelas

### Badge Diamond não aparece
- ✅ Faça logout e login novamente
- ✅ Verifique se `subscription_plan` está como 'diamond' na tabela `profiles`
- ✅ Limpe cache do navegador

---

## 🚀 Indo para Produção

### 1. Checklist

- [ ] Trocar credenciais de TESTE por PRODUÇÃO
- [ ] Atualizar `APP_URL` para domínio real
- [ ] Configurar webhook com URL de produção
- [ ] Testar fluxo completo em produção
- [ ] Configurar monitoramento de pagamentos
- [ ] Criar rotina de expiração de assinaturas

### 2. Cron Job para Expirar Assinaturas

Configure no Supabase ou use serviço externo (cron-job.org):

```bash
# Chamar a cada 1 hora
curl -X POST 'https://[project-id].supabase.co/rest/v1/rpc/expire_subscriptions' \
  -H "apikey: [anon-key]" \
  -H "Content-Type: application/json"
```

---

## 📊 Monitoramento

### Dashboards Recomendados

1. **Mercado Pago**: Acompanhe transações
2. **Supabase**: Monitore edge functions e banco
3. **Vercel/Analytics**: Monitore conversões

### Métricas Importantes

- Taxa de conversão (visitas upgrade → pagamentos)
- Taxa de aprovação de pagamentos
- Churn (cancelamentos) mensal
- MRR (Monthly Recurring Revenue)

---

## 📝 Notas Importantes

1. **Segurança**: Nunca exponha `MERCADOPAGO_ACCESS_TOKEN` no frontend
2. **Webhooks**: São essenciais, configure corretamente
3. **Teste**: Sempre teste em ambiente de sandbox primeiro
4. **Logs**: Monitore logs das Edge Functions
5. **Backup**: Faça backup regular das tabelas de assinatura

---

## 🆘 Suporte

- Mercado Pago Developers: https://www.mercadopago.com.br/developers/
- Supabase Docs: https://supabase.com/docs
- GitHub Issues: [link do seu repo]

---

**Desenvolvido com ❤️ para Nutra Elite**

