# 💳 Integração Peper - Gateway de Pagamento

## 🎯 Visão Geral

Integração com o gateway de pagamento **Peper** para processar assinaturas do plano Diamond.

---

## 📋 Informações Necessárias

Para configurar a integração, você precisa me fornecer:

### 1. Credenciais da API Peper
- ✅ **API Key** ou **Token de API**
- ✅ **API Secret** (se necessário)
- ✅ **Merchant ID** ou **Client ID** (se necessário)
- Onde encontrar: Painel Peper → Configurações → API

### 2. URLs de Retorno
- ✅ **URL de Sucesso**: `https://seuapp.vercel.app/payment/success`
- ✅ **URL de Falha**: `https://seuapp.vercel.app/payment/failure`
- ✅ **URL de Webhook**: `https://[project-id].supabase.co/functions/v1/peper-webhook`

### 3. Informações do Produto
- ✅ **Valor**: R$ 197,00/mês
- ✅ **Nome do Plano**: "Plano Diamond - Nutra Elite"
- ✅ **Recorrência**: Mensal

---

## 🔧 Configuração no Supabase

### Secrets no Supabase

Vá em: **Project Settings** → **Edge Functions** → **Secrets**

Adicione as seguintes variáveis:

```env
PEPER_API_KEY=sua_api_key_aqui
PEPER_API_SECRET=sua_api_secret_aqui  # Se necessário
PEPER_MERCHANT_ID=seu_merchant_id     # Se necessário
APP_URL=https://seuapp.vercel.app
```

**IMPORTANTE:** 
- Substitua pelos valores reais da sua conta Peper
- Use credenciais de **TESTE** primeiro

---

## 💻 Edge Functions

### Criar: `supabase/functions/create-peper-checkout/index.ts`

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
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Obter dados do usuário
    const authHeader = req.headers.get('Authorization')!;
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      throw new Error('Usuário não autenticado');
    }

    // Buscar perfil do usuário
    const { data: profile } = await supabase
      .from('profiles')
      .select('email, full_name, username')
      .eq('user_id', user.id)
      .single();

    const { planType } = await req.json();

    // Configuração do plano
    const plans = {
      diamond: {
        name: 'Plano Diamond - Nutra Elite',
        amount: 19700, // R$ 197,00 em centavos
      }
    };

    const plan = plans[planType as keyof typeof plans];
    if (!plan) {
      throw new Error('Plano inválido');
    }

    // Criar checkout na Peper
    const peperApiKey = Deno.env.get('PEPER_API_KEY')!;
    const peperApiSecret = Deno.env.get('PEPER_API_SECRET');
    const appUrl = Deno.env.get('APP_URL')!;
    
    // TODO: Adaptar conforme a API da Peper
    // Exemplo genérico (precisa ser ajustado conforme documentação real)
    const checkoutData = {
      customer: {
        name: profile?.full_name || profile?.username || 'Cliente',
        email: profile?.email || user.email,
      },
      items: [
        {
          name: plan.name,
          amount: plan.amount,
          quantity: 1,
        }
      ],
      subscription: {
        interval: 'monthly',
        interval_count: 1,
      },
      success_url: `${appUrl}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appUrl}/payment/failure`,
      metadata: {
        user_id: user.id,
        plan_type: planType,
      }
    };

    // TODO: Ajustar URL e headers conforme documentação da Peper
    const response = await fetch('https://api.peper.com.br/v1/checkouts', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${peperApiKey}`,
        'Content-Type': 'application/json',
        // Adicionar outros headers se necessário
      },
      body: JSON.stringify(checkoutData),
    });

    if (!response.ok) {
      const errorData = await response.text();
      throw new Error(`Erro Peper: ${errorData}`);
    }

    const data = await response.json();

    return new Response(JSON.stringify({ 
      checkout_url: data.url || data.checkout_url,
      checkout_id: data.id,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Erro ao criar checkout:', error);
    return new Response(JSON.stringify({ 
      error: error.message || 'Erro ao processar pagamento' 
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
```

### Criar: `supabase/functions/peper-webhook/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  try {
    const payload = await req.json();
    
    console.log('Webhook Peper recebido:', payload);

    // TODO: Verificar assinatura do webhook (se a Peper fornecer)
    // const signature = req.headers.get('x-peper-signature');
    // if (!verifySignature(payload, signature)) {
    //   return new Response('Invalid signature', { status: 401 });
    // }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { type, data } = payload;

    // TODO: Ajustar conforme os eventos da API Peper
    // Processar diferentes tipos de eventos
    switch (type) {
      case 'checkout.completed':
      case 'subscription.created':
      case 'payment.succeeded': {
        const userId = data.metadata?.user_id;
        const planType = data.metadata?.plan_type || 'diamond';

        if (!userId) {
          console.error('user_id não encontrado no metadata');
          break;
        }

        const now = new Date();
        const nextMonth = new Date(now);
        nextMonth.setMonth(nextMonth.getMonth() + 1);

        // Criar/atualizar assinatura
        const { error: subError } = await supabase
          .from('subscriptions')
          .upsert({
            user_id: userId,
            plan_type: planType,
            status: 'active',
            payment_provider: 'peper',
            payment_provider_payment_id: data.id,
            payment_provider_subscription_id: data.subscription_id || data.id,
            payment_provider_customer_id: data.customer_id,
            current_period_start: now.toISOString(),
            current_period_end: nextMonth.toISOString(),
            cancel_at_period_end: false,
            updated_at: now.toISOString(),
          }, {
            onConflict: 'user_id'
          });

        if (subError) {
          console.error('Erro ao criar assinatura:', subError);
          throw subError;
        }

        // Registrar pagamento
        const { error: payError } = await supabase
          .from('payments')
          .insert({
            user_id: userId,
            amount: data.amount / 100, // Converter centavos para reais
            currency: 'BRL',
            status: 'approved',
            payment_provider: 'peper',
            payment_provider_payment_id: data.id,
            payment_method: data.payment_method,
            metadata: data,
          });

        if (payError) {
          console.error('Erro ao registrar pagamento:', payError);
          throw payError;
        }

        console.log('Assinatura ativada com sucesso para user:', userId);
        break;
      }

      case 'subscription.cancelled':
      case 'subscription.expired': {
        const userId = data.metadata?.user_id;
        
        if (userId) {
          await supabase
            .from('subscriptions')
            .update({
              status: 'cancelled',
              cancel_at_period_end: true,
              updated_at: new Date().toISOString(),
            })
            .eq('user_id', userId);
        }
        break;
      }

      case 'payment.failed':
      case 'payment.refunded': {
        const userId = data.metadata?.user_id;
        
        if (userId) {
          await supabase
            .from('payments')
            .insert({
              user_id: userId,
              amount: data.amount / 100,
              currency: 'BRL',
              status: type === 'payment.failed' ? 'rejected' : 'refunded',
              payment_provider: 'peper',
              payment_provider_payment_id: data.id,
              metadata: data,
            });
        }
        break;
      }

      default:
        console.log('Evento não processado:', type);
    }

    return new Response('OK', { status: 200 });
  } catch (error) {
    console.error('Erro no webhook:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
```

---

## 🚀 Deploy das Functions

```bash
# Login no Supabase
supabase login

# Link ao projeto
supabase link --project-ref [seu-project-id]

# Deploy das functions
supabase functions deploy create-peper-checkout
supabase functions deploy peper-webhook
```

---

## 🔗 Configurar Webhook na Peper

1. No painel Peper, vá em **"Configurações"** → **"Webhooks"**
2. Clique em **"Adicionar Webhook"**
3. Cole a URL:
   ```
   https://[seu-project-id].supabase.co/functions/v1/peper-webhook
   ```
4. Selecione os eventos necessários
5. Salve o webhook

---

## 📱 Atualizar Frontend

O hook `usePayments.ts` já está preparado. Apenas precisa atualizar o nome da função:

```typescript
// Em src/hooks/usePayments.ts
export function useCreatePaymentPreference() {
  // ...
  const { data, error } = await supabase.functions.invoke('create-peper-checkout', {
    body: { planType },
  });
  // ...
}
```

---

## 📝 Próximos Passos

1. **Você:** Me fornecer:
   - API Key da Peper
   - API Secret (se necessário)
   - Merchant ID (se necessário)
   - URL da documentação da API Peper
   - Exemplos de requisições/respostas

2. **Eu:** Ajustar o código conforme a documentação real da Peper

3. **Você:** Testar o fluxo completo

---

## ❓ Informações que Preciso

Para adaptar o código corretamente, preciso saber:

1. **URL Base da API Peper**
   - Exemplo: `https://api.peper.com.br/v1`

2. **Formato de Autenticação**
   - Bearer Token?
   - API Key no header?
   - Basic Auth?

3. **Estrutura de Requisição para Criar Checkout**
   - Quais campos são obrigatórios?
   - Formato do payload?

4. **Estrutura de Resposta**
   - Como vem a URL do checkout?
   - Quais campos retorna?

5. **Eventos de Webhook**
   - Quais eventos são enviados?
   - Formato do payload?

6. **Métodos de Pagamento Suportados**
   - Cartão de crédito?
   - Pix?
   - Boleto?

---

**🎯 Me envie essas informações e eu adapto tudo!**

