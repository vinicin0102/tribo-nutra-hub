# ✅ EXECUTE ESTE SQL - VERSÃO SIMPLES QUE FUNCIONA

## 🎯 SOLUÇÃO DEFINITIVA:

Removi a dependência de funções RPC. Agora usamos **UPDATE direto** com uma **RLS policy** simples.

---

## 📋 EXECUTE ESTE SQL:

### Arquivo: `SOLUCAO-SIMPLES-ALTERAR-PLANO.sql`

**Este SQL é diferente dos anteriores:**
- ✅ **NÃO cria função RPC** (que estava dando problema)
- ✅ **Cria apenas uma RLS policy** que permite admins atualizarem planos
- ✅ **Muito mais simples** e confiável

---

## 🚀 PASSO A PASSO:

1. **Abra o Supabase Dashboard:**
   - https://supabase.com/dashboard
   - Selecione seu projeto
   - Clique em **"SQL Editor"**

2. **Abra o arquivo:** `SOLUCAO-SIMPLES-ALTERAR-PLANO.sql`

3. **Copie TODO o conteúdo** (Ctrl+A, Ctrl+C)

4. **Cole no SQL Editor** (Ctrl+V)

5. **Execute** (RUN ou Ctrl+Enter)

6. **Verifique:**
   - Deve aparecer uma tabela mostrando a policy criada
   - Deve mostrar `policyname = 'Admins can update subscription plan'`

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
AND policyname = 'Admins can update subscription plan';
```

**Deve retornar uma linha.**

---

## 🔄 DEPOIS:

1. **Aguarde 1-2 minutos** para o deploy
2. **Limpe o cache:** Ctrl+Shift+R (ou Cmd+Shift+R)
3. **Faça logout e login novamente**
4. **Teste a alteração de plano**

---

## ⚠️ SE AINDA NÃO FUNCIONAR:

### Verifique o Console (F12):
Procure por:
- **"🔄 Atualizando plano diretamente na tabela profiles..."**
- **"❌ ERRO AO ATUALIZAR PLANO"**
- Veja o código do erro (ex: 42501 = permissão negada)

### Se o erro for 42501 (permissão):
Execute também `FIX-RLS-DEFINITIVO.sql` para garantir que todas as policies estão corretas.

---

## 🎯 POR QUE ESTA VERSÃO FUNCIONA:

1. ✅ **Não depende de funções RPC** (que estavam dando problema)
2. ✅ **Usa apenas RLS policy** (mais simples)
3. ✅ **UPDATE direto** (mais confiável)
4. ✅ **Código simplificado** (menos pontos de falha)

---

**🚀 Execute o SQL `SOLUCAO-SIMPLES-ALTERAR-PLANO.sql` e teste!**

