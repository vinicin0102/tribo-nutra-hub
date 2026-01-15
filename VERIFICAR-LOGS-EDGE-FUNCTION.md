# 📋 Como Verificar Logs da Edge Function

## 🔍 Passo a Passo

### 1. Acessar Logs

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Edge Functions** (menu lateral)
4. Clique em **send-push-notification**
5. Clique na aba **"Logs"**

### 2. Enviar Notificação de Teste

1. Vá no app → **Painel Admin** → **Notificações Push**
2. Preencha título e mensagem
3. Clique em **"Enviar"**
4. **IMEDIATAMENTE** vá para os logs

### 3. Copiar TODOS os Logs

Nos logs, você deve ver uma sequência como:

```
📥 Recebida requisição: POST
🔑 VAPID configurado? { publicKey: true, privateKey: true, subject: true }
🔑 VAPID Public Key (primeiros 20 chars): BJGycBNYXAneMYoI_SRq...
🔑 VAPID Public Key (tamanho): 87
🔑 VAPID Private Key (primeiros 10 chars): L3b3eBUnGy...
🔑 VAPID Private Key (tamanho): 43
🔑 VAPID Subject: mailto:...
📋 Dados recebidos: { title: "...", body: "...", ... }
🔍 Buscando subscriptions no banco...
🧪 Teste de conexão: { success: true/false, ... }
📊 Subscriptions encontradas: X
📦 Importando biblioteca web-push...
✅ Biblioteca web-push importada com sucesso
🔧 Configurando VAPID details...
✅ VAPID details configurados
📨 Tentando enviar para: ...
```

## ❓ O Que Procurar

### Se aparecer `📊 Subscriptions encontradas: 0`

**Problema:** RLS está bloqueando ou tabela está vazia

**Solução:**
1. Execute o SQL para criar política para service_role
2. Verifique se há subscriptions no banco

### Se aparecer `❌ Erro ao importar web-push`

**Problema:** Biblioteca não funciona no Deno

**Solução:** Implementar manualmente (vou fazer isso)

### Se aparecer `❌ Erro ao configurar VAPID`

**Problema:** Chaves VAPID incorretas

**Solução:** Verificar secrets no Supabase

### Se aparecer `❌ Erro ao enviar para endpoint`

**Problema:** Erro ao enviar notificação

**Solução:** Verificar mensagem de erro específica

## 📋 Me Envie

**Copie e cole TODOS os logs** que aparecem quando você envia uma notificação.

Isso vai mostrar exatamente onde está falhando!
