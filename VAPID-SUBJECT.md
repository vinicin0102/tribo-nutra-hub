# 📧 VAPID Subject - O que é e como configurar

## O que é VAPID Subject?

O **VAPID Subject** é um identificador obrigatório para VAPID que indica **quem está enviando** as notificações push. É usado para autenticação e identificação do servidor.

## Formato

O VAPID Subject deve ser:
- Um email no formato: `mailto:seu-email@exemplo.com`
- Ou uma URL: `https://seu-dominio.com`

**Recomendado:** Use o formato `mailto:` com um email válido.

## Exemplos

```
mailto:contato@sociedadenutra.com
mailto:suporte@tribonutra.com
mailto:admin@exemplo.com
```

## Onde usar?

### 1. **Frontend (`.env`)**
❌ **NÃO precisa** - O Subject só é usado no backend

### 2. **Backend (Supabase Secrets)**
✅ **SIM** - Quando criar a Edge Function, adicione:

```bash
supabase secrets set VAPID_SUBJECT=mailto:seu-email@exemplo.com
```

## Como configurar

### Opção 1: Usar email da empresa/app
```
mailto:contato@sociedadenutra.com
```

### Opção 2: Usar email pessoal (para testes)
```
mailto:seu-email@gmail.com
```

### Opção 3: Usar email do Supabase
```
mailto:seu-email@supabase.com
```

## ⚠️ Importante

1. **Deve ser um email válido** (pode ser usado para contato em caso de problemas)
2. **Não precisa ser verificado** - é apenas um identificador
3. **Pode ser qualquer email** - não precisa ser o mesmo do Supabase
4. **Use o mesmo Subject** para todas as notificações do app

## 📋 Resumo das Chaves VAPID

| Chave | Onde usar | Exemplo |
|-------|-----------|---------|
| **Public Key** | Frontend (`.env`) | `VITE_VAPID_PUBLIC_KEY=...` |
| **Private Key** | Backend (Supabase Secrets) | `VAPID_PRIVATE_KEY=...` |
| **Subject** | Backend (Supabase Secrets) | `VAPID_SUBJECT=mailto:...` |

## 🚀 Quando configurar?

Você só precisa configurar o VAPID Subject quando:
- ✅ Criar a Edge Function para enviar notificações
- ✅ Adicionar nas Supabase Secrets junto com a Private Key

**Por enquanto, você não precisa configurar** - só será necessário quando for implementar o envio real de notificações.

## 💡 Sugestão

Use um email relacionado ao app:
```
mailto:contato@sociedadenutra.com
```

Ou se não tiver email próprio:
```
mailto:seu-email-pessoal@gmail.com
```

