# 🚀 Configurar OneSignal para Push Notifications

## 📋 Informações

- **OneSignal App ID:** `e1e6712a-5457-4991-a922-f22b1f151c25`
- **Status:** ✅ Integração implementada

---

## ✅ Passo 1: Obter OneSignal API Key

1. Acesse: **https://app.onesignal.com/**
2. Faça login na sua conta
3. Selecione o app (ou crie um novo com o App ID acima)
4. Vá em: **Settings** → **Keys & IDs**
5. Copie a **REST API Key** (não a App ID!)

---

## ✅ Passo 2: Configurar no Supabase

### 2.1. Adicionar Secrets

1. Acesse: **https://supabase.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Settings** → **Edge Functions** → **Secrets**
4. Adicione os seguintes secrets:

```
ONESIGNAL_APP_ID=e1e6712a-5457-4991-a922-f22b1f151c25
ONESIGNAL_API_KEY=sua_rest_api_key_aqui
```

⚠️ **Importante:** Substitua `sua_rest_api_key_aqui` pela REST API Key que você copiou do OneSignal.

---

## ✅ Passo 3: Configurar Variável de Ambiente no Frontend

### 3.1. Criar/Atualizar arquivo `.env`

No diretório raiz do projeto, crie ou atualize o arquivo `.env`:

```env
VITE_ONESIGNAL_APP_ID=e1e6712a-5457-4991-a922-f22b1f151c25
```

### 3.2. Adicionar no Vercel (se estiver usando)

1. Acesse: **https://vercel.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Settings** → **Environment Variables**
4. Adicione:
   - **Key:** `VITE_ONESIGNAL_APP_ID`
   - **Value:** `e1e6712a-5457-4991-a922-f22b1f151c25`
5. Clique em **Save**

---

## ✅ Passo 4: Deploy da Edge Function

A Edge Function `send-push-notification-onesignal` já está criada. Para fazer deploy:

```bash
# Se ainda não tiver o Supabase CLI instalado
npm install -g supabase

# Fazer login
supabase login

# Linkar ao projeto
supabase link --project-ref seu-project-ref

# Deploy da função
supabase functions deploy send-push-notification-onesignal
```

Ou use o Dashboard do Supabase:
1. Dashboard → **Edge Functions**
2. Clique em **Deploy** na função `send-push-notification-onesignal`

---

## ✅ Passo 5: Testar

### 5.1. Testar no Frontend

1. Acesse o app
2. Vá em **Perfil** → **Notificações Push**
3. Clique em **"Ativar Notificações"**
4. Permita as notificações quando solicitado
5. Você deve ver: ✅ **"Notificações Ativadas"**

### 5.2. Testar Envio (Admin)

1. Acesse o **Painel Admin**
2. Vá em **Notificações Push**
3. Preencha:
   - **Título:** Teste OneSignal
   - **Mensagem:** Esta é uma notificação de teste
4. Clique em **"Enviar Notificação"**
5. Você deve receber a notificação no dispositivo!

---

## 🔍 Verificar se Está Funcionando

### No Console do Navegador (F12)

Você deve ver logs como:
```
[OneSignal] Script carregado
[OneSignal] Inicializando com App ID: e1e6712a-5457-4991-a922-f22b1f151c25
[OneSignal] ✅ Inicializado com sucesso
[OneSignal] Push notifications habilitadas? true
[OneSignal] ✅ User ID associado: seu-user-id
```

### No Supabase Dashboard

1. Vá em: **Database** → **Table Editor** → **push_subscriptions**
2. Você deve ver registros com `endpoint` começando com `onesignal:`

---

## 🆘 Problemas Comuns

### Erro: "OneSignal não está disponível"

**Solução:**
- Verifique se o script do OneSignal está carregando
- Abra o Console (F12) e verifique se há erros
- Verifique se `VITE_ONESIGNAL_APP_ID` está configurado

### Erro: "API Key não configurada"

**Solução:**
- Verifique se `ONESIGNAL_API_KEY` está configurado nos Secrets do Supabase
- Certifique-se de usar a **REST API Key** (não a App ID)

### Erro: "Nenhum dispositivo inscrito"

**Solução:**
- Certifique-se de que os usuários ativaram as notificações
- Verifique a tabela `push_subscriptions` no banco
- Verifique se os endpoints começam com `onesignal:`

### Notificações não chegam

**Solução:**
- Verifique os logs da Edge Function no Supabase Dashboard
- Verifique se o OneSignal App ID está correto
- Verifique se a REST API Key está correta
- No OneSignal Dashboard, verifique se há erros na aba **Delivery**

---

## 📊 Monitoramento

### OneSignal Dashboard

1. Acesse: **https://app.onesignal.com/**
2. Selecione seu app
3. Vá em: **Delivery** para ver estatísticas de envio
4. Vá em: **Audience** para ver dispositivos inscritos

### Supabase Dashboard

1. Vá em: **Database** → **Table Editor** → **push_notifications_log**
2. Veja o histórico de notificações enviadas

---

## ✅ Checklist

- [ ] OneSignal App ID configurado: `e1e6712a-5457-4991-a922-f22b1f151c25`
- [ ] REST API Key obtida do OneSignal Dashboard
- [ ] `ONESIGNAL_API_KEY` configurado nos Secrets do Supabase
- [ ] `ONESIGNAL_APP_ID` configurado nos Secrets do Supabase
- [ ] `VITE_ONESIGNAL_APP_ID` configurado no `.env` (frontend)
- [ ] Edge Function `send-push-notification-onesignal` deployada
- [ ] Teste de ativação de notificações funcionando
- [ ] Teste de envio de notificações funcionando

---

## 🎉 Pronto!

Agora você pode enviar push notifications via OneSignal! 🚀

