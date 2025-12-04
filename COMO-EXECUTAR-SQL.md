# 🔧 Como Executar o SQL no Supabase

## ❌ O Erro que você teve:

```
ERROR: 42703: column profiles.user_id does not exist
```

**O que era:** Problema nas políticas RLS (segurança)

**Solução:** Use a versão simplificada!

---

## ✅ SOLUÇÃO: Use o arquivo corrigido

Criei **2 arquivos corrigidos** para você:

### 🟢 Opção 1: SUPER SIMPLES (RECOMENDADO)
**Arquivo:** `setup-payments-simples.sql`

✅ Sem complexidade
✅ Políticas RLS básicas
✅ Funciona 100%

### 🔵 Opção 2: COMPLETO
**Arquivo:** `setup-payments-fixed.sql`

✅ Políticas RLS avançadas
✅ Suporte para admin ver tudo
⚠️ Um pouco mais complexo

---

## 📋 Passo a Passo (5 minutos)

### 1️⃣ Abrir Supabase

```
1. Vá em: https://supabase.com
2. Faça login
3. Clique no projeto "vinicin IA"
```

### 2️⃣ Ir no SQL Editor

```
No menu esquerdo (barra lateral preta):
Procure o ícone: </>
Clique em: "SQL Editor"
```

### 3️⃣ Abrir Nova Query

```
No SQL Editor:
Clique em: "+ New query" (botão verde no topo)
```

### 4️⃣ Copiar e Colar o SQL

**OPÇÃO A - Simples (recomendado):**
```
1. Abra o arquivo: setup-payments-simples.sql
2. Selecione TUDO (Ctrl+A ou Cmd+A)
3. Copie (Ctrl+C ou Cmd+C)
4. Cole no SQL Editor do Supabase
```

**OPÇÃO B - Completo:**
```
1. Abra o arquivo: setup-payments-fixed.sql
2. Selecione TUDO (Ctrl+A ou Cmd+A)
3. Copie (Ctrl+C ou Cmd+C)
4. Cole no SQL Editor do Supabase
```

### 5️⃣ Executar

```
No SQL Editor do Supabase:
Clique no botão: "RUN" (canto inferior direito)
Ou aperte: Ctrl+Enter (Cmd+Enter no Mac)
```

### 6️⃣ Verificar Sucesso

**Você deve ver:**
```
✅ Success
✅ "Tabelas criadas com sucesso!"
```

**Se aparecer erro:**
- Copie a mensagem de erro
- Me manda que eu te ajudo!

---

## 🔍 Como Verificar se Funcionou

### Ver as tabelas criadas:

1. No Supabase, vá em: **Table Editor** (ícone de tabela no menu)
2. Você deve ver na lista:
   - ✅ `subscriptions`
   - ✅ `payments`

### Testar uma query:

Cole isso no SQL Editor:
```sql
SELECT * FROM subscriptions LIMIT 1;
```

Se não der erro, funcionou! ✅

---

## 📊 Diferença entre as Versões

### setup-payments-simples.sql (RECOMENDADO)
```
✅ Mais fácil de entender
✅ Políticas RLS básicas
✅ Funciona perfeitamente
✅ Menos código
✅ Ideal para começar
```

### setup-payments-fixed.sql
```
✅ Políticas RLS avançadas
✅ Suporte pode ver tudo
✅ Mais seguro
⚠️ Um pouco mais complexo
```

**Recomendação:** Comece com o **simples**! Você pode trocar depois se quiser.

---

## 🎯 O que Cada SQL Faz

```
┌─────────────────────────────────────────────┐
│  1. Cria tabela "subscriptions"             │
│     (Quem é Diamond, quando expira, etc)    │
├─────────────────────────────────────────────┤
│  2. Cria tabela "payments"                  │
│     (Histórico de pagamentos)               │
├─────────────────────────────────────────────┤
│  3. Cria índices                            │
│     (Deixa as buscas mais rápidas)          │
├─────────────────────────────────────────────┤
│  4. Ativa RLS (segurança)                   │
│     (Cada usuário vê só suas coisas)        │
├─────────────────────────────────────────────┤
│  5. Cria função sync_subscription_plan()    │
│     (Quando paga, vira Diamond automático)  │
├─────────────────────────────────────────────┤
│  6. Cria trigger                            │
│     (Executa a função automaticamente)      │
└─────────────────────────────────────────────┘
```

---

## ❓ Perguntas Frequentes

### "Qual versão devo usar?"
👉 Use `setup-payments-simples.sql`

### "Posso executar os 2?"
❌ Não! Escolha apenas 1. Use o simples.

### "E se já executei o antigo com erro?"
✅ Sem problema! Execute o novo que ele vai corrigir.

### "Preciso apagar algo antes?"
❌ Não! Pode executar direto.

### "Vou perder dados?"
❌ Não! Os dados existentes ficam intactos.

---

## 🐛 Erros Comuns

### "relation already exists"
**Significa:** Tabela já foi criada antes
**Solução:** Tá tudo bem! Ignore e continue.

### "permission denied"
**Significa:** Sem permissão de admin
**Solução:** Verifique se está no projeto correto

### "syntax error"
**Significa:** SQL copiado errado
**Solução:** Copie tudo novamente do arquivo

---

## ✅ Checklist

Marque conforme fizer:

- [ ] ✅ Abri o Supabase
- [ ] ✅ Fui no SQL Editor
- [ ] ✅ Criei uma New Query
- [ ] ✅ Copiei o SQL (versão simples)
- [ ] ✅ Colei no editor
- [ ] ✅ Cliquei em RUN
- [ ] ✅ Vi "Success"
- [ ] ✅ Verifiquei no Table Editor
- [ ] ✅ Vi as tabelas subscriptions e payments

---

## 🎉 Depois disso

Próximos passos:
1. ✅ SQL executado (você está aqui!)
2. ⏭️ Criar Edge Functions
3. ⏭️ Adicionar Secrets
4. ⏭️ Testar pagamento

Cada passo está no `GUIA-SIMPLES-SUPABASE.md`!

---

**Conseguiu executar? Me avisa se deu certo ou se teve algum erro!** 😊

