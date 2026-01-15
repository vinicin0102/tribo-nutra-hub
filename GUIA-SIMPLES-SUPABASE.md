# 🎯 Guia SUPER SIMPLES - Configurar Pagamentos no Supabase

## 📚 O que você vai fazer (resumo):

1. ✅ Executar um SQL no Supabase (criar tabelas)
2. ✅ Criar 2 "funções" no Supabase (processar pagamentos)
3. ✅ Adicionar 2 senhas secretas (tokens)
4. ✅ Testar se funcionou

**Tempo total:** ~20 minutos

---

## 🗄️ PASSO 1: Criar as Tabelas (5 minutos)

### O que são tabelas?
Pense como planilhas do Excel. Você vai criar 2 planilhas:
- **subscriptions** = guardar quem é Diamond
- **payments** = guardar histórico de pagamentos

### Como fazer:

1. **Abra o Supabase:**
   - Acesse: https://supabase.com
   - Faça login
   - Clique no seu projeto "vinicin IA"

2. **Vá no SQL Editor:**
   ```
   [Seu Projeto] → SQL Editor (ícone de </> no menu esquerdo)
   ```

3. **Copie e Cole:**
   - Abra o arquivo `setup-payments.sql` (está na pasta do projeto)
   - Copie TUDO (Ctrl+A, Ctrl+C)
   - Cole no SQL Editor do Supabase
   - Clique em **"RUN"** (botão verde no canto inferior direito)

4. **Pronto!** ✅
   - Você verá "Success. No rows returned"
   - As tabelas foram criadas!

**Verificar:**
```
Vá em: Table Editor → você verá "subscriptions" e "payments" na lista
```

---

## ⚡ PASSO 2: Criar as Edge Functions (10 minutos)

### O que são Edge Functions?
São "robôs" que fazem o trabalho pesado:
- **Robô 1:** Cria link de pagamento na Doppus
- **Robô 2:** Recebe notificação quando alguém paga

### Como fazer:

#### 2.1 - Instalar Supabase CLI

**No seu terminal/prompt:**

```bash
# Para Mac/Linux:
brew install supabase/tap/supabase

# Para Windows:
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

**Verificar instalação:**
```bash
supabase --version
```

#### 2.2 - Fazer Login

```bash
supabase login
```
- Vai abrir o navegador
- Faça login
- Volte pro terminal

#### 2.3 - Conectar ao Projeto

```bash
supabase link --project-ref oglakfbpuosrhhtbyprw
```
- Vai pedir pra confirmar
- Digite: yes

#### 2.4 - Criar Pastas e Arquivos

**Na pasta do seu projeto, crie esta estrutura:**

```
tribo-nutra-hub/
  └── supabase/
      └── functions/
          ├── create-doppus-checkout/
          │   └── index.ts
          └── doppus-webhook/
              └── index.ts
```

**Como criar (no terminal):**

```bash
# Vá pra pasta do projeto
cd ~/Downloads/tribo-nutra-hub-main/tribo-nutra-hub

# Criar as pastas
mkdir -p supabase/functions/create-doppus-checkout
mkdir -p supabase/functions/doppus-webhook

# Criar os arquivos vazios
touch supabase/functions/create-doppus-checkout/index.ts
touch supabase/functions/doppus-webhook/index.ts
```

#### 2.5 - Copiar o Código

**Arquivo 1:** `supabase/functions/create-doppus-checkout/index.ts`

👉 Copie o código que está no arquivo `DOPPUS-SETUP.md` (procure por "create-doppus-checkout")

**Arquivo 2:** `supabase/functions/doppus-webhook/index.ts`

👉 Copie o código que está no arquivo `DOPPUS-SETUP.md` (procure por "doppus-webhook")

#### 2.6 - Fazer Deploy (Subir pro Supabase)

```bash
# Deploy da função 1
supabase functions deploy create-doppus-checkout

# Deploy da função 2
supabase functions deploy doppus-webhook
```

**Pronto!** ✅ As funções estão no ar!

**Verificar:**
```
No Supabase Dashboard:
Edge Functions → você verá as 2 funções listadas
```

---

## 🔐 PASSO 3: Adicionar Senhas Secretas (3 minutos)

### O que são Secrets?
São senhas/tokens que as funções usam. Como uma chave de API.

### Como fazer:

1. **No Supabase Dashboard:**
   ```
   Project Settings (ícone de engrenagem) 
   → Edge Functions 
   → Secrets
   ```

2. **Adicionar Secret 1:**
   ```
   Name: DOPPUS_API_TOKEN
   Value: sk_test_seu_token_da_doppus_aqui
   ```
   
   👉 **Onde pegar:** 
   - Vá em https://doppus.com/
   - Faça login
   - Configurações → API
   - Copie o token

3. **Adicionar Secret 2:**
   ```
   Name: APP_URL
   Value: https://seuapp.vercel.app
   ```
   
   👉 **Qual URL usar:**
   - Se ainda não deployou no Vercel: `http://localhost:5173`
   - Se já deployou: a URL do Vercel (ex: `https://tribo-nutra-hub.vercel.app`)

4. **Clique em "Bulk save"** (botão verde)

**Pronto!** ✅ Secrets configurados!

**NÃO adicione:**
- ❌ SUPABASE_URL (já existe)
- ❌ SUPABASE_SERVICE_ROLE_KEY (já existe)

---

## 🧪 PASSO 4: Testar se Funcionou (2 minutos)

### Como testar:

1. **Abra seu app:**
   ```
   npm run dev
   ```

2. **Faça login** e vá em `/upgrade`

3. **Clique em "Assinar Plano Diamond"**

4. **O que DEVE acontecer:**
   - Abre uma nova aba
   - Mostra a página de checkout da Doppus
   - Pode preencher dados de pagamento

5. **Se deu erro:**
   - Veja os logs: `supabase functions logs create-doppus-checkout --tail`
   - Verifique se os secrets estão corretos

---

## 🎓 Explicando Cada Parte

### 🗄️ Tabelas (subscriptions e payments)
```
┌─────────────────────────────────────┐
│  TABELA: subscriptions              │
├─────────────────────────────────────┤
│ user_id │ plan_type │ status        │
│ abc123  │ diamond   │ active        │
│ def456  │ free      │ expired       │
└─────────────────────────────────────┘

Guarda: Quem tem Diamond, quando expira, etc.
```

### ⚡ Edge Functions
```
┌──────────────────────────────────────┐
│  1. create-doppus-checkout           │
│     Quando: Usuário clica "Assinar"  │
│     Faz: Cria link de pagamento      │
│     Retorna: URL da Doppus           │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  2. doppus-webhook                   │
│     Quando: Usuário paga na Doppus   │
│     Faz: Ativa assinatura Diamond    │
│     Salva: Dados em subscriptions    │
└──────────────────────────────────────┘
```

### 🔐 Secrets
```
São como senhas que as funções usam:

DOPPUS_API_TOKEN = "chave pra acessar Doppus"
APP_URL = "onde seu app está hospedado"
```

---

## 🔍 Onde Está Cada Coisa?

### No seu computador:
```
tribo-nutra-hub/
├── setup-payments.sql          ← SQL pra criar tabelas
├── DOPPUS-SETUP.md            ← Documentação completa
├── src/
│   ├── hooks/usePayments.ts   ← Código React
│   └── pages/Upgrade.tsx      ← Página de upgrade
└── supabase/
    └── functions/              ← Edge Functions
        ├── create-doppus-checkout/
        └── doppus-webhook/
```

### No Supabase Dashboard:
```
Project → SQL Editor           ← Onde executar SQL
Project → Table Editor         ← Ver tabelas criadas
Project → Edge Functions       ← Ver funções deployadas
Project → Settings → Secrets   ← Adicionar tokens
```

---

## ❓ Perguntas Frequentes

### "Não sei programar, consigo fazer?"
✅ Sim! É só copiar e colar os códigos. Não precisa entender.

### "Preciso mexer no código?"
❌ Não! Só copiar os arquivos prontos.

### "E se der erro?"
💬 Me avise qual erro apareceu que eu te ajudo!

### "Quanto custa?"
💚 Supabase é grátis até 500MB de banco
💰 Doppus cobra só quando vende (4,99% + R$0,40)

### "Posso usar Mercado Pago?"
✅ Sim! Mas Doppus é melhor pra assinaturas.

### "Preciso de CNPJ?"
⚠️ Sim, tanto Doppus quanto Mercado Pago pedem.

---

## 📝 Checklist Final

Marque conforme for fazendo:

- [ ] ✅ SQL executado (tabelas criadas)
- [ ] ✅ Supabase CLI instalado
- [ ] ✅ Login feito (`supabase login`)
- [ ] ✅ Projeto linkado (`supabase link`)
- [ ] ✅ Pastas criadas (`supabase/functions/`)
- [ ] ✅ Códigos copiados (index.ts)
- [ ] ✅ Deploy feito (`supabase functions deploy`)
- [ ] ✅ Secrets adicionados (DOPPUS_API_TOKEN e APP_URL)
- [ ] ✅ Teste realizado (clicou em "Assinar")
- [ ] ✅ Checkout abriu!

---

## 🆘 Precisa de Ajuda?

**Se travar em algum passo:**

1. Veja qual erro aparece
2. Leia a mensagem de erro
3. Me manda print/texto do erro
4. Te ajudo a resolver!

**Comandos úteis:**

```bash
# Ver se funções estão no ar
supabase functions list

# Ver logs em tempo real
supabase functions logs create-doppus-checkout --tail
supabase functions logs doppus-webhook --tail

# Testar função localmente
supabase functions serve create-doppus-checkout
```

---

## 🎉 Quando Terminar

Você terá:
- ✅ Sistema de pagamentos funcionando
- ✅ Assinaturas Diamond automatizadas
- ✅ Checkout da Doppus integrado
- ✅ Webhooks processando pagamentos

**E o melhor:** Funciona 24/7 sozinho! 🚀

---

**Ainda com dúvida em alguma parte específica? Me fala qual passo tá confuso que eu explico melhor!** 😊


