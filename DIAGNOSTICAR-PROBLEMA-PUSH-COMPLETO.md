# 🔍 Diagnóstico Completo - Push Notifications Não Funcionam

## ✅ Checklist de Verificação

### 1️⃣ Verificar Subscriptions no Banco

Execute este SQL no **Supabase SQL Editor**:

```sql
-- Verificar quantas subscriptions existem
SELECT COUNT(*) as total_subscriptions FROM public.push_subscriptions;

-- Ver detalhes das subscriptions
SELECT 
  id,
  user_id,
  LEFT(endpoint, 60) as endpoint_preview,
  LENGTH(p256dh) as p256dh_size,
  LENGTH(auth) as auth_size,
  created_at,
  updated_at
FROM public.push_subscriptions
ORDER BY updated_at DESC
LIMIT 10;
```

**O que verificar:**
- ✅ Se `total_subscriptions` for **0**, nenhum usuário ativou push notifications
- ✅ Se `total_subscriptions` for **> 0**, mas as notificações não chegam, o problema está no envio

---

### 2️⃣ Verificar RLS (Row Level Security)

Execute este SQL:

```sql
-- Verificar se RLS está ativo
SELECT 
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'push_subscriptions';

-- Ver TODAS as políticas RLS
SELECT 
  policyname,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'push_subscriptions';
```

**O que verificar:**
- ✅ Deve existir uma política que permite `service_role` ler todas as subscriptions
- ✅ Se não existir, execute o script `CORRIGIR-RLS-SERVICE-ROLE.sql`

---

### 3️⃣ Verificar Logs da Edge Function

**Passo a passo:**

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Edge Functions** (menu lateral)
4. Clique em **send-push-notification**
5. Clique na aba **"Logs"**
6. **Envie uma notificação de teste** pelo app (Painel Admin → Notificações Push)
7. **Imediatamente** volte aos logs e copie **TUDO** que aparecer

**O que procurar nos logs:**

```
📥 Recebida requisição: POST
🔑 VAPID configurado? { publicKey: true, privateKey: true, subject: true }
📋 Dados recebidos: { title: "...", body: "..." }
🔍 Buscando subscriptions no banco...
🧪 Teste de conexão: { success: true/false, ... }
📊 Subscriptions encontradas: X
```

**Possíveis problemas:**

- ❌ `📊 Subscriptions encontradas: 0` → RLS bloqueando ou tabela vazia
- ❌ `❌ Erro ao buscar subscriptions` → Problema de RLS ou conexão
- ❌ `❌ Erro ao importar web-push` → Problema com biblioteca
- ❌ `❌ Erro ao configurar VAPID` → Chaves VAPID incorretas

---

### 4️⃣ Verificar Chaves VAPID

**No Supabase Dashboard:**

1. Vá em **Settings** → **Edge Functions** → **Secrets**
2. Verifique se existem:
   - `VAPID_PUBLIC_KEY`
   - `VAPID_PRIVATE_KEY`
   - `VAPID_SUBJECT`

**Verificar formato das chaves:**

- ✅ `VAPID_PUBLIC_KEY`: Deve ter ~87 caracteres (base64 URL-safe)
- ✅ `VAPID_PRIVATE_KEY`: Deve ter ~43 caracteres (base64 URL-safe)
- ✅ `VAPID_SUBJECT`: Deve ser um email válido (ex: `mailto:seu@email.com`)

**⚠️ IMPORTANTE:** As chaves devem ser as **mesmas** usadas no frontend (`.env`)

---

### 5️⃣ Testar Edge Function Manualmente

Execute este código no **Supabase SQL Editor** (ou use o **API Explorer**):

```sql
-- Isso não funciona diretamente no SQL, mas você pode usar o API Explorer
-- ou fazer uma requisição HTTP manual
```

**Ou use o curl no terminal:**

```bash
curl -X POST \
  'https://SEU_PROJETO.supabase.co/functions/v1/send-push-notification' \
  -H 'Authorization: Bearer SEU_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "title": "Teste Manual",
    "body": "Esta é uma notificação de teste",
    "url": "/"
  }'
```

**Substitua:**
- `SEU_PROJETO` → Seu projeto Supabase (ex: `oglakfbpuosrhhtbyprw`)
- `SEU_ANON_KEY` → Sua chave anon do Supabase

---

### 6️⃣ Verificar Service Worker no Frontend

**No navegador (Chrome DevTools):**

1. Abra o app no navegador
2. Pressione `F12` (ou `Cmd+Option+I` no Mac)
3. Vá na aba **Application** → **Service Workers**
4. Verifique se há um Service Worker ativo
5. Vá em **Application** → **Storage** → **IndexedDB**
6. Verifique se há dados de push subscriptions

---

## 🎯 Soluções Comuns

### Problema: "Subscriptions encontradas: 0"

**Solução 1:** Executar SQL para permitir service_role ler subscriptions:

```sql
-- Permitir service_role ler todas as subscriptions
CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions
FOR SELECT
TO service_role
USING (true);
```

**Solução 2:** Verificar se há subscriptions no banco (passo 1)

---

### Problema: "Erro ao buscar subscriptions"

**Solução:** Verificar se a política RLS para `service_role` existe (passo 2)

---

### Problema: "Erro ao configurar VAPID"

**Solução:** 
1. Verificar se as chaves VAPID estão nos secrets do Supabase
2. Verificar se o formato está correto (sem espaços, quebras de linha)
3. Regenerar as chaves se necessário

---

### Problema: Notificações enviadas mas não chegam

**Possíveis causas:**
1. **Service Worker não está ativo** → Verificar passo 6
2. **Subscription expirada** → O endpoint pode ter expirado
3. **Chaves VAPID diferentes** → Frontend e backend devem usar as mesmas chaves
4. **Navegador não suporta** → Safari tem suporte limitado

---

## 📋 Checklist Final

Antes de reportar o problema, verifique:

- [ ] Há subscriptions no banco? (passo 1)
- [ ] RLS permite service_role ler? (passo 2)
- [ ] Logs da Edge Function mostram erro? (passo 3)
- [ ] Chaves VAPID estão configuradas? (passo 4)
- [ ] Service Worker está ativo? (passo 6)
- [ ] Frontend e backend usam as mesmas chaves VAPID?

---

## 🆘 Próximos Passos

Depois de executar todos os passos acima, **me envie:**

1. ✅ Resultado do SQL do passo 1 (quantas subscriptions)
2. ✅ Resultado do SQL do passo 2 (políticas RLS)
3. ✅ **Logs completos** da Edge Function (passo 3) - **ISSO É CRUCIAL**
4. ✅ Screenshot das chaves VAPID configuradas (sem mostrar valores completos)

Com essas informações, consigo identificar exatamente onde está o problema! 🎯


