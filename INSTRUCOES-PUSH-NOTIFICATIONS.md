# 📱 Push Notifications - Guia de Implementação

Este guia explica como configurar e usar push notifications no app.

## ✅ O que já foi implementado

1. ✅ Tabela `push_subscriptions` no banco de dados
2. ✅ Hook `usePushNotifications` para gerenciar subscriptions
3. ✅ Componente `NotificationToggle` para ativar/desativar
4. ✅ Integração no perfil do usuário
5. ✅ Service Worker com handlers de push (já existia)

## 🔧 Configuração Necessária

### 1. Executar Migrations no Supabase

Execute as migrations no Supabase SQL Editor:

1. `supabase/migrations/20251214000000_create_push_subscriptions.sql`
2. `supabase/migrations/20251214000001_create_push_notification_trigger.sql`

### 2. Gerar Chaves VAPID

As chaves VAPID são necessárias para autenticar as push notifications. Execute:

```bash
npm install -g web-push
web-push generate-vapid-keys
```

Isso gerará duas chaves:
- **Public Key**: Use no frontend (variável de ambiente)
- **Private Key**: Use no backend (Edge Function)

### 3. Configurar Variável de Ambiente

Adicione a chave pública VAPID no arquivo `.env`:

```env
VITE_VAPID_PUBLIC_KEY=sua_chave_publica_aqui
```

**Importante**: A chave deve estar no formato correto (base64 URL-safe).

### 4. Criar Edge Function para Enviar Push Notifications

Para enviar push notifications reais, você precisa criar uma Supabase Edge Function.

#### Passo 1: Instalar Supabase CLI

```bash
npm install -g supabase
```

#### Passo 2: Criar Edge Function

```bash
supabase functions new send-push-notification
```

#### Passo 3: Implementar a Function

Crie o arquivo `supabase/functions/send-push-notification/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import * as webpush from "https://deno.land/x/webpush@0.0.0/mod.ts"

const VAPID_PUBLIC_KEY = Deno.env.get("VAPID_PUBLIC_KEY") || ""
const VAPID_PRIVATE_KEY = Deno.env.get("VAPID_PRIVATE_KEY") || ""
const VAPID_SUBJECT = Deno.env.get("VAPID_SUBJECT") || "mailto:seu-email@exemplo.com"

serve(async (req) => {
  try {
    const { user_id, title, message, url } = await req.json()

    // Buscar subscriptions do usuário
    const { data: subscriptions, error } = await supabase
      .from('push_subscriptions')
      .select('endpoint, p256dh, auth')
      .eq('user_id', user_id)

    if (error) throw error

    // Enviar para cada subscription
    const results = await Promise.allSettled(
      subscriptions.map(async (sub) => {
        const subscription = {
          endpoint: sub.endpoint,
          keys: {
            p256dh: sub.p256dh,
            auth: sub.auth,
          },
        }

        const payload = JSON.stringify({
          title,
          body: message,
          icon: '/icons/icon-192x192.png',
          badge: '/icons/icon-72x72.png',
          url: url || '/',
        })

        await webpush.sendNotification(
          subscription,
          payload,
          {
            vapidDetails: {
              subject: VAPID_SUBJECT,
              publicKey: VAPID_PUBLIC_KEY,
              privateKey: VAPID_PRIVATE_KEY,
            },
          }
        )
      })
    )

    return new Response(
      JSON.stringify({ 
        success: true, 
        sent: results.filter(r => r.status === 'fulfilled').length 
      }),
      { headers: { "Content-Type": "application/json" } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    )
  }
})
```

#### Passo 4: Configurar Secrets

```bash
supabase secrets set VAPID_PUBLIC_KEY=sua_chave_publica
supabase secrets set VAPID_PRIVATE_KEY=sua_chave_privada
supabase secrets set VAPID_SUBJECT=mailto:seu-email@exemplo.com
```

#### Passo 5: Deploy da Function

```bash
supabase functions deploy send-push-notification
```

### 5. Integrar com Sistema de Notificações

Quando uma notificação é criada na tabela `notifications`, você pode chamar a Edge Function:

```sql
-- Exemplo de função para chamar Edge Function quando notificação é criada
CREATE OR REPLACE FUNCTION public.send_push_on_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  response http_response;
BEGIN
  -- Chamar Edge Function via HTTP
  SELECT * INTO response
  FROM http_post(
    'https://seu-projeto.supabase.co/functions/v1/send-push-notification',
    json_build_object(
      'user_id', NEW.user_id,
      'title', NEW.title,
      'message', NEW.message,
      'url', '/notifications'
    )::text,
    'application/json'::text,
    json_build_object(
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    )::text
  );
  
  RETURN NEW;
END;
$$;
```

## 🧪 Como Testar

1. **Ativar Notificações no App**:
   - Vá em "Perfil" → "Notificações Push"
   - Clique em "Ativar Notificações"
   - Permita notificações no navegador

2. **Verificar Subscription**:
   - Execute no Supabase SQL Editor:
   ```sql
   SELECT * FROM public.push_subscriptions;
   ```

3. **Testar Envio Manual**:
   - Crie uma notificação na tabela `notifications`
   - Verifique se a push notification aparece no dispositivo

## 📝 Notas Importantes

- **HTTPS Obrigatório**: Push notifications só funcionam em HTTPS (ou localhost)
- **Navegadores Suportados**: Chrome, Firefox, Edge (Safari tem suporte limitado)
- **iOS**: Requer configuração adicional no manifest.json
- **Chaves VAPID**: Mantenha a chave privada segura (nunca no frontend)

## 🔍 Troubleshooting

### Notificações não aparecem

1. Verifique se a permissão foi concedida
2. Verifique se a subscription está salva no banco
3. Verifique os logs do Service Worker (DevTools → Application → Service Workers)
4. Verifique se as chaves VAPID estão corretas

### Erro "VAPID key not valid"

- Verifique se a chave pública está no formato correto
- Certifique-se de que não há espaços ou quebras de linha
- Regere as chaves se necessário

### Service Worker não registra

- Verifique se o arquivo `sw.js` está acessível
- Verifique os logs do console do navegador
- Limpe o cache e recarregue a página

## 🚀 Próximos Passos

1. Implementar Edge Function para envio real
2. Adicionar notificações para eventos específicos (novos comentários, likes, etc.)
3. Adicionar ações nas notificações (botões de ação)
4. Implementar notificações agendadas
5. Adicionar analytics de notificações

