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

    // Validar plano
    if (planType !== 'diamond') {
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

    // Converter objeto para formato URL-encoded do Stripe
    const formData = new URLSearchParams();
    formData.append('customer_email', checkoutData.customer_email);
    formData.append('line_items[0][price]', checkoutData.line_items[0].price);
    formData.append('line_items[0][quantity]', checkoutData.line_items[0].quantity.toString());
    formData.append('mode', checkoutData.mode);
    formData.append('success_url', checkoutData.success_url);
    formData.append('cancel_url', checkoutData.cancel_url);
    formData.append('metadata[user_id]', checkoutData.metadata.user_id);
    formData.append('metadata[plan_type]', checkoutData.metadata.plan_type);
    formData.append('subscription_data[metadata][user_id]', checkoutData.subscription_data.metadata.user_id);
    formData.append('subscription_data[metadata][plan_type]', checkoutData.subscription_data.metadata.plan_type);

    const response = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${stripeSecretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: formData.toString(),
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('Erro Stripe:', errorData);
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

