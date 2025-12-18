# ✅ Aplicar Todas as Correções - Checklist Completo

## ✅ O que já foi feito:

1. ✅ **Chave VAPID atualizada no .env** (frontend)
2. ✅ **Código corrigido** com logs detalhados
3. ✅ **Script SQL criado** para corrigir RLS

## 📋 O que VOCÊ precisa fazer:

### 1. Configurar Secrets no Supabase ⚠️ IMPORTANTE

Acesse: **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**

Adicione estes 3 secrets:

**VAPID_PUBLIC_KEY:**
```
BJGycBNYXAneMYoI_SRqLYVP3wSehrgyH2uZmKJm28Kssdp1dkuKW60LLH_kFkSZyBEeUTgLIikR1JvBJhdKj9I
```

**VAPID_PRIVATE_KEY:**
```
L3b3eBUnGyvYKbg5PctWmnCXvniSJ9LETvDODJVwXLU
```

**VAPID_SUBJECT:**
```
mailto:admin@sociedadenutra.com
```
*(Substitua pelo seu email real)*

### 2. Executar SQL para Corrigir RLS

Execute no **SQL Editor** do Supabase:

```sql
-- Remover política existente se houver
DROP POLICY IF EXISTS "Service role can read all subscriptions" ON public.push_subscriptions;

-- Criar política para service_role
CREATE POLICY "Service role can read all subscriptions"
ON public.push_subscriptions 
FOR SELECT
TO service_role
USING (true);
```

### 3. Fazer Deploy da Edge Function

1. Vá em **Edge Functions** → **send-push-notification**
2. Clique em **"Redeploy"** ou **"Deploy"**

### 4. Verificar se Funcionou

1. Vá no app → **Painel Admin** → **Notificações Push**
2. Envie uma notificação de teste
3. Deve aparecer: **"Enviada para 2 dispositivo(s)"**

## 🔍 Verificar Logs

Se ainda não funcionar, verifique os logs:

1. **Edge Functions** → **send-push-notification** → **Logs**
2. Veja se aparece:
   - `🔑 VAPID configurado? { publicKey: true, privateKey: true, subject: true }`
   - `📊 Subscriptions encontradas: 2`

## ✅ Checklist Final

- [ ] Secrets configurados no Supabase (3 secrets)
- [ ] SQL executado para corrigir RLS
- [ ] Edge Function redeployada
- [ ] Teste de envio realizado
- [ ] Logs verificados

## 🆘 Se Ainda Não Funcionar

Me envie:
1. **Logs da Edge Function** (copie tudo)
2. **Resultado do SQL** (quantas subscriptions existem)
3. **Secrets configurados** (apenas confirme se estão lá)

