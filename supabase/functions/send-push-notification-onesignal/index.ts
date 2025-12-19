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
    console.log('📥 [OneSignal] Recebida requisição:', req.method);
    
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const onesignalAppId = Deno.env.get('ONESIGNAL_APP_ID') || 'e1e6712a-5457-4991-a922-f22b1f151c25';
    const onesignalApiKey = Deno.env.get('ONESIGNAL_API_KEY');

    console.log('🔑 [OneSignal] Configuração:', {
      appId: onesignalAppId,
      apiKey: !!onesignalApiKey,
    });

    // Verificar se a API Key está configurada
    if (!onesignalApiKey) {
      console.error('❌ [OneSignal] API Key não configurada');
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'OneSignal API Key não configurada. Configure ONESIGNAL_API_KEY nos secrets.' 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Parse do body da requisição
    const { title, body, url } = await req.json();

    if (!title || !body) {
      return new Response(
        JSON.stringify({ success: false, error: 'Título e mensagem são obrigatórios' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    console.log('📨 [OneSignal] Enviando notificação:', { title, body, url });

    // Criar cliente Supabase
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Buscar todas as subscriptions do OneSignal
    const { data: subscriptions, error: subsError } = await supabase
      .from('push_subscriptions')
      .select('user_id, endpoint')
      .like('endpoint', 'onesignal:%');

    if (subsError) {
      console.error('❌ [OneSignal] Erro ao buscar subscriptions:', subsError);
      return new Response(
        JSON.stringify({ success: false, error: 'Erro ao buscar subscriptions: ' + subsError.message }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    console.log(`📊 [OneSignal] Encontradas ${subscriptions?.length || 0} subscriptions`);

    if (!subscriptions || subscriptions.length === 0) {
      console.warn('⚠️ [OneSignal] Nenhuma subscription encontrada');
      return new Response(
        JSON.stringify({ 
          success: true, 
          success_count: 0, 
          failed_count: 0,
          message: 'Nenhum dispositivo inscrito' 
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Extrair player IDs do OneSignal dos endpoints
    const playerIds = subscriptions
      .map(sub => {
        const match = sub.endpoint.match(/onesignal:(.+)/);
        return match ? match[1] : null;
      })
      .filter((id): id is string => id !== null);

    console.log(`📱 [OneSignal] Player IDs extraídos: ${playerIds.length}`);

    if (playerIds.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: true, 
          success_count: 0, 
          failed_count: 0,
          message: 'Nenhum player ID válido encontrado' 
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    // Preparar payload para OneSignal API
    const onesignalPayload = {
      app_id: onesignalAppId,
      include_player_ids: playerIds,
      headings: { en: title, pt: title },
      contents: { en: body, pt: body },
      data: url ? { url } : {},
    };

    if (url) {
      onesignalPayload.url = url;
    }

    console.log('🚀 [OneSignal] Enviando para API do OneSignal...');

    // Enviar para OneSignal API
    const onesignalResponse = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${onesignalApiKey}`,
      },
      body: JSON.stringify(onesignalPayload),
    });

    const onesignalData = await onesignalResponse.json();

    if (!onesignalResponse.ok) {
      console.error('❌ [OneSignal] Erro na API:', onesignalData);
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Erro ao enviar para OneSignal: ' + (onesignalData.errors?.[0] || onesignalData.message || 'Erro desconhecido'),
          details: onesignalData 
        }),
        { 
          status: onesignalResponse.status, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      );
    }

    console.log('✅ [OneSignal] Resposta da API:', onesignalData);

    const successCount = onesignalData.recipients || playerIds.length;
    const failedCount = playerIds.length - successCount;

    // Salvar no log
    try {
      await supabase
        .from('push_notifications_log')
        .insert({
          title,
          body,
          url: url || null,
          recipients_count: playerIds.length,
          success_count: successCount,
          failed_count: failedCount,
        });
    } catch (logError) {
      console.warn('⚠️ [OneSignal] Erro ao salvar log:', logError);
    }

    return new Response(
      JSON.stringify({
        success: true,
        success_count: successCount,
        failed_count: failedCount,
        onesignal_id: onesignalData.id,
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );

  } catch (error: any) {
    console.error('❌ [OneSignal] Erro geral:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Erro desconhecido',
        stack: error.stack 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

