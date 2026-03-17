import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Parse payload
    const payload = await req.json();
    console.log('--- Webhook Recebido ---');
    console.log('Payload:', JSON.stringify(payload, null, 2));

    // Identificar plataforma (opcional)
    const platform = req.headers.get('x-platform') || 'generic';
    
    // Tentar encontrar o email em campos comuns de diversos gateways
    // Kiwify: data.customer.email
    // Hotmart: data.purchase.email
    // Doppus: customer.email
    // Peper: customer.email
    // Perfect Pay: email
    // Kirvano: customer.email
    // Eduzz: email
    
    const email = 
      payload.email || 
      payload.customer?.email || 
      payload.data?.customer?.email || 
      payload.data?.purchase?.email ||
      payload.customer_email ||
      payload.data?.email ||
      payload.object?.customer_email;

    if (!email) {
      console.error('Email não encontrado no payload');
      return new Response(JSON.stringify({ error: 'Email not found in payload' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    console.log('Email identificado:', email);

    // Tentar encontrar o status em campos comuns
    // status: approved, paid, completed, succeeded
    const statusField = 
      payload.status || 
      payload.data?.status || 
      payload.purchase_status ||
      payload.event;

    // Se não houver status, assumimos que é uma aprovação (alguns gateways só enviam webhook no sucesso)
    // Mas se houver, validamos se é um dos estados de "sucesso"
    const successStatuses = ['paid', 'approved', 'completed', 'succeeded', 'active', 'pago', 'aprovado', 'sucesso'];
    const lowerStatus = statusField?.toString().toLowerCase();
    
    const isApproved = !statusField || successStatuses.some(s => lowerStatus?.includes(s));

    if (!isApproved) {
      console.log('Status não é de aprovação:', statusField);
      return new Response(JSON.stringify({ message: 'Status not approved, skipping' }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Buscar usuário pelo email
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('user_id, full_name')
      .ilike('email', email)
      .maybeSingle();

    if (profileError || !profile) {
      console.error('Usuário não encontrado para o email:', email);
      return new Response(JSON.stringify({ error: 'User not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const userId = profile.user_id;
    const planType = 'diamond'; // Default para Nutra hubs

    const now = new Date();
    const nextMonth = new Date(now);
    nextMonth.setMonth(nextMonth.getMonth() + 1);

    console.log('Ativando plano diamond para:', profile.full_name || email);

    // Criar/atualizar assinatura
    const { error: subError } = await supabase
      .from('subscriptions')
      .upsert({
        user_id: userId,
        plan_type: planType,
        status: 'active',
        payment_provider: platform,
        payment_provider_payment_id: payload.id || payload.transaction_id || payload.data?.id || `gen_${Date.now()}`,
        current_period_start: now.toISOString(),
        current_period_end: nextMonth.toISOString(),
        updated_at: now.toISOString(),
      }, {
        onConflict: 'user_id'
      });

    if (subError) {
      console.error('Erro ao salvar assinatura:', subError);
      throw subError;
    }

    // Registrar pagamento
    const amount = 
      payload.amount || 
      payload.price || 
      payload.data?.amount || 
      payload.total_price || 
      0;

    await supabase
      .from('payments')
      .insert({
        user_id: userId,
        amount: typeof amount === 'number' ? amount / (amount > 1000 ? 100 : 1) : 0, // Tentar normalizar centavos
        currency: 'BRL',
        status: 'approved',
        payment_provider: platform,
        payment_provider_payment_id: payload.id || payload.transaction_id || `gen_${Date.now()}`,
        metadata: payload,
      });

    // Opcional: Notificar o usuário via push se o sistema tiver isso
    // ...

    return new Response(JSON.stringify({ 
      message: 'Success', 
      user: profile.full_name,
      plan: planType 
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    console.error('Erro no processamento do webhook:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
