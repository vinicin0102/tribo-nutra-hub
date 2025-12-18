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
    console.log('📥 Recebida requisição:', req.method);
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const vapidPublicKey = Deno.env.get('VAPID_PUBLIC_KEY');
    const vapidPrivateKey = Deno.env.get('VAPID_PRIVATE_KEY');
    const vapidSubject = Deno.env.get('VAPID_SUBJECT');

    console.log('🔑 VAPID configurado?', {
      publicKey: !!vapidPublicKey,
      privateKey: !!vapidPrivateKey,
      subject: !!vapidSubject,
    });

    // Verificar se as chaves VAPID estão configuradas
    if (!vapidPublicKey || !vapidPrivateKey || !vapidSubject) {
      console.error('❌ Chaves VAPID não configuradas');
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

    // Tentar parse do JSON
    let requestData;
    try {
      requestData = await req.json();
      console.log('📋 Dados recebidos:', {
        title: requestData.title,
        body: requestData.body,
        url: requestData.url,
        hasSentBy: !!requestData.sentBy,
      });
    } catch (parseError) {
      console.error('❌ Erro ao fazer parse do JSON:', parseError);
      return new Response(
        JSON.stringify({ success: false, error: 'Erro ao processar requisição JSON' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { title, body, url, sentBy } = requestData;

    if (!title || !body) {
      console.error('❌ Título ou corpo faltando:', { title: !!title, body: !!body });
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Título e corpo são obrigatórios',
          received: { title: !!title, body: !!body }
        }),
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

    // Usar biblioteca web-push via npm
    // Importar dinamicamente para evitar problemas de compatibilidade
    console.log('📦 Importando biblioteca web-push...');
    let webpush;
    try {
      webpush = await import('https://esm.sh/web-push@3.6.6');
      console.log('✅ Biblioteca web-push importada com sucesso');
    } catch (importError) {
      console.error('❌ Erro ao importar web-push:', importError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Erro ao carregar biblioteca web-push. Verifique os logs.' 
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
    
    // Configurar web-push com chaves VAPID
    console.log('🔧 Configurando VAPID details...');
    try {
      webpush.setVapidDetails(
        vapidSubject!,
        vapidPublicKey!,
        vapidPrivateKey!
      );
      console.log('✅ VAPID details configurados');
    } catch (vapidError) {
      console.error('❌ Erro ao configurar VAPID:', vapidError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Erro ao configurar chaves VAPID. Verifique se estão corretas.' 
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Enviar para cada subscription usando web-push
    for (const sub of subscriptions) {
      try {
        console.log(`📨 Tentando enviar para: ${sub.endpoint.substring(0, 60)}...`);
        
        // Converter chaves de base64 para Uint8Array
        const p256dh = Uint8Array.from(atob(sub.p256dh), c => c.charCodeAt(0));
        const auth = Uint8Array.from(atob(sub.auth), c => c.charCodeAt(0));
        
        const subscription = {
          endpoint: sub.endpoint,
          keys: {
            p256dh: p256dh,
            auth: auth,
          },
        };

        // Enviar notificação usando web-push
        await webpush.sendNotification(
          subscription,
          payload,
          {
            TTL: 86400, // 24 horas
            urgency: 'normal',
          }
        );

        console.log(`✅ Enviado com sucesso para endpoint`);
        successCount++;
      } catch (err: unknown) {
        const error = err as Error;
        console.error(`❌ Erro ao enviar para ${sub.endpoint}:`, error.message);
        console.error(`❌ Stack:`, error.stack);
        
        // Verificar se o endpoint expirou
        if (error.message.includes('410') || error.message.includes('Gone') || error.message.includes('expired') || error.message.includes('410')) {
          console.log(`⚠️ Endpoint expirado`);
          expiredEndpoints.push(sub.endpoint);
        }
        
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
