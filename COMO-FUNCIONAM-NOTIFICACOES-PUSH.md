# 📱 Como Funcionam as Notificações Push

## 🎯 Visão Geral

O sistema de notificações push permite que o app envie notificações para o dispositivo do usuário **mesmo quando o app está fechado**. Isso funciona através de uma combinação de tecnologias web modernas.

---

## 🔄 Fluxo Completo

### **1. Ativação (Primeira Vez)**

Quando o usuário ativa as notificações push:

```
Usuário clica "Ativar Notificações"
    ↓
Navegador solicita permissão
    ↓
Service Worker cria uma "subscription" única
    ↓
Subscription é salva no banco de dados (push_subscriptions)
    ↓
✅ Usuário está inscrito para receber notificações
```

**O que acontece no código:**

1. **Frontend** (`usePushNotifications.ts`):
   - Solicita permissão do navegador
   - Cria uma subscription usando a chave VAPID pública
   - Salva a subscription no Supabase (`push_subscriptions`)

2. **Subscription contém:**
   - `endpoint`: URL única do serviço de push (ex: `https://fcm.googleapis.com/...`)
   - `p256dh`: Chave pública para criptografia
   - `auth`: Chave de autenticação
   - `user_id`: ID do usuário

---

### **2. Envio de Notificação (Futuro)**

Quando você quiser enviar uma notificação:

```
Evento acontece (ex: novo comentário)
    ↓
Sistema cria registro na tabela `notifications`
    ↓
Edge Function busca subscriptions do usuário
    ↓
Edge Function envia push para cada subscription
    ↓
Serviço de push (Google/Apple) entrega ao dispositivo
    ↓
Service Worker recebe e exibe a notificação
```

**O que precisa ser implementado:**

1. **Edge Function** (Supabase):
   - Busca subscriptions do usuário no banco
   - Usa a chave VAPID privada para autenticar
   - Envia push para o endpoint do usuário

2. **Service Worker** (`sw.js`):
   - Recebe o push mesmo com app fechado
   - Exibe a notificação no dispositivo
   - Abre o app quando o usuário clica

---

## 🛠️ Componentes do Sistema

### **1. Service Worker (`public/sw.js`)**

O Service Worker é um script que roda em background, mesmo com o app fechado.

**Funções principais:**

```javascript
// Recebe notificações push
self.addEventListener('push', (event) => {
  const data = event.data.json();
  // Exibe a notificação
  self.registration.showNotification(data.title, {
    body: data.body,
    icon: '/icons/icon-192x192.png',
    // ...
  });
});

// Quando usuário clica na notificação
self.addEventListener('notificationclick', (event) => {
  // Abre o app na página correta
  clients.openWindow(event.notification.data.url);
});
```

### **2. Hook `usePushNotifications`**

Gerencia a subscription do usuário no frontend.

**Funções:**

- `subscribe()`: Ativa notificações
- `unsubscribe()`: Desativa notificações
- `checkSubscriptionStatus()`: Verifica se está ativo

**Exemplo de uso:**

```typescript
const { isSubscribed, subscribe, unsubscribe } = usePushNotifications();

// Ativar
await subscribe();

// Desativar
await unsubscribe();
```

### **3. Tabela `push_subscriptions`**

Armazena as subscriptions de todos os usuários.

**Estrutura:**

```sql
- id: UUID único
- user_id: ID do usuário
- endpoint: URL do serviço de push
- p256dh: Chave pública de criptografia
- auth: Chave de autenticação
- user_agent: Navegador do usuário
- created_at: Data de criação
- updated_at: Última atualização
```

### **4. Chaves VAPID**

**VAPID** = Voluntary Application Server Identification

- **Chave Pública**: Usada no frontend para criar subscriptions
- **Chave Privada**: Usada no backend para enviar notificações

**Segurança:**
- ✅ Chave pública pode estar no `.env` (frontend)
- ❌ Chave privada NUNCA no frontend (apenas no Supabase Secrets)

---

## 📊 Tipos de Notificações

### **1. Notificações In-App**

São as notificações que aparecem dentro do app (tabela `notifications`).

**Quando aparecem:**
- Novo comentário no seu post
- Alguém curtiu seu post
- Nova mensagem no chat
- Novo badge conquistado

**Como funcionam:**
- Criadas no banco de dados
- Exibidas na página de Notificações
- Atualizadas em tempo real via Supabase Realtime

### **2. Push Notifications**

São as notificações que aparecem no dispositivo, mesmo com app fechado.

**Quando aparecem:**
- Mesmos eventos das notificações in-app
- Mas chegam mesmo com app fechado

**Como funcionam:**
- Service Worker recebe o push
- Exibe notificação nativa do sistema
- Ao clicar, abre o app

---

## 🔐 Segurança e Privacidade

### **Permissões**

- O navegador solicita permissão antes de ativar
- Usuário pode negar ou revogar a qualquer momento
- Permissões são por domínio (ex: `tribo-nutra.com`)

### **Criptografia**

- Todas as notificações são criptografadas
- Chaves VAPID garantem autenticidade
- Apenas o servidor pode enviar notificações válidas

### **RLS (Row Level Security)**

- Usuários só veem suas próprias subscriptions
- Admins podem ver todas (para gerenciamento)
- Subscriptions são deletadas quando usuário é removido

---

## 🧪 Como Testar

### **1. Ativar Notificações**

1. Abra o app no navegador
2. Vá em **Perfil** → **Notificações Push**
3. Clique em **"Ativar Notificações"**
4. Permita quando o navegador solicitar

### **2. Verificar Subscription**

Execute no Supabase SQL Editor:

```sql
SELECT 
  u.email,
  ps.endpoint,
  ps.created_at
FROM push_subscriptions ps
JOIN auth.users u ON u.id = ps.user_id;
```

Se aparecer sua subscription, está funcionando! ✅

### **3. Testar Recebimento (Futuro)**

Quando a Edge Function estiver pronta:

1. Crie uma notificação na tabela `notifications`
2. A Edge Function deve enviar o push automaticamente
3. A notificação deve aparecer no dispositivo

---

## 🚀 Próximos Passos (Para Implementar)

### **1. Criar Edge Function**

Criar `supabase/functions/send-push-notification/index.ts`:

```typescript
// Busca subscriptions do usuário
// Envia push usando webpush
// Retorna resultado
```

### **2. Configurar Trigger**

Criar trigger no banco que chama a Edge Function quando:
- Nova notificação é criada
- Novo comentário é feito
- Nova mensagem no chat

### **3. Adicionar VAPID Secrets**

No Supabase:
```bash
supabase secrets set VAPID_PRIVATE_KEY=sua_chave_privada
supabase secrets set VAPID_SUBJECT=mailto:seu-email@exemplo.com
```

---

## ❓ Perguntas Frequentes

### **Por que não funciona no Safari?**

Safari tem suporte limitado a push notifications. Use Chrome, Firefox ou Edge.

### **Precisa estar em HTTPS?**

Sim! Push notifications só funcionam em HTTPS (ou localhost para desenvolvimento).

### **Funciona com app fechado?**

Sim! O Service Worker recebe notificações mesmo com o app fechado.

### **Consome muita bateria?**

Não! O Service Worker é muito eficiente e só ativa quando necessário.

### **Posso desativar depois?**

Sim! Basta ir em Perfil → Notificações Push → Desativar.

---

## 📚 Recursos Técnicos

- **Service Worker API**: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API
- **Push API**: https://developer.mozilla.org/en-US/docs/Web/API/Push_API
- **VAPID**: https://tools.ietf.org/html/rfc8292
- **Web Push Protocol**: https://datatracker.ietf.org/doc/html/rfc8030

---

## 🎯 Resumo

1. **Usuário ativa** → Subscription criada e salva
2. **Evento acontece** → Sistema cria notificação
3. **Edge Function envia** → Push para o dispositivo
4. **Service Worker recebe** → Exibe notificação
5. **Usuário clica** → App abre na página correta

**Status atual:**
- ✅ Frontend pronto (subscription)
- ✅ Service Worker pronto (receber/exibir)
- ⏳ Backend pendente (Edge Function para enviar)

