# 💳 Integração Stripe - Configuração Completa

## 🎯 Visão Geral

O Stripe é um dos gateways de pagamento mais populares e confiáveis do mundo, com excelente suporte para assinaturas recorrentes.

### Vantagens do Stripe:
- ✅ Suporte global (mais de 40 países)
- ✅ Excelente para assinaturas recorrentes
- ✅ Dashboard completo e intuitivo
- ✅ Webhooks em tempo real
- ✅ Taxas competitivas
- ✅ Suporte a múltiplos métodos de pagamento

---

## 📋 Passo a Passo de Configuração

### 1️⃣ Criar Conta no Stripe

1. Acesse: https://stripe.com/
2. Clique em **"Start now"** ou **"Sign up"**
3. Preencha o cadastro
4. Confirme e-mail
5. Complete o onboarding

### 2️⃣ Obter Chaves de API

1. No Dashboard do Stripe, vá em **"Developers"** → **"API keys"**
2. Você verá duas chaves:
   - **Publishable key** (começa com `pk_test_...` ou `pk_live_...`)
   - **Secret key** (começa com `sk_test_...` ou `sk_live_...`)

⚠️ **IMPORTANTE:**
- Use `test` para desenvolvimento/testes
- Use `live` para produção
- **NUNCA** compartilhe a Secret key publicamente!

### 3️⃣ Criar Produto e Preço no Stripe

1. No Dashboard, vá em **"Products"** → **"Add product"**
2. Preencha:
   - **Name:** Plano Diamond - Nutra Elite
   - **Description:** Acesso total à plataforma premium
   - **Pricing model:** Standard pricing
   - **Price:** R$ 197,00
   - **Billing period:** Monthly (recorrente)
3. Clique em **"Save product"**
4. **Copie o Price ID** (ex: `price_abc123xyz`)

---

## 🔧 Configuração no Supabase

### 1. Secrets no Supabase

Vá em: **Project Settings** → **Edge Functions** → **Secrets**

Adicione as seguintes variáveis:

```env
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
STRIPE_PRICE_ID=price_abc123xyz
APP_URL=https://seuapp.vercel.app
```

**IMPORTANTE:**
- Substitua pelos valores reais do seu Stripe
- Use `sk_test_` e `pk_test_` para testes
- Use `sk_live_` e `pk_live_` para produção

---

## 💻 Edge Functions

### Criar: `supabase/functions/create-stripe-checkout/index.ts`

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

    // Criar checkout session no Stripe
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')!;
    const stripePriceId = Deno.env.get('STRIPE_PRICE_ID')!;
    const appUrl = Deno.env.get('APP_URL')!;
    
    const checkoutData = {
      customer_email: profile?.email || user.email,
      line_items: [
        {
          price: stripePriceId,
          quantity: 1,
        }
      ],
      mode: 'subscription',
      success_url: `${appUrl}/payment/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${appUrl}/payment/failure`,
      metadata: {
        user_id: user.id,
        plan_type: planType,
      },
      subscription_data: {
        metadata: {
          user_id: user.id,
          plan_type: planType,
        }
      }
    };

    const response = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams(
        Object.entries(checkoutData).flatMap(([key, value]) => {
          if (typeof value === 'object' && !Array.isArray(value)) {
            return Object.entries(value).map(([subKey, subValue]) => [
              `${key}[${subKey}]`,
              typeof subValue === 'object' ? JSON.stringify(subValue) : String(subValue)
            ]);
          }
          if (Array.isArray(value)) {
            return value.map((item, index) => 
              Object.entries(item).map(([subKey, subValue]) => [
                `${key}[${index}][${subKey}]`,
                String(subValue)
              ])
            ).flat();
          }
          return [[key, String(value)]];
        })
      ).toString()
    });

    if (!response.ok) {
      const errorData = await response.text();
      throw new Error(`Erro Stripe: ${errorData}`);
    }

    const data = await response.json();

    return new Response(JSON.stringify({ 
      checkout_url: data.url,
      session_id: data.id,
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

### Criar: `supabase/functions/stripe-webhook/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const stripe = {
  webhooks: {
    constructEvent: async (payload: string, signature: string, secret: string) => {
      // Verificar assinatura do webhook
      const encoder = new TextEncoder();
      const key = await crypto.subtle.importKey(
        'raw',
        encoder.encode(secret),
        { name: 'HMAC', hash: 'SHA-256' },
        false,
        ['sign']
      );
      
      const timestamp = signature.split(',')[0].split('=')[1];
      const signatures = signature.split(',').map(s => s.split('=')[1]);
      
      const signedPayload = `${timestamp}.${payload}`;
      const data = encoder.encode(signedPayload);
      
      for (const sig of signatures) {
        const signatureBuffer = Uint8Array.from(atob(sig), c => c.charCodeAt(0));
        const isValid = await crypto.subtle.verify('HMAC', key, signatureBuffer, data);
        if (isValid) return JSON.parse(payload);
      }
      
      throw new Error('Invalid signature');
    }
  }
};

serve(async (req) => {
  try {
    const payload = await req.text();
    const signature = req.headers.get('stripe-signature') || '';
    
    const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;
    
    // Verificar assinatura
    let event;
    try {
      event = await stripe.webhooks.constructEvent(payload, signature, stripeWebhookSecret);
    } catch (err) {
      console.error('Erro ao verificar assinatura:', err);
      return new Response('Invalid signature', { status: 401 });
    }
    
    console.log('Webhook Stripe recebido:', event.type);

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Processar diferentes tipos de eventos
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object;
        const userId = session.metadata?.user_id;
        const planType = session.metadata?.plan_type || 'diamond';

        if (!userId) {
          console.error('user_id não encontrado no metadata');
          break;
        }

        // Buscar subscription do Stripe
        const subscriptionId = session.subscription;
        if (!subscriptionId) break;

        // Buscar subscription details do Stripe
        const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')!;
        const subResponse = await fetch(`https://api.stripe.com/v1/subscriptions/${subscriptionId}`, {
          headers: {
            'Authorization': `Bearer ${stripeSecretKey}`,
          }
        });
        
        if (!subResponse.ok) {
          console.error('Erro ao buscar subscription do Stripe');
          break;
        }
        
        const subscription = await subResponse.json();
        const customerId = subscription.customer;

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
            payment_provider: 'stripe',
            payment_provider_payment_id: session.id,
            payment_provider_subscription_id: subscriptionId,
            payment_provider_customer_id: customerId,
            current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
            current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
            cancel_at_period_end: subscription.cancel_at_period_end || false,
            updated_at: now.toISOString(),
          }, {
            onConflict: 'user_id'
          });

        if (subError) {
          console.error('Erro ao criar assinatura:', subError);
          throw subError;
        }

        // Atualizar perfil
        await supabase
          .from('profiles')
          .update({
            subscription_plan: planType,
            subscription_expires_at: new Date(subscription.current_period_end * 1000).toISOString(),
          })
          .eq('user_id', userId);

        // Registrar pagamento
        const { error: payError } = await supabase
          .from('payments')
          .insert({
            user_id: userId,
            amount: session.amount_total / 100, // Converter centavos para reais
            currency: session.currency.toUpperCase(),
            status: 'approved',
            payment_provider: 'stripe',
            payment_provider_payment_id: session.id,
            payment_method: session.payment_method_types?.[0] || 'card',
            metadata: session,
          });

        if (payError) {
          console.error('Erro ao registrar pagamento:', payError);
        }

        console.log('Assinatura ativada com sucesso para user:', userId);
        break;
      }

      case 'customer.subscription.deleted':
      case 'customer.subscription.updated': {
        const subscription = event.data.object;
        const customerId = subscription.customer;
        
        // Buscar user_id pelo customer_id
        const { data: subData } = await supabase
          .from('subscriptions')
          .select('user_id')
          .eq('payment_provider_customer_id', customerId)
          .single();
        
        if (subData?.user_id) {
          if (event.type === 'customer.subscription.deleted') {
            await supabase
              .from('subscriptions')
              .update({
                status: 'cancelled',
                updated_at: new Date().toISOString(),
              })
              .eq('user_id', subData.user_id);
          } else {
            await supabase
              .from('subscriptions')
              .update({
                status: subscription.status === 'active' ? 'active' : 'cancelled',
                current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
                current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
                cancel_at_period_end: subscription.cancel_at_period_end || false,
                updated_at: new Date().toISOString(),
              })
              .eq('user_id', subData.user_id);
          }
        }
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object;
        const customerId = invoice.customer;
        
        // Buscar user_id pelo customer_id
        const { data: subData } = await supabase
          .from('subscriptions')
          .select('user_id')
          .eq('payment_provider_customer_id', customerId)
          .single();
        
        if (subData?.user_id) {
          await supabase
            .from('payments')
            .insert({
              user_id: subData.user_id,
              amount: invoice.amount_paid / 100,
              currency: invoice.currency.toUpperCase(),
              status: 'approved',
              payment_provider: 'stripe',
              payment_provider_payment_id: invoice.id,
              payment_method: 'card',
              metadata: invoice,
            });
        }
        break;
      }

      case 'invoice.payment_failed': {
        const invoice = event.data.object;
        const customerId = invoice.customer;
        
        const { data: subData } = await supabase
          .from('subscriptions')
          .select('user_id')
          .eq('payment_provider_customer_id', customerId)
          .single();
        
        if (subData?.user_id) {
          await supabase
            .from('subscriptions')
            .update({
              status: 'past_due',
              updated_at: new Date().toISOString(),
            })
            .eq('user_id', subData.user_id);
        }
        break;
      }

      default:
        console.log('Evento não processado:', event.type);
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

### Via CLI:

```bash
# Login no Supabase
supabase login

# Link ao projeto
supabase link --project-ref [seu-project-id]

# Deploy das functions
supabase functions deploy create-stripe-checkout
supabase functions deploy stripe-webhook
```

### Via Dashboard:
1. Supabase Dashboard → Edge Functions
2. Create a new function
3. Cole o código correspondente
4. Deploy

---

## 🔗 Configurar Webhook no Stripe

1. No Dashboard do Stripe, vá em **"Developers"** → **"Webhooks"**
2. Clique em **"Add endpoint"**
3. Cole a URL:
   ```
   https://[seu-project-id].supabase.co/functions/v1/stripe-webhook
   ```
4. Selecione eventos:
   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
   - ✅ `invoice.payment_succeeded`
   - ✅ `invoice.payment_failed`
5. Clique em **"Add endpoint"**
6. **Copie o "Signing secret"** (começa com `whsec_...`)
7. Adicione no Supabase Secrets:
   ```
   STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
   ```

---

## 📱 Atualizar Frontend

### Atualizar `src/hooks/usePayments.ts`:

```typescript
// Hook para criar checkout no Stripe
export function useCreatePaymentPreference() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (planType: 'diamond') => {
      if (!user) throw new Error('User not authenticated');

      // Chamar edge function do Supabase
      const { data, error } = await supabase.functions.invoke('create-stripe-checkout', {
        body: { 
          planType,
        }
      });

      if (error) throw error;
      
      return data;
    },
    onSuccess: (data) => {
      // Redirecionar para checkout do Stripe
      if (data.checkout_url) {
        window.location.href = data.checkout_url;
      }
    },
    onError: (error: any) => {
      console.error('Erro ao criar checkout:', error);
      toast.error(error?.message || 'Erro ao processar pagamento');
    },
  });
}
```

### Atualizar `src/pages/Upgrade.tsx`:

Altere a linha 215:
```typescript
<p>Pagamento processado pela <strong className="text-white">Stripe</strong></p>
```

---

## 🧪 Testando

### Cartões de Teste do Stripe:

| Cartão | Número | CVV | Validade | Resultado |
|--------|--------|-----|----------|-----------|
| VISA Aprovado | 4242 4242 4242 4242 | 123 | 12/34 | ✅ Aprovado |
| VISA Recusado | 4000 0000 0000 0002 | 123 | 12/34 | ❌ Recusado |
| 3D Secure | 4000 0027 6000 3184 | 123 | 12/34 | ✅ Requer autenticação |

### Fluxo de Teste:

1. Acesse `/upgrade`
2. Clique em "Assinar Plano Diamond"
3. Preencha com dados de teste
4. Use cartão: `4242 4242 4242 4242`
5. CVV: qualquer 3 dígitos
6. Validade: qualquer data futura
7. Confirme pagamento
8. Verifique redirecionamento para `/payment/success`
9. Verifique badge Diamond no perfil

---

## 📊 Monitoramento

### Dashboard Stripe:
- Transações em tempo real
- Assinaturas ativas
- Webhooks recebidos
- Logs de erros

### Logs do Supabase:
```bash
supabase functions logs stripe-webhook --tail
supabase functions logs create-stripe-checkout --tail
```

---

## 💰 Taxas do Stripe

- **Cartão de Crédito:** 3,99% + R$0,39 por transação
- **Pix:** 0,99% (mínimo R$0,10)
- **Boleto:** R$2,90 por boleto
- **Sem mensalidade**
- **Repasse em D+1** (D+7 para novos usuários)

---

## 🔒 Segurança

### Verificação de Webhook:
- ✅ Assinatura verificada automaticamente
- ✅ Secret armazenado no Supabase
- ✅ Validação de eventos

### Boas Práticas:
- ✅ Use HTTPS sempre
- ✅ Valide todos os webhooks
- ✅ Não exponha secret keys
- ✅ Use test keys para desenvolvimento

---

## ✅ Checklist de Produção

- [ ] Trocar `sk_test_` por `sk_live_`
- [ ] Trocar `pk_test_` por `pk_live_`
- [ ] Configurar webhook de produção
- [ ] Atualizar `STRIPE_WEBHOOK_SECRET` com secret de produção
- [ ] Testar fluxo completo
- [ ] Configurar e-mails transacionais
- [ ] Monitorar primeiros pagamentos

---

**🎉 Pronto! Sistema de pagamentos Stripe configurado!**

