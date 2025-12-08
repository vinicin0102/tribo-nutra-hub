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
    // Verificar variáveis de ambiente primeiro
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Variáveis de ambiente do Supabase faltando');
      return new Response(JSON.stringify({ 
        error: 'Configuração do servidor incompleta',
        details: 'SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY não configurados'
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Obter dados do usuário
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ 
        error: 'Token de autenticação não fornecido'
      }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    
    if (authError || !user) {
      console.error('Erro de autenticação:', authError);
      return new Response(JSON.stringify({ 
        error: 'Usuário não autenticado',
        details: authError?.message
      }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
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
      return new Response(JSON.stringify({ 
        error: 'Plano inválido'
      }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Criar checkout session no Stripe
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    const stripePriceId = Deno.env.get('STRIPE_PRICE_ID');
    const appUrl = Deno.env.get('APP_URL');
    
    // Verificar variáveis de ambiente do Stripe
    if (!stripeSecretKey || !stripePriceId || !appUrl) {
      const missingVars = [];
      if (!stripeSecretKey) missingVars.push('STRIPE_SECRET_KEY');
      if (!stripePriceId) missingVars.push('STRIPE_PRICE_ID');
      if (!appUrl) missingVars.push('APP_URL');
      
      return new Response(JSON.stringify({ 
        error: `Variáveis de ambiente faltando: ${missingVars.join(', ')}`,
        missing_vars: missingVars
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }
    
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
      return new Response(JSON.stringify({ 
        error: `Erro Stripe: ${errorData}`
      }), {
        status: response.status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const data = await response.json();

    return new Response(JSON.stringify({ 
      checkout_url: data.url,
      session_id: data.id,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: any) {
    console.error('Erro ao criar checkout:', error);
    
    const errorMessage = error instanceof Error ? error.message : (error?.message || 'Erro ao processar pagamento');
    
    return new Response(JSON.stringify({ 
      error: errorMessage,
      details: error?.stack || error
    }), {
      status: error?.status || 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
