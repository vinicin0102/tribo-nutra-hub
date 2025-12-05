# 📍 ONDE PEGAR: Token e URL do App

## 🔑 1. ONDE PEGAR O TOKEN DA DOPPUS

### Passo a Passo:

1. **Acesse a Doppus:**
   - Vá em: https://doppus.com/
   - Faça login na sua conta

2. **Vá para Configurações:**
   - No menu lateral, clique em **"Configurações"** (ou "Settings")
   - Ou procure por **"API"** no menu

3. **Encontre a seção API:**
   - Procure por **"API"** ou **"Integrações"**
   - Clique em **"API"** ou **"Tokens"**

4. **Copie o Token:**
   - Você verá algo como:
     ```
     API Token: sk_test_abc123xyz456...
     ```
   - Clique no botão **"Copiar"** ou selecione e copie manualmente
   - ⚠️ **IMPORTANTE:** Use o token que começa com `sk_test_` para testes!

5. **O token vai parecer assim:**
   ```
   sk_test_abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
   ```

---

## 🌐 2. ONDE PEGAR A URL DO APP

### Opção A: Se está no Vercel

1. **Acesse o Vercel:**
   - Vá em: https://vercel.com/
   - Faça login

2. **Encontre seu projeto:**
   - Clique no projeto **"tribo-nutra-hub"** (ou o nome do seu projeto)

3. **Veja a URL:**
   - Na página do projeto, você verá algo como:
     ```
     Production
     https://tribo-nutra-hub.vercel.app
     ```
   - **Copie essa URL completa**

4. **A URL vai parecer assim:**
   ```
   https://tribo-nutra-hub.vercel.app
   ```
   - ⚠️ **NÃO coloque `/` no final!**

### Opção B: Se tem domínio personalizado

1. **No Vercel:**
   - Vá em: **Settings** → **Domains**
   - Você verá seu domínio personalizado
   - Exemplo: `https://tribonutra.com.br`

2. **Use o domínio personalizado:**
   ```
   https://seudominio.com.br
   ```

### Opção C: Se ainda não fez deploy

1. **Faça o deploy primeiro:**
   ```bash
   # No terminal, na pasta do projeto:
   vercel --prod
   ```

2. **Depois pegue a URL que aparecer**

---

## 📸 EXEMPLO VISUAL

### Doppus - Onde está o Token:

```
┌─────────────────────────────────────────┐
│  Doppus Dashboard                       │
├─────────────────────────────────────────┤
│                                         │
│  [🏠 Início]  [📦 Produtos]  [⚙️ Config] │
│                                         │
│  ⚙️ Configurações                      │
│  ├─ Perfil                              │
│  ├─ Empresa                             │
│  ├─ 💳 API          ← CLIQUE AQUI!      │
│  ├─ Webhooks                            │
│  └─ Notificações                        │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  💳 API                           │ │
│  ├───────────────────────────────────┤ │
│  │                                   │ │
│  │  API Token:                      │ │
│  │  ┌─────────────────────────────┐  │ │
│  │  │ sk_test_abc123xyz...       │  │ │
│  │  └─────────────────────────────┘  │ │
│  │  [👁 Mostrar] [📋 Copiar]       │ │
│  │                                   │ │
│  │  ⚠️ Use sk_test_ para testes     │ │
│  │  ⚠️ Use sk_live_ para produção   │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Vercel - Onde está a URL:

```
┌─────────────────────────────────────────┐
│  Vercel Dashboard                      │
├─────────────────────────────────────────┤
│                                         │
│  📁 tribo-nutra-hub                    │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Production                       │ │
│  │  ┌─────────────────────────────┐  │ │
│  │  │ https://tribo-nutra-hub    │  │ │
│  │  │     .vercel.app            │  │ │
│  │  └─────────────────────────────┘  │ │
│  │  [🌐 Abrir] [📋 Copiar]          │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Ou em Settings → Domains:             │
│  ┌───────────────────────────────────┐ │
│  │  Custom Domain                   │ │
│  │  https://seudominio.com.br       │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## ✅ CHECKLIST RÁPIDO

### Token da Doppus:
- [ ] Fiz login na Doppus (https://doppus.com/)
- [ ] Fui em "Configurações" → "API"
- [ ] Copiei o token que começa com `sk_test_`
- [ ] O token está completo (muito longo, tipo 50+ caracteres)

### URL do App:
- [ ] Fiz login no Vercel (https://vercel.com/)
- [ ] Encontrei meu projeto
- [ ] Copiei a URL de produção (ex: `https://tribo-nutra-hub.vercel.app`)
- [ ] NÃO coloquei `/` no final

---

## 🎯 EXEMPLO DO QUE VOCÊ VAI ME ENVIAR

```
Token da Doppus:
sk_test_abc123def456ghi789jkl012mno345pqr678stu901vwx234yz

URL do App:
https://tribo-nutra-hub.vercel.app
```

---

## ❓ DÚVIDAS COMUNS

### "Não encontro a seção API na Doppus"
- Procure por "Integrações" ou "Tokens"
- Ou "Configurações" → "Desenvolvedor"
- Se não encontrar, pode ser que precise ativar a conta primeiro

### "Não vejo URL no Vercel"
- Certifique-se de que fez o deploy
- Procure em "Deployments" → clique no último deploy
- Ou vá em "Settings" → "Domains"

### "Qual URL usar se tenho várias?"
- Use a URL de **Produção** (não Preview)
- Se tem domínio personalizado, use ele
- Se não tem, use a `.vercel.app`

---

## 🚀 PRÓXIMO PASSO

Depois que pegar as duas informações:
1. Token da Doppus
2. URL do App

**Me envie aqui no chat!** E eu configuro tudo! 🎉

