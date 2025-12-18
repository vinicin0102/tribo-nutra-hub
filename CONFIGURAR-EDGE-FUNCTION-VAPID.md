# 🚀 Configurar Edge Function para VAPID Public Key

## 📋 O que foi criado:

1. **Edge Function** (`supabase/functions/get-vapid-public-key/index.ts`)
   - Retorna a chave VAPID pública do backend
   - Mais confiável que variável de ambiente

2. **Código atualizado** no `usePushNotifications.ts`
   - Tenta buscar do backend primeiro
   - Fallback para `.env` se backend falhar
   - Fallback para chave hardcoded se tudo falhar

## 🔧 Como Configurar:

### 1. Adicionar VAPID_PUBLIC_KEY nas Supabase Secrets

No Supabase Dashboard ou via CLI:

```bash
supabase secrets set VAPID_PUBLIC_KEY=BGlpREcbTdz2SRMHeOGGCBCeRGwqx6i9LpcSXg6dD1_yPkLSCNV6TDWtlHNGYPHe6mqKoiW5TVPtBi2lCY3w7xY
```

**Ou no Supabase Dashboard:**
1. Vá em **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   - **Name:** `VAPID_PUBLIC_KEY`
   - **Value:** `BGlpREcbTdz2SRMHeOGGCBCeRGwqx6i9LpcSXg6dD1_yPkLSCNV6TDWtlHNGYPHe6mqKoiW5TVPtBi2lCY3w7xY`

### 2. Fazer Deploy da Edge Function

**Opção A - Via Supabase CLI:**

```bash
# Instalar Supabase CLI (se não tiver)
npm install -g supabase

# Login no Supabase
supabase login

# Linkar ao projeto
supabase link --project-ref seu-project-ref

# Deploy da function
supabase functions deploy get-vapid-public-key
```

**Opção B - Via Supabase Dashboard:**
1. Vá em **Edge Functions**
2. Clique em **Create Function**
3. Nome: `get-vapid-public-key`
4. Cole o código do arquivo `supabase/functions/get-vapid-public-key/index.ts`
5. Clique em **Deploy**

### 3. Testar a Function

No console do navegador, teste:

```javascript
const { data } = await supabase.functions.invoke('get-vapid-public-key');
console.log('Chave VAPID:', data?.vapidPublicKey);
```

Deve retornar a chave VAPID pública.

## ✅ Vantagens desta Abordagem:

1. **Mais confiável** - Chave vem do backend, não depende de build
2. **Centralizada** - Uma única fonte de verdade
3. **Segura** - Chave não exposta no código frontend
4. **Flexível** - Pode mudar sem rebuild

## 🔄 Ordem de Fallback:

O código agora tenta nesta ordem:

1. **Backend (Edge Function)** ← Mais confiável
2. **Variável de ambiente (.env)** ← Fallback
3. **Chave hardcoded** ← Último recurso

## 📝 Notas:

- A Edge Function precisa estar deployada e configurada
- A chave VAPID_PUBLIC_KEY precisa estar nas Supabase Secrets
- Se a function não estiver disponível, usa o fallback do .env
- Isso resolve problemas de chave não carregada do .env

## 🚀 Próximos Passos:

1. ✅ Adicionar `VAPID_PUBLIC_KEY` nas Supabase Secrets
2. ✅ Fazer deploy da Edge Function
3. ✅ Testar se a chave é retornada corretamente
4. ✅ Tentar ativar notificações novamente

