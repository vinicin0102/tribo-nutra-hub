import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Função para verificar assinatura do webhook Stripe
async function verifyStripeSignature(
  payload: string,
  signature: string,
  secret: string
): Promise<boolean> {
  try {
    const encoder = new TextEncoder();
    const timestamp = signature.split(',')[0].split('=')[1];
    const signatures = signature.split(',').map(s => s.split('=')[1]);
    
    const signedPayload = `${timestamp}.${payload}`;
    const data = encoder.encode(signedPayload);
    
    const key = await crypto.subtle.importKey(
      'raw',
      encoder.encode(secret),
      { name: 'HMAC', hash: 'SHA-256' },
      false,
      ['verify']
    );
    
    for (const sig of signatures) {
      const signatureBuffer = Uint8Array.from(atob(sig), c => c.charCodeAt(0));
      const isValid = await crypto.subtle.verify('HMAC', key, signatureBuffer, data);
      if (isValid) return true;
    }
    
    return false;
  } catch (error) {
    console.error('Erro ao verificar assinatura:', error);
    return false;
  }
}

serve(async (req) => {
  try {
    const payload = await req.text();
    const signature = req.headers.get('stripe-signature') || '';
    
    const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
    
    // Verificar assinatura se secret estiver configurado
    if (stripeWebhookSecret) {
      const isValid = await verifyStripeSignature(payload, signature, stripeWebhookSecret);
      if (!isValid) {
        console.error('Assinatura inválida');
        return new Response('Invalid signature', { status: 401 });
      }
    }
    
    const event = JSON.parse(payload);
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

        const subscriptionId = session.subscription;
        if (!subscriptionId) {
          console.error('subscription_id não encontrado');
          break;
        }

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
            updated_at: new Date().toISOString(),
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
        await supabase
          .from('payments')
          .insert({
            user_id: userId,
            amount: session.amount_total / 100,
            currency: session.currency.toUpperCase(),
            status: 'approved',
            payment_provider: 'stripe',
            payment_provider_payment_id: session.id,
            payment_method: session.payment_method_types?.[0] || 'card',
            metadata: session,
          });

        console.log('Assinatura ativada com sucesso para user:', userId);
        break;
      }

      case 'customer.subscription.deleted': {
        const subscription = event.data.object;
        const customerId = subscription.customer;
        
        const { data: subData } = await supabase
          .from('subscriptions')
          .select('user_id')
          .eq('payment_provider_customer_id', customerId)
          .single();
        
        if (subData?.user_id) {
          await supabase
            .from('subscriptions')
            .update({
              status: 'cancelled',
              updated_at: new Date().toISOString(),
            })
            .eq('user_id', subData.user_id);
        }
        break;
      }

      case 'customer.subscription.updated': {
        const subscription = event.data.object;
        const customerId = subscription.customer;
        
        const { data: subData } = await supabase
          .from('subscriptions')
          .select('user_id')
          .eq('payment_provider_customer_id', customerId)
          .single();
        
        if (subData?.user_id) {
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
        break;
      }

      case 'invoice.payment_succeeded': {
        const invoice = event.data.object;
        const customerId = invoice.customer;
        
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

