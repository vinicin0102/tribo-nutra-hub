# 🚀 Configurar OneSignal - Guia Rápido

## ✅ Informações da Sua Conta

- **OneSignal App ID:** `e1e6712a-5457-4991-a922-f22b1f151c25`
- **OneSignal REST API Key:** `os_v2_app_4hthcksuk5ezdkjc6ivr6fi4eu5erd5oblqegd4czyxbp3dgs6kjdctjki6hdifsd7ajfs26c7u37cw3kd6pkyxcevbmxzlttwdym3q`

---

## 📋 Passo a Passo Rápido

### 1️⃣ Configurar no Supabase (Edge Functions Secrets)

1. Acesse: **https://supabase.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Settings** → **Edge Functions** → **Secrets**
4. Clique em **"Add new secret"**
5. Adicione os seguintes secrets:

**Secret 1:**
- **Name:** `ONESIGNAL_APP_ID`
- **Value:** `e1e6712a-5457-4991-a922-f22b1f151c25`

**Secret 2:**
- **Name:** `ONESIGNAL_API_KEY`
- **Value:** `os_v2_app_4hthcksuk5ezdkjc6ivr6fi4eu5erd5oblqegd4czyxbp3dgs6kjdctjki6hdifsd7ajfs26c7u37cw3kd6pkyxcevbmxzlttwdym3q`

6. Clique em **"Save"** para cada secret

---

### 2️⃣ Configurar no Frontend (.env)

No arquivo `.env` na raiz do projeto, adicione:

```env
VITE_ONESIGNAL_APP_ID=e1e6712a-5457-4991-a922-f22b1f151c25
```

**Se não tiver arquivo `.env`, crie um!**

---

### 3️⃣ Configurar no Vercel (se estiver usando)

1. Acesse: **https://vercel.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Settings** → **Environment Variables**
4. Clique em **"Add New"**
5. Adicione:
   - **Key:** `VITE_ONESIGNAL_APP_ID`
   - **Value:** `e1e6712a-5457-4991-a922-f22b1f151c25`
   - **Environment:** Production, Preview, Development (marque todos)
6. Clique em **"Save"**
7. **IMPORTANTE:** Faça um novo deploy após adicionar a variável!

---

### 4️⃣ Deploy da Edge Function

#### Opção A: Via Dashboard (Mais Fácil)

1. Acesse: **https://supabase.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Edge Functions**
4. Procure por: `send-push-notification-onesignal`
5. Se não existir, clique em **"Create a new function"**
6. Cole o código de `supabase/functions/send-push-notification-onesignal/index.ts`
7. Clique em **"Deploy"**

#### Opção B: Via Terminal

```bash
# Se ainda não tiver o Supabase CLI
npm install -g supabase

# Fazer login
supabase login

# Linkar ao projeto (use o project ref do seu Supabase)
supabase link --project-ref seu-project-ref

# Deploy
supabase functions deploy send-push-notification-onesignal
```

---

## ✅ Testar

### Teste 1: Ativar Notificações

1. Acesse o app
2. Vá em **Perfil** → **Notificações Push**
3. Clique em **"Ativar Notificações"**
4. Permita as notificações quando solicitado
5. Você deve ver: ✅ **"Notificações Ativadas"**

### Teste 2: Enviar Notificação (Admin)

1. Acesse o **Painel Admin**
2. Vá em **Notificações Push**
3. Preencha:
   - **Título:** Teste OneSignal
   - **Mensagem:** Esta é uma notificação de teste do OneSignal
4. Clique em **"Enviar Notificação"**
5. Você deve receber a notificação no dispositivo! 🔔

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

### No OneSignal Dashboard

1. Acesse: **https://app.onesignal.com/**
2. Selecione seu app
3. Vá em: **Audience** → **All Users**
4. Você deve ver os dispositivos inscritos

---

## 🆘 Problemas Comuns

### Erro: "OneSignal não está disponível"

**Solução:**
- Verifique se o script está carregando (Console F12)
- Verifique se `VITE_ONESIGNAL_APP_ID` está no `.env`
- Faça um rebuild do projeto: `npm run build`

### Erro: "API Key não configurada"

**Solução:**
- Verifique se `ONESIGNAL_API_KEY` está nos Secrets do Supabase
- Certifique-se de copiar a chave completa (é muito longa)
- Verifique se não há espaços extras

### Erro: "Nenhum dispositivo inscrito"

**Solução:**
- Certifique-se de que os usuários ativaram as notificações
- Verifique a tabela `push_subscriptions` no banco
- Verifique se os endpoints começam com `onesignal:`

### Notificações não chegam

**Solução:**
1. Verifique os logs da Edge Function no Supabase Dashboard
2. Verifique se o OneSignal App ID está correto
3. Verifique se a REST API Key está correta
4. No OneSignal Dashboard, verifique se há erros na aba **Delivery**

---

## ✅ Checklist Final

- [ ] `ONESIGNAL_APP_ID` configurado nos Secrets do Supabase
- [ ] `ONESIGNAL_API_KEY` configurado nos Secrets do Supabase
- [ ] `VITE_ONESIGNAL_APP_ID` configurado no `.env` (frontend)
- [ ] `VITE_ONESIGNAL_APP_ID` configurado no Vercel (se usar)
- [ ] Edge Function `send-push-notification-onesignal` deployada
- [ ] Teste de ativação de notificações funcionando
- [ ] Teste de envio de notificações funcionando

---

## 🎉 Pronto!

Agora você pode enviar push notifications via OneSignal! 🚀

Se tiver algum problema, verifique os logs no Console (F12) e nos logs da Edge Function no Supabase Dashboard.

