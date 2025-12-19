# 🚀 Como Fazer Deploy da Edge Function (Sem Terminal)

## 📋 Passo a Passo

### 1. Acesse o Supabase Dashboard

1. Vá para: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto do app

### 2. Vá em Edge Functions

1. No menu lateral esquerdo, clique em **"Edge Functions"**
2. Você verá uma lista de funções (ou estará vazio se for a primeira vez)

### 3. Deploy da Função

**Opção A: Se a função já existe**

1. Encontre a função `send-push-notification` na lista
2. Clique nos **3 pontinhos** (⋮) ao lado dela
3. Clique em **"Deploy"** ou **"Redeploy"**
4. Aguarde o deploy terminar

**Opção B: Se a função não existe ainda**

1. Clique no botão **"Create a new function"** ou **"New Function"**
2. Nome da função: `send-push-notification`
3. Cole o código do arquivo `supabase/functions/send-push-notification/index.ts`
4. Clique em **"Deploy"**

### 4. Verificar Secrets (IMPORTANTE!)

1. No menu lateral, clique em **"Project Settings"** (ícone de engrenagem)
2. Vá em **"Edge Functions"** → **"Secrets"**
3. Verifique se existem os seguintes secrets:
   - `VAPID_PUBLIC_KEY`
   - `VAPID_PRIVATE_KEY`
   - `VAPID_SUBJECT`

**Se não existirem, adicione:**

1. Clique em **"Add new secret"**
2. Para cada um:
   - **Name:** `VAPID_PUBLIC_KEY`
   - **Value:** Cole a chave pública VAPID (a mesma do `.env`)
   - Clique em **"Save"**

   - **Name:** `VAPID_PRIVATE_KEY`
   - **Value:** Cole a chave privada VAPID
   - Clique em **"Save"**

   - **Name:** `VAPID_SUBJECT`
   - **Value:** `mailto:seu@email.com` (substitua pelo seu email)
   - Clique em **"Save"**

### 5. Testar a Função

1. Volte para **"Edge Functions"**
2. Clique na função `send-push-notification`
3. Vá na aba **"Invoke"** ou **"Test"**
4. Cole este JSON de teste:
   ```json
   {
     "title": "Teste",
     "body": "Esta é uma notificação de teste",
     "url": "/"
   }
   ```
5. Clique em **"Invoke"** ou **"Run"**
6. Verifique se retorna sucesso

### 6. Testar no App

1. Vá no app → Painel Admin → Notificações Push
2. Envie uma notificação de teste
3. Verifique se aparece "Enviada para X dispositivo(s)"

## ❓ Onde Encontrar as Chaves VAPID?

Se você não tem as chaves:

1. Vá na pasta do projeto
2. Abra o arquivo `.env`
3. Procure por `VITE_VAPID_PUBLIC_KEY` - essa é a chave pública
4. Para a chave privada, você precisa ter gerado anteriormente (ou gere novas)

## 🔑 Gerar Novas Chaves (Se Precisar)

Se você não tem as chaves VAPID:

1. Acesse: https://web-push-codelab.glitch.me/
2. Ou use o script local (se conseguir):
   ```bash
   node scripts/generate-vapid-keys.js
   ```

## ✅ Checklist

- [ ] Edge Function deployada
- [ ] Secrets configurados (VAPID_PUBLIC_KEY, VAPID_PRIVATE_KEY, VAPID_SUBJECT)
- [ ] Função testada no dashboard
- [ ] Notificação testada no app

## 🆘 Se Ainda Não Funcionar

Me diga:
1. A função foi deployada com sucesso?
2. Os secrets estão configurados?
3. Qual erro aparece quando tenta enviar notificação?


