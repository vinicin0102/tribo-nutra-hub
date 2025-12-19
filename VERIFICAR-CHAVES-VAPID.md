# 🔑 Verificar Chaves VAPID

## 📋 Onde Verificar

### 1. No Frontend (.env)

A chave pública VAPID deve estar no arquivo `.env`:

```bash
VITE_VAPID_PUBLIC_KEY=BOlpF9ZAdxaamQgTTka0zCJu2SvAJXabWdEuqqcbSfcKbNVC79QvXgp2m9ljiurQTcIOfk0AZ20Y_iSCePPvIcY
```

**Verificar:**
- ✅ Chave existe no `.env`
- ✅ Chave tem ~87 caracteres
- ✅ Chave não tem espaços ou quebras de linha

### 2. No Supabase Secrets (Backend)

As chaves devem estar configuradas nos **Secrets** do Supabase:

1. Acesse **Supabase Dashboard**
2. Vá em **Project Settings** → **Edge Functions** → **Secrets**
3. Verifique se existem:
   - `VAPID_PUBLIC_KEY` ✅
   - `VAPID_PRIVATE_KEY` ✅
   - `VAPID_SUBJECT` ✅ (formato: `mailto:seu@email.com`)

### 3. Verificar se as Chaves Estão Corretas

**Chave Pública (Frontend):**
```
BOlpF9ZAdxaamQgTTka0zCJu2SvAJXabWdEuqqcbSfcKbNVC79QvXgp2m9ljiurQTcIOfk0AZ20Y_iSCePPvIcY
```

**Chave Privada (Backend):**
- Deve estar nos Secrets do Supabase
- Não deve ser exposta no frontend

**VAPID Subject:**
- Formato: `mailto:seu@email.com`
- Exemplo: `mailto:admin@sociedadenutra.com`

## 🔍 Como Verificar se Estão Corretas

### Teste 1: Validar Chave Pública

Execute no console do navegador (F12):

```javascript
const key = 'BOlpF9ZAdxaamQgTTka0zCJu2SvAJXabWdEuqqcbSfcKbNVC79QvXgp2m9ljiurQTcIOfk0AZ20Y_iSCePPvIcY';
const padding = '='.repeat((4 - (key.length % 4)) % 4);
const base64 = (key + padding).replace(/-/g, '+').replace(/_/g, '/');
const decoded = atob(base64);
console.log('Tamanho:', decoded.length, 'bytes (deve ser 65)');
console.log('Primeiro byte:', decoded.charCodeAt(0), '(deve ser 4)');
console.log('Válida?', decoded.length === 65 && decoded.charCodeAt(0) === 4);
```

### Teste 2: Verificar no Código

A chave pública deve estar sendo carregada em:
- `src/hooks/usePushNotifications.ts` (linha ~170)
- Deve buscar de `import.meta.env.VITE_VAPID_PUBLIC_KEY`

## ❌ Problemas Comuns

### Problema 1: Chave não está no .env

**Solução:** Adicionar no `.env`:
```
VITE_VAPID_PUBLIC_KEY=BOlpF9ZAdxaamQgTTka0zCJu2SvAJXabWdEuqqcbSfcKbNVC79QvXgp2m9ljiurQTcIOfk0AZ20Y_iSCePPvIcY
```

### Problema 2: Chaves não estão nos Secrets do Supabase

**Solução:** Adicionar nos Secrets:
1. Vá em **Project Settings** → **Edge Functions** → **Secrets**
2. Adicione:
   - `VAPID_PUBLIC_KEY` = mesma chave do `.env`
   - `VAPID_PRIVATE_KEY` = chave privada (gerada anteriormente)
   - `VAPID_SUBJECT` = `mailto:seu@email.com`

### Problema 3: Chaves não correspondem

**Solução:** As chaves pública e privada devem ser um par. Se não corresponderem, gere novas:
```bash
node scripts/generate-vapid-keys.js
```

## 📋 Checklist

- [ ] Chave pública no `.env` (frontend)
- [ ] Chave pública nos Secrets do Supabase
- [ ] Chave privada nos Secrets do Supabase
- [ ] VAPID_SUBJECT nos Secrets do Supabase
- [ ] Chaves são um par válido
- [ ] Chave pública tem ~87 caracteres
- [ ] Chave pública decodifica para 65 bytes
- [ ] Primeiro byte é 4 (0x04)

## 🚀 Próximos Passos

1. Verifique se todas as chaves estão configuradas
2. Se não estiverem, adicione nos lugares corretos
3. Se as chaves não corresponderem, gere novas
4. Teste novamente o envio de notificações


