# 💎 Liberação da Mentoria Avançada para Usuários Diamond

## 📋 Como Funciona

### 1. Liberação Automática para Novos Assinantes

Quando um usuário assina o plano Diamond, **todos os módulos bloqueados são desbloqueados automaticamente**, incluindo a mentoria avançada.

**Função:** `auto_unlock_modules_on_diamond()`
- **Trigger:** `trigger_auto_unlock_modules_on_diamond`
- **Quando executa:** Automaticamente quando `subscription_plan` muda para `'diamond'`
- **O que faz:** Desbloqueia todos os módulos com `is_locked = true`

### 2. Liberação para Usuários Diamond Existentes

Se você já tem usuários Diamond antes da implementação do sistema automático, execute o script de migração:

**Migration:** `20251212201000_liberar_mentoria_para_diamond_existentes.sql`
- **O que faz:** Desbloqueia todos os módulos bloqueados para usuários que já são Diamond
- **Quando executar:** Uma vez, após implementar o sistema

## 🚀 Como Aplicar

### Passo 1: Executar Migration Principal

```sql
-- Execute no Supabase SQL Editor
-- Arquivo: supabase/migrations/20251212190000_auto_unlock_modules_on_diamond.sql
```

Esta migration cria a função e o trigger para liberação automática.

### Passo 2: Executar Migration para Usuários Existentes

```sql
-- Execute no Supabase SQL Editor
-- Arquivo: supabase/migrations/20251212201000_liberar_mentoria_para_diamond_existentes.sql
```

Esta migration libera a mentoria para usuários Diamond que já existem no sistema.

## ✅ Verificação

### Verificar se a Mentoria está Bloqueada

```sql
-- Ver módulos bloqueados
SELECT id, title, is_locked 
FROM public.modules 
WHERE is_locked = true;
```

### Verificar Acesso dos Usuários Diamond

```sql
-- Ver usuários Diamond e seus módulos desbloqueados
SELECT 
  p.user_id,
  p.username,
  p.subscription_plan,
  COUNT(um.module_id) as modulos_desbloqueados
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.subscription_plan;
```

### Verificar Módulos Desbloqueados de um Usuário Específico

```sql
-- Substitua USER_ID pelo ID do usuário
SELECT 
  m.title,
  m.is_locked,
  um.created_at as desbloqueado_em
FROM public.unlocked_modules um
INNER JOIN public.modules m ON m.id = um.module_id
WHERE um.user_id = 'USER_ID';
```

## 📝 Importante

1. **Mentoria = Módulo Bloqueado**: A mentoria avançada é um módulo que deve ter `is_locked = true` no banco de dados.

2. **Liberação Automática**: Após executar as migrations, novos assinantes Diamond receberão acesso automaticamente.

3. **Usuários Existentes**: Execute a segunda migration para garantir que usuários Diamond existentes também tenham acesso.

4. **Verificação no Frontend**: O frontend verifica se o módulo está desbloqueado através da tabela `unlocked_modules` e se o usuário tem acesso Diamond.

## 🔄 Fluxo Completo

```
1. Usuário assina Diamond
   ↓
2. Trigger detecta mudança de plano
   ↓
3. Função desbloqueia todos os módulos bloqueados
   ↓
4. Módulos são inseridos em unlocked_modules
   ↓
5. Frontend verifica unlocked_modules
   ↓
6. Usuário tem acesso à mentoria avançada ✅
```

## ⚠️ Troubleshooting

Se a mentoria não estiver sendo liberada:

1. **Verifique se o módulo está marcado como bloqueado:**
   ```sql
   UPDATE public.modules 
   SET is_locked = true 
   WHERE title ILIKE '%mentoria%';
   ```

2. **Verifique se o trigger está ativo:**
   ```sql
   SELECT trigger_name 
   FROM information_schema.triggers 
   WHERE trigger_name = 'trigger_auto_unlock_modules_on_diamond';
   ```

3. **Execute manualmente para um usuário:**
   ```sql
   -- Substitua USER_ID pelo ID do usuário Diamond
   INSERT INTO public.unlocked_modules (user_id, module_id)
   SELECT 'USER_ID', id 
   FROM public.modules 
   WHERE is_locked = true
   ON CONFLICT (user_id, module_id) DO NOTHING;
   ```

