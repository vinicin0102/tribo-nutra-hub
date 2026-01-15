# 🧪 Como Testar a Liberação Automática de Módulos

## 📋 Passo a Passo

### 1. Execute a Migration Primeiro

Antes de testar, certifique-se de que a migration foi executada:

1. Acesse **Supabase Dashboard** > **SQL Editor**
2. Execute o arquivo: `supabase/migrations/20251212190000_auto_unlock_modules_on_diamond.sql`

### 2. Execute o Script de Teste

1. No **Supabase Dashboard** > **SQL Editor**
2. Abra o arquivo: `TESTE-LIBERAR-MODULOS-DIAMOND.sql`
3. Execute o script completo
4. Verifique os logs no console

### 3. O que o Teste Faz

O script de teste verifica:

✅ **1. Verificação de Função**
   - Confirma se a função `auto_unlock_modules_on_diamond()` existe

✅ **2. Verificação de Trigger**
   - Confirma se o trigger `trigger_auto_unlock_modules_on_diamond` existe

✅ **3. Verificação de Módulos Bloqueados**
   - Conta quantos módulos estão bloqueados no sistema
   - Se não houver, cria um módulo de teste

✅ **4. Preparação do Usuário de Teste**
   - Seleciona um usuário que não é Diamond
   - Salva o plano atual para restaurar depois

✅ **5. Limpeza Pré-Teste**
   - Remove desbloqueios anteriores do usuário de teste
   - Garante um estado limpo para o teste

✅ **6. Simulação de Assinatura Diamond**
   - Atualiza o plano do usuário para `'diamond'`
   - Isso aciona o trigger automaticamente

✅ **7. Validação**
   - Verifica se todos os módulos bloqueados foram desbloqueados
   - Compara o número esperado vs. obtido

✅ **8. Limpeza Pós-Teste**
   - Restaura o plano original do usuário
   - Remove módulos de teste criados

### 4. Resultado Esperado

Se tudo estiver funcionando, você verá:

```
✅ TESTE PASSOU COM SUCESSO!
✅ A liberação automática está funcionando corretamente.
```

E nos logs:

```
✅ Liberação automática concluída para usuário [ID]: X novos módulos desbloqueados (total: Y de Z bloqueados)
```

### 5. Se o Teste Falhar

Se o teste falhar, verifique:

1. **Migration não executada?**
   - Execute a migration primeiro
   - Verifique se não há erros no SQL Editor

2. **Função não encontrada?**
   - Execute a migration novamente
   - Verifique os logs de erro

3. **Trigger não encontrado?**
   - Execute a migration novamente
   - Verifique se o trigger foi criado

4. **Módulos não foram desbloqueados?**
   - Verifique se há módulos com `is_locked = true`
   - Verifique as políticas RLS da tabela `unlocked_modules`
   - Verifique os logs de erro no console

### 6. Teste Manual Rápido

Se quiser testar manualmente sem o script completo:

```sql
-- 1. Verificar módulos bloqueados
SELECT id, title, is_locked 
FROM public.modules 
WHERE is_locked = true;

-- 2. Pegar um usuário de teste (substitua pelo ID real)
SELECT user_id, subscription_plan 
FROM public.profiles 
WHERE subscription_plan != 'diamond' 
LIMIT 1;

-- 3. Limpar desbloqueios anteriores
DELETE FROM public.unlocked_modules 
WHERE user_id = 'SEU_USER_ID_AQUI';

-- 4. Atualizar para Diamond (isso aciona o trigger)
UPDATE public.profiles 
SET subscription_plan = 'diamond' 
WHERE user_id = 'SEU_USER_ID_AQUI';

-- 5. Verificar se foram desbloqueados
SELECT 
  m.title,
  um.user_id,
  um.created_at
FROM public.unlocked_modules um
INNER JOIN public.modules m ON m.id = um.module_id
WHERE um.user_id = 'SEU_USER_ID_AQUI'
  AND m.is_locked = true;

-- 6. Restaurar plano original (se necessário)
UPDATE public.profiles 
SET subscription_plan = 'free'  -- ou o plano original
WHERE user_id = 'SEU_USER_ID_AQUI';
```

### 7. Verificação em Produção

Após executar a migration em produção:

1. **Monitore os logs** quando alguém assinar Diamond
2. **Verifique a tabela** `unlocked_modules` após uma assinatura
3. **Teste com um usuário real** (e restaure o plano depois)

## ⚠️ Importante

- O teste **não afeta** usuários reais se você restaurar o plano depois
- O script cria um módulo de teste temporário e o remove ao final
- Sempre restaure o plano original do usuário após o teste

