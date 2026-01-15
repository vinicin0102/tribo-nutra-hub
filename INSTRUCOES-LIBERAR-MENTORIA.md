# 🚀 INSTRUÇÕES: Liberar Mentoria para Usuários Diamond

## ⚠️ IMPORTANTE: Execute este script AGORA

Se você tem usuários Diamond que ainda não têm acesso à mentoria, execute o script abaixo:

## 📋 Passo a Passo

1. **Acesse o Supabase Dashboard**
   - Vá para: https://supabase.com/dashboard
   - Selecione seu projeto

2. **Abra o SQL Editor**
   - No menu lateral, clique em **SQL Editor**
   - Clique em **New query**

3. **Execute o Script**
   - Abra o arquivo: `LIBERAR-MENTORIA-DIAMOND-AGORA.sql`
   - Copie TODO o conteúdo do arquivo
   - Cole no SQL Editor do Supabase
   - Clique em **RUN** (ou pressione Ctrl+Enter)

4. **Verifique o Resultado**
   - O script vai mostrar quantos usuários foram processados
   - A query no final vai mostrar uma lista de todos os usuários Diamond e quantos módulos eles têm desbloqueados

## ✅ O que o script faz

- Busca TODOS os usuários com `subscription_plan = 'diamond'`
- Para cada usuário Diamond, desbloqueia TODOS os módulos bloqueados (`is_locked = true`)
- Isso inclui a mentoria avançada
- Usa `ON CONFLICT DO NOTHING` para não duplicar registros

## 🔍 Verificação Manual

Após executar, você pode verificar manualmente:

```sql
-- Ver quantos módulos bloqueados existem
SELECT COUNT(*) as total_modulos_bloqueados 
FROM public.modules 
WHERE is_locked = true;

-- Ver usuários Diamond e seus módulos desbloqueados
SELECT 
  p.username,
  p.full_name,
  COUNT(um.module_id) as modulos_desbloqueados
FROM public.profiles p
LEFT JOIN public.unlocked_modules um ON um.user_id = p.user_id
LEFT JOIN public.modules m ON m.id = um.module_id AND m.is_locked = true
WHERE p.subscription_plan = 'diamond'
GROUP BY p.user_id, p.username, p.full_name;
```

## ⚠️ Se ainda não funcionar

Se após executar o script ainda não funcionar:

1. Verifique se a mentoria está marcada como bloqueada:
   ```sql
   SELECT id, title, is_locked 
   FROM public.modules 
   WHERE title ILIKE '%mentoria%';
   ```

2. Se não estiver bloqueada, bloqueie:
   ```sql
   UPDATE public.modules 
   SET is_locked = true 
   WHERE title ILIKE '%mentoria%';
   ```

3. Execute o script de liberação novamente

## 📝 Nota

Este script é idempotente, ou seja, pode ser executado várias vezes sem problemas. Ele só adiciona novos desbloqueios, não remove os existentes.

