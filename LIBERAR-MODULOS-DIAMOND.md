# 🔓 Liberação Automática de Módulos para Diamond

## 📋 O que foi implementado

Quando um usuário assina o plano Diamond, **todos os módulos bloqueados são desbloqueados automaticamente**.

## ⚙️ Como funciona

### 1. Trigger Automático no Banco de Dados

Foi criado um **trigger** no banco de dados que:
- Monitora mudanças na coluna `subscription_plan` da tabela `profiles`
- Quando o plano muda para `'diamond'`, executa automaticamente
- Desbloqueia todos os módulos que têm `is_locked = true`

### 2. Função `auto_unlock_modules_on_diamond()`

Esta função:
- Busca todos os módulos bloqueados (`is_locked = true`)
- Insere cada módulo na tabela `unlocked_modules` para o usuário
- Usa `ON CONFLICT DO NOTHING` para evitar duplicatas

### 3. Quando é executado

O trigger é executado automaticamente quando:
- ✅ Webhook do Stripe atualiza o plano
- ✅ Admin atualiza o plano manualmente via painel
- ✅ Função RPC `change_user_plan_admin` é chamada
- ✅ Qualquer UPDATE na coluna `subscription_plan` para 'diamond'

## 🚀 Como aplicar

Execute a migration no Supabase Dashboard:

1. Acesse **Supabase Dashboard** > **SQL Editor**
2. Execute o arquivo: `supabase/migrations/20251212190000_auto_unlock_modules_on_diamond.sql`

Ou copie e cole o conteúdo do arquivo diretamente no SQL Editor.

## ✅ Verificação

Após executar a migration, você pode testar:

```sql
-- 1. Verificar se a função foi criada
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'auto_unlock_modules_on_diamond';

-- 2. Verificar se o trigger foi criado
SELECT trigger_name 
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_auto_unlock_modules_on_diamond';

-- 3. Testar manualmente (substitua USER_ID pelo ID do usuário)
UPDATE profiles 
SET subscription_plan = 'diamond' 
WHERE user_id = 'USER_ID';

-- 4. Verificar se os módulos foram desbloqueados
SELECT * FROM unlocked_modules WHERE user_id = 'USER_ID';
```

## 📝 Notas Importantes

- O trigger só executa quando o plano **muda** para Diamond (não executa se já for Diamond)
- Módulos já desbloqueados não são afetados (usa `ON CONFLICT DO NOTHING`)
- A função usa `SECURITY DEFINER` para ignorar políticas RLS
- Funciona automaticamente, sem necessidade de intervenção manual

## 🔄 Atualização da Interface

O frontend foi atualizado para invalidar as queries de módulos quando o plano Diamond é ativado, garantindo que a interface atualize imediatamente.

