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
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Variáveis de ambiente do Supabase faltando');
      return new Response(JSON.stringify({ 
        error: 'Configuração do servidor incompleta'
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

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
        error: 'Usuário não autenticado'
      }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('email, full_name, username')
      .eq('user_id', user.id)
      .single();

    const { planType, duration } = await req.json();

    if (planType !== 'diamond') {
      return new Response(JSON.stringify({ 
        error: 'Plano inválido'
      }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY');
    
    // Selecionar o Price ID baseado na duração
    let stripePriceId: string | undefined;
    if (duration === '6m') {
      stripePriceId = Deno.env.get('STRIPE_PRICE_ID_6M');
    } else if (duration === '3m') {
      stripePriceId = Deno.env.get('STRIPE_PRICE_ID_3M');
    } else {
      stripePriceId = Deno.env.get('STRIPE_PRICE_ID');
    }
    
    if (!stripeSecretKey || !stripePriceId) {
      const missingVars = [];
      if (!stripeSecretKey) missingVars.push('STRIPE_SECRET_KEY');
      if (!stripePriceId) missingVars.push('STRIPE_PRICE_ID');
      
      return new Response(JSON.stringify({ 
        error: `Variáveis de ambiente faltando: ${missingVars.join(', ')}`
      }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log('Criando checkout com price_id:', stripePriceId, 'para duração:', duration || '1m');

    const origin = req.headers.get('origin') || 'https://sociedade-nutra.lovable.app';
    
    const formData = new URLSearchParams();
    formData.append('customer_email', profile?.email || user.email || '');
    formData.append('line_items[0][price]', stripePriceId);
    formData.append('line_items[0][quantity]', '1');
    formData.append('mode', 'subscription');
    formData.append('success_url', `${origin}/payment/success?session_id={CHECKOUT_SESSION_ID}`);
    formData.append('cancel_url', `${origin}/payment/failure`);
    formData.append('metadata[user_id]', user.id);
    formData.append('metadata[plan_type]', planType);
    formData.append('metadata[duration]', duration || '1m');
    formData.append('subscription_data[metadata][user_id]', user.id);
    formData.append('subscription_data[metadata][plan_type]', planType);

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
    console.log('Checkout criado com sucesso:', data.id);

    return new Response(JSON.stringify({ 
      checkout_url: data.url,
      session_id: data.id,
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: any) {
    console.error('Erro ao criar checkout:', error);
    
    return new Response(JSON.stringify({ 
      error: error instanceof Error ? error.message : 'Erro ao processar pagamento'
    }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
