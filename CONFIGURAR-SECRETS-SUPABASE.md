# 🔐 Configurar Secrets no Supabase

## 📋 Chaves para Configurar

Use estas chaves **EXATAS** (copie e cole):

### 1. VAPID_PUBLIC_KEY
```
BJGycBNYXAneMYoI_SRqLYVP3wSehrgyH2uZmKJm28Kssdp1dkuKW60LLH_kFkSZyBEeUTgLIikR1JvBJhdKj9I
```

### 2. VAPID_PRIVATE_KEY
```
L3b3eBUnGyvYKbg5PctWmnCXvniSJ9LETvDODJVwXLU
```

### 3. VAPID_SUBJECT
```
mailto:admin@sociedadenutra.com
```
*(Substitua pelo seu email real)*

## 🚀 Como Configurar

### Passo 1: Acessar Secrets

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Project Settings** (ícone de engrenagem)
4. Clique em **Edge Functions** no menu lateral
5. Clique em **Secrets**

### Passo 2: Adicionar/Atualizar Secrets

Para cada secret:

1. Clique em **"Add new secret"** (ou edite se já existir)
2. **Name:** Cole o nome exato (ex: `VAPID_PUBLIC_KEY`)
3. **Value:** Cole o valor correspondente
4. Clique em **"Save"**

**Repita para os 3 secrets:**
- ✅ `VAPID_PUBLIC_KEY`
- ✅ `VAPID_PRIVATE_KEY`
- ✅ `VAPID_SUBJECT`

### Passo 3: Verificar

Após adicionar, você deve ver os 3 secrets listados:
- VAPID_PUBLIC_KEY ✅
- VAPID_PRIVATE_KEY ✅
- VAPID_SUBJECT ✅

## ⚠️ IMPORTANTE

- **NÃO** adicione espaços ou quebras de linha
- **COPIE EXATAMENTE** como está acima
- **VAPID_SUBJECT** deve começar com `mailto:`

## ✅ Após Configurar

1. Faça **redeploy** da Edge Function `send-push-notification`
2. Teste enviando uma notificação
3. Verifique os logs para confirmar que as chaves foram carregadas

## 🔍 Verificar se Funcionou

Nos logs da Edge Function, você deve ver:
- `🔑 VAPID configurado? { publicKey: true, privateKey: true, subject: true }`

Se aparecer `false` em algum, o secret não foi configurado corretamente.

