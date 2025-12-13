# 🔧 INSTRUÇÕES PARA RESOLVER USUÁRIOS SEM PERFIL

## 📋 Problema Identificado

Muitos usuários foram criados ontem, mas não aparecem na tabela `profiles`. Isso pode acontecer por:

1. **Trigger não está funcionando** - O trigger `on_auth_user_created` pode não estar ativo
2. **Função falhando silenciosamente** - A função `handle_new_user()` pode estar falhando sem mostrar erro
3. **Problema de RLS** - Row Level Security pode estar bloqueando a inserção
4. **Coluna faltando** - A coluna `email` pode não existir na tabela `profiles`

## 🚀 SOLUÇÃO PASSO A PASSO

### **PASSO 1: Executar Diagnóstico**

1. Abra o **Supabase SQL Editor**
2. Execute o arquivo: `DIAGNOSTICO-COMPLETO-USUARIOS.sql`
3. Analise os resultados:
   - Verifique se o trigger existe
   - Veja quantos usuários estão sem perfil
   - Confira se há usuários criados ontem sem perfil

### **PASSO 2: Corrigir a Função e Trigger**

1. Execute o arquivo: `CORRIGIR-FUNCAO-HANDLE-NEW-USER.sql`
2. Este script:
   - ✅ Adiciona a coluna `email` se não existir
   - ✅ Recria a função `handle_new_user()` com tratamento de erros
   - ✅ Recria o trigger `on_auth_user_created`
   - ✅ Verifica se tudo está funcionando

### **PASSO 3: Criar Perfis Faltantes**

1. Execute o arquivo: `CRIAR-PERFIS-FALTANTES-FORCA-TOTAL.sql`
2. Este script:
   - ✅ Identifica TODOS os usuários sem perfil
   - ✅ Cria perfis para cada um deles
   - ✅ Migra dados de `auth.users` para `profiles`
   - ✅ Mostra quantos perfis foram criados
   - ✅ Lista usuários que ainda estão sem perfil (se houver)

### **PASSO 4: Verificar Resultado**

Execute novamente o diagnóstico para confirmar que todos os usuários agora têm perfil:

```sql
SELECT 
  (SELECT COUNT(*) FROM auth.users) as total_usuarios_auth,
  (SELECT COUNT(*) FROM public.profiles) as total_perfis,
  (SELECT COUNT(*) FROM auth.users) - (SELECT COUNT(*) FROM public.profiles) as diferenca;
```

A `diferenca` deve ser **0**.

## 📊 Scripts Disponíveis

| Arquivo | Descrição |
|---------|-----------|
| `DIAGNOSTICO-COMPLETO-USUARIOS.sql` | Análise completa do problema |
| `CORRIGIR-FUNCAO-HANDLE-NEW-USER.sql` | Corrige função e trigger |
| `CRIAR-PERFIS-FALTANTES-FORCA-TOTAL.sql` | Cria perfis para todos os faltantes |
| `VERIFICAR-USUARIOS-SEM-PERFIL.sql` | Lista usuários sem perfil |
| `CRIAR-PERFIS-FALTANTES.sql` | Versão simples para criar perfis |

## ⚠️ IMPORTANTE

- Execute os scripts **na ordem** apresentada acima
- Após executar, **verifique** se todos os usuários têm perfil
- Se ainda houver problemas, execute o diagnóstico novamente
- Os scripts são **seguros** e usam `ON CONFLICT DO NOTHING` para evitar duplicatas

## 🔍 Verificação Contínua

Para verificar se novos usuários estão sendo criados corretamente:

```sql
-- Verificar usuários criados nas últimas 24h
SELECT 
  COUNT(*) as usuarios_criados,
  COUNT(p.user_id) as perfis_criados,
  COUNT(*) - COUNT(p.user_id) as faltantes
FROM auth.users u
LEFT JOIN public.profiles p ON p.user_id = u.id
WHERE u.created_at >= NOW() - INTERVAL '24 hours';
```

Se `faltantes` for maior que 0, há um problema com o trigger.

