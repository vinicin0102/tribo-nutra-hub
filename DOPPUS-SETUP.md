# 💳 Integração Doppus - Pagamentos e Assinaturas

## 🎯 Visão Geral

A Doppus é uma plataforma brasileira especializada em pagamentos recorrentes e produtos digitais, ideal para assinaturas.

### Vantagens da Doppus:
- ✅ Especializada em assinaturas
- ✅ Sistema anti-fraude avançado
- ✅ Área de membros integrada
- ✅ Pix, Cartão e Boleto
- ✅ Gestão de cancelamentos
- ✅ Webhooks em tempo real
- ✅ Taxas competitivas (4,99% + R$0,40)

---

## 📋 Passo a Passo Completo

### 1️⃣ Criar Conta na Doppus

1. Acesse: https://doppus.com/
2. Clique em **"Começar agora"**
3. Preencha o cadastro
4. Confirme e-mail
5. Complete o cadastro da empresa

### 2️⃣ Criar Produto/Assinatura

1. No painel Doppus, vá em **"Produtos"**
2. Clique em **"Novo Produto"**
3. Preencha:
   - **Nome:** Plano Diamond - Nutra Elite
   - **Tipo:** Assinatura
   - **Valor:** R$ 197,00
   - **Recorrência:** Mensal
   - **Descrição:** Acesso total à plataforma premium
4. Salve o produto
5. **Copie o ID do produto** (ex: `prod_abc123`)

### 3️⃣ Obter Token de API

1. Vá em **"Configurações"** → **"API"**
2. Copie seu **API Token**
3. Formato: `sk_live_xxxxxxxxxxxxx` (produção) ou `sk_test_xxxxxxxxxxxxx` (teste)

---

## 🔧 Configuração no Supabase

### 1. Secrets no Supabase

Vá em: **Project Settings > Edge Functions > Secrets**

Adicione **APENAS 2 VARIÁVEIS**:

```env
DOPPUS_API_TOKEN=sk_test_xxxxxxxxxxxxx
APP_URL=https://seuapp.vercel.app
```

**IMPORTANTE:** Use `sk_test_` para testes e `sk_live_` para produção.

---

## 💻 Edge Functions

### Criar: `supabase/functions/create-doppus-checkout/index.ts`

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

    // Criar checkout na Doppus
    const doppusToken = Deno.env.get('DOPPUS_API_TOKEN')!;
    const appUrl = Deno.env.get('APP_URL')!;
    
    const checkoutData = {
      customer: {
        name: profile?.full_name || profile?.username || 'Cliente',
        email: profile?.email || user.email,
        document: '', // CPF/CNPJ (opcional)
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

    const response = await fetch('https://api.doppus.app/v1/checkouts', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${doppusToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(checkoutData),
    });

    if (!response.ok) {
      const errorData = await response.text();
      throw new Error(`Erro Doppus: ${errorData}`);
    }

    const data = await response.json();

    return new Response(JSON.stringify({ 
      checkout_url: data.url,
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

### Criar: `supabase/functions/doppus-webhook/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  try {
    const payload = await req.json();
    
    console.log('Webhook Doppus recebido:', payload);

    // Verificar assinatura do webhook (recomendado em produção)
    // const signature = req.headers.get('x-doppus-signature');
    // if (!verifySignature(payload, signature)) {
    //   return new Response('Invalid signature', { status: 401 });
    // }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { type, data } = payload;

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
            payment_provider: 'doppus',
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
            payment_provider: 'doppus',
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
              payment_provider: 'doppus',
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
supabase functions deploy create-doppus-checkout
supabase functions deploy doppus-webhook
```

---

## 🔗 Configurar Webhook na Doppus

1. No painel Doppus, vá em **"Configurações"** → **"Webhooks"**
2. Clique em **"Adicionar Webhook"**
3. Cole a URL:
   ```
   https://[seu-project-id].supabase.co/functions/v1/doppus-webhook
   ```
4. Selecione eventos:
   - ✅ `checkout.completed`
   - ✅ `subscription.created`
   - ✅ `subscription.cancelled`
   - ✅ `payment.succeeded`
   - ✅ `payment.failed`
5. Salve o webhook

---

## 📱 Atualizar Frontend

Atualize `src/hooks/usePayments.ts`:

```typescript
// Trocar a função de criar pagamento
export function useCreateDoppusCheckout() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (planType: 'diamond') => {
      if (!user) throw new Error('User not authenticated');

      const { data, error } = await supabase.functions.invoke('create-doppus-checkout', {
        body: { planType }
      });

      if (error) throw error;
      
      return data;
    },
    onSuccess: (data) => {
      // Redirecionar para checkout da Doppus
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

Atualize `src/pages/Upgrade.tsx`:

```typescript
import { useCreateDoppusCheckout } from '@/hooks/usePayments';

// No componente
const createCheckout = useCreateDoppusCheckout();

const handleUpgrade = () => {
  createCheckout.mutate('diamond');
};
```

---

## 🧪 Testando

### 1. Cartões de Teste da Doppus

| Cartão | Número | CVV | Validade | Resultado |
|--------|--------|-----|----------|-----------|
| VISA | 4111 1111 1111 1111 | 123 | 12/30 | APROVADO |
| Mastercard | 5555 5555 5555 4444 | 123 | 12/30 | APROVADO |
| VISA | 4000 0000 0000 0002 | 123 | 12/30 | RECUSADO |

### 2. Pix de Teste

No ambiente de teste, você pode usar qualquer código Pix - será aprovado automaticamente após alguns segundos.

### 3. Fluxo de Teste

1. Vá em `/upgrade`
2. Clique em "Assinar Plano Diamond"
3. Preencha com dados de teste
4. Use cartão de teste
5. Confirme pagamento
6. Aguarde redirecionamento para `/payment/success`
7. Verifique badge Diamond

---

## 📊 Monitoramento

### Painel Doppus

Acesse o painel para ver:
- Transações em tempo real
- Status de assinaturas
- Cobranças pendentes
- Cancelamentos
- Reembolsos

### Logs do Supabase

```bash
# Ver logs do webhook
supabase functions logs doppus-webhook --tail

# Ver logs do checkout
supabase functions logs create-doppus-checkout --tail
```

---

## 💰 Taxas da Doppus

- **Cartão de Crédito:** 4,99% + R$0,40 por transação
- **Pix:** 0,99% (mínimo R$0,10)
- **Boleto:** R$2,90 por boleto
- **Sem mensalidade**
- **Repasse em 1 dia útil** (D+1)

---

## 🔒 Segurança

### Verificar Assinatura do Webhook (Recomendado)

```typescript
function verifyWebhookSignature(payload: any, signature: string): boolean {
  const doppusWebhookSecret = Deno.env.get('DOPPUS_WEBHOOK_SECRET')!;
  
  // Criar hash HMAC SHA256
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(doppusWebhookSecret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  
  const data = encoder.encode(JSON.stringify(payload));
  const signatureBuffer = await crypto.subtle.sign('HMAC', key, data);
  const computedSignature = Array.from(new Uint8Array(signatureBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return computedSignature === signature;
}
```

---

## 🎯 Vantagens vs Mercado Pago

| Recurso | Doppus | Mercado Pago |
|---------|--------|--------------|
| Especializado em assinaturas | ✅ | ❌ |
| Área de membros | ✅ | ❌ |
| Gestão de acessos | ✅ | ❌ |
| Taxa cartão | 4,99% | 4,99% |
| Taxa Pix | 0,99% | 0,99% |
| Repasse | D+1 | D+14 |
| Suporte BR | ✅ | ✅ |

---

## 📝 Checklist de Produção

- [ ] Trocar `sk_test_` por `sk_live_`
- [ ] Configurar webhook de produção
- [ ] Testar fluxo completo
- [ ] Configurar e-mails transacionais
- [ ] Monitorar primeiros pagamentos
- [ ] Documentar processo de cancelamento

---

**🎉 Pronto! Sistema de pagamentos Doppus configurado!**

