# ⚠️ IMPORTANTE: Como Executar o SQL

## ❌ Erro Comum

Se você viu este erro:
```
ERROR: 42601: syntax error at or near "#"
```

**Isso significa que você tentou executar um arquivo `.md` (Markdown) no SQL Editor!**

---

## ✅ Solução

### 1. Abra o arquivo SQL correto:
- ✅ **`create-stripe-payments-tables.sql`** ← Execute este!
- ❌ ~~`CONFIGURAR-STRIPE-RAPIDO.md`~~ ← Este é apenas documentação!

### 2. Passo a Passo:

1. **Abra o Supabase Dashboard**
2. **Vá em SQL Editor** (ícone de banco de dados no menu lateral)
3. **Clique em "New query"**
4. **Abra o arquivo `create-stripe-payments-tables.sql`** no seu editor de código
5. **Copie TODO o conteúdo** do arquivo `.sql`
6. **Cole no SQL Editor do Supabase**
7. **Clique em "Run"** ou pressione `Ctrl+Enter` (Windows) / `Cmd+Enter` (Mac)

---

## 📋 Diferença entre Arquivos

| Arquivo | Tipo | O que fazer |
|---------|------|-------------|
| `create-stripe-payments-tables.sql` | **SQL** | ✅ **EXECUTAR** no SQL Editor |
| `CONFIGURAR-STRIPE-RAPIDO.md` | Markdown | 📖 Apenas ler (documentação) |
| `STRIPE-SETUP.md` | Markdown | 📖 Apenas ler (documentação) |

---

## ✅ Verificação

Após executar o SQL, você deve ver:
```
✓ Tabela subscriptions
✓ Tabela payments
✓ Função sync_subscription_plan
```

Se aparecer `✗`, algo deu errado. Me avise!

---

## 🚀 Próximos Passos

Depois de executar o SQL:
1. Configure os secrets do Stripe no Supabase
2. Faça deploy das Edge Functions
3. Configure o webhook no Stripe
4. Teste o pagamento

---

**💡 Dica:** Sempre verifique se o arquivo termina com `.sql` antes de executar!

