# ✅ Execute Este SQL para Liberar Plano Imediatamente

## 🎯 Problema:

O plano não está sendo liberado imediatamente porque a RLS policy não permite que o usuário atualize seu próprio `subscription_plan`.

---

## ✅ SOLUÇÃO:

Execute este SQL no Supabase SQL Editor:

### Arquivo: `permitir-usuario-atualizar-proprio-plano.sql`

Este SQL cria uma policy que permite que o usuário atualize seu próprio plano.

---

## 🚀 PASSO A PASSO:

1. **Abra o Supabase Dashboard:**
   - https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em **"SQL Editor"**

2. **Abra o arquivo:** `permitir-usuario-atualizar-proprio-plano.sql`

3. **Copie TODO o conteúdo** (Ctrl+A, Ctrl+C)

4. **Cole no SQL Editor** (Ctrl+V)

5. **Execute** (RUN ou Ctrl+Enter)

6. **Verifique:**
   - Deve aparecer: **"✅ Policy criada!"**
   - Deve mostrar `policyname = 'Users can update own subscription plan'`

---

## ✅ VERIFICAÇÃO:

Execute este SQL para confirmar:

```sql
SELECT 
  policyname,
  cmd
FROM pg_policies 
WHERE tablename = 'profiles' 
AND cmd = 'UPDATE'
AND policyname = 'Users can update own subscription plan';
```

**Deve retornar uma linha.**

---

## 🔄 DEPOIS DE EXECUTAR:

1. **Aguarde 1-2 minutos** para o deploy do código
2. **Limpe o cache:** Ctrl+Shift+R (ou Cmd+Shift+R)
3. **Teste fazendo um pagamento**
4. **O plano deve ser liberado imediatamente!**

---

## 🎯 COMO FUNCIONA:

### Antes (bloqueado):
- ❌ Usuário tenta atualizar seu próprio plano
- ❌ RLS policy bloqueia (não há policy específica)
- ❌ Precisa esperar webhook

### Depois (liberado):
- ✅ Usuário pode atualizar seu próprio `subscription_plan`
- ✅ Policy permite: `auth.uid() = user_id`
- ✅ Plano liberado imediatamente após pagamento

---

## ⚠️ SE AINDA NÃO FUNCIONAR:

### Verifique o Console (F12):
Procure por:
- **"💎 Atualizando plano para Diamond imediatamente..."**
- **"❌ Erro ao atualizar plano"**
- Veja o código do erro (ex: 42501 = permissão negada)

### Se o erro for 42501:
Execute o SQL `permitir-usuario-atualizar-proprio-plano.sql`

### Se não houver erro mas não atualizar:
Verifique se a policy foi criada corretamente com o SQL de verificação acima.

---

**🚀 Execute o SQL `permitir-usuario-atualizar-proprio-plano.sql` e teste novamente!**

