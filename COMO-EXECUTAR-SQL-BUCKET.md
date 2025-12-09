# 🚀 EXECUTAR SQL PARA CRIAR BUCKET

## 📋 PASSO A PASSO RÁPIDO:

### 1️⃣ Abra o arquivo SQL
- Arquivo: `EXECUTAR-ESTE-SQL-BUCKET.sql`
- Você já está com ele aberto! ✅

### 2️⃣ Copie TODO o conteúdo
- Selecione tudo: **Ctrl+A** (ou Cmd+A no Mac)
- Copie: **Ctrl+C** (ou Cmd+C no Mac)

### 3️⃣ Vá no Supabase
- Acesse: https://supabase.com/dashboard
- Entre no seu projeto
- Clique em **"SQL Editor"** (menu lateral esquerdo)

### 4️⃣ Cole e execute
- Cole o conteúdo: **Ctrl+V** (ou Cmd+V no Mac)
- Clique no botão **"RUN"** (ou pressione Ctrl+Enter)

### 5️⃣ Verifique o resultado
- Deve aparecer: `✅ SUCESSO! Bucket criado!`
- Com os dados: `id: images`, `name: images`, `public: true`

### 6️⃣ Teste no app
- Aguarde 5 segundos
- Recarregue o app: **F5** (ou Cmd+R no Mac)
- Tente enviar um áudio novamente

---

## ✅ RESULTADO ESPERADO:

Após executar o SQL, você verá algo assim:

```
✅ SUCESSO! Bucket criado!
id: images
name: images
public: true
```

---

## ❌ SE APARECER ERRO:

**Erro:** `syntax error` ou `permission denied`

**Solução:** 
- Verifique se copiou TODO o conteúdo do arquivo SQL
- Certifique-se de que está logado no Supabase
- Tente executar novamente

---

## 🔍 VERIFICAR SE O BUCKET FOI CRIADO:

Execute este SQL no Supabase SQL Editor:
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'images';
```

**Se aparecer resultado:** ✅ Bucket criado!
**Se não aparecer nada:** ❌ Bucket não existe (execute o SQL novamente)

