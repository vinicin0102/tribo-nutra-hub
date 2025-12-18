import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const vapidPublicKey = Deno.env.get('VAPID_PUBLIC_KEY');
    const vapidPrivateKey = Deno.env.get('VAPID_PRIVATE_KEY');
    const vapidSubject = Deno.env.get('VAPID_SUBJECT');

    // Verificar se as chaves VAPID estão configuradas
    if (!vapidPublicKey || !vapidPrivateKey || !vapidSubject) {
      console.error('Chaves VAPID não configuradas');
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Chaves VAPID não configuradas. Configure VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY e VAPID_SUBJECT nos secrets.' 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { title, body, url, sentBy } = await req.json();

    if (!title || !body) {
      return new Response(
        JSON.stringify({ success: false, error: 'Título e corpo são obrigatórios' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`📤 Enviando push notification: "${title}"`);

    // Buscar todas as subscriptions ativas
    const { data: subscriptions, error: fetchError } = await supabase
      .from('push_subscriptions')
      .select('*');

    if (fetchError) {
      console.error('Erro ao buscar subscriptions:', fetchError);
      return new Response(
        JSON.stringify({ success: false, error: fetchError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (!subscriptions || subscriptions.length === 0) {
      console.log('Nenhuma subscription encontrada');
      
      // Registrar no log mesmo sem dispositivos
      await supabase
        .from('push_notifications_log')
        .insert({
          title,
          body,
          url,
          sent_by: sentBy || null,
          sent_to_all: true,
          recipients_count: 0,
          success_count: 0,
          failed_count: 0,
        });

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Nenhum dispositivo registrado para receber notificações',
          recipients_count: 0,
          success_count: 0,
          failed_count: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    console.log(`📱 Encontradas ${subscriptions.length} subscriptions`);

    let successCount = 0;
    let failedCount = 0;
    const expiredEndpoints: string[] = [];

    // Payload da notificação
    const payload = JSON.stringify({
      title,
      body,
      icon: '/icons/icon-192x192.png',
      badge: '/icons/icon-72x72.png',
      data: {
        url: url || '/',
        timestamp: Date.now(),
      },
    });

    // Enviar para cada subscription usando web-push protocol
    for (const sub of subscriptions) {
      try {
        console.log(`📨 Tentando enviar para: ${sub.endpoint.substring(0, 60)}...`);
        
        // Fazer POST para o endpoint do push service
        // Nota: Esta é uma implementação simplificada que pode não funcionar
        // com todos os push services (FCM, Mozilla, etc.)
        // Para produção, recomenda-se usar uma biblioteca como web-push
        
        const response = await fetch(sub.endpoint, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'TTL': '86400',
          },
          body: payload,
        });

        if (response.ok || response.status === 201) {
          console.log(`✅ Enviado com sucesso para endpoint`);
          successCount++;
        } else if (response.status === 404 || response.status === 410) {
          // Endpoint não existe mais
          console.log(`⚠️ Endpoint expirado: ${response.status}`);
          expiredEndpoints.push(sub.endpoint);
          failedCount++;
        } else {
          console.error(`❌ Falha ao enviar: ${response.status}`);
          failedCount++;
        }
      } catch (err: unknown) {
        const error = err as Error;
        console.error(`❌ Erro ao enviar para ${sub.endpoint}:`, error.message);
        failedCount++;
      }
    }

    // Remover endpoints expirados
    if (expiredEndpoints.length > 0) {
      console.log(`🗑️ Removendo ${expiredEndpoints.length} endpoints expirados`);
      await supabase
        .from('push_subscriptions')
        .delete()
        .in('endpoint', expiredEndpoints);
    }

    // Registrar no log
    const { error: logError } = await supabase
      .from('push_notifications_log')
      .insert({
        title,
        body,
        url,
        sent_by: sentBy || null,
        sent_to_all: true,
        recipients_count: subscriptions.length,
        success_count: successCount,
        failed_count: failedCount,
      });

    if (logError) {
      console.error('Erro ao salvar log:', logError);
    }

    console.log(`✅ Notificação processada - Total: ${subscriptions.length}, Sucesso: ${successCount}, Falha: ${failedCount}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: `Notificação enviada para ${successCount} dispositivo(s)`,
        recipients_count: subscriptions.length,
        success_count: successCount,
        failed_count: failedCount,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err: unknown) {
    const error = err as Error;
    console.error('Erro na edge function:', error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
