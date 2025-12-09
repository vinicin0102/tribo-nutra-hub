# 📋 INSTRUÇÕES SIMPLES - CRIAR BUCKET

## 🎯 O QUE FAZER:

1. **Abra o arquivo:** `criar-bucket-images-simples.sql`
2. **Selecione TODO o texto** (Ctrl+A ou Cmd+A)
3. **Copie** (Ctrl+C ou Cmd+C)
4. **Vá no Supabase:** https://supabase.com/dashboard
5. **Clique em "SQL Editor"** (menu lateral esquerdo)
6. **Cole o conteúdo** (Ctrl+V ou Cmd+V)
7. **Clique em "RUN"** (ou pressione Ctrl+Enter)
8. **Aguarde o resultado** (deve aparecer "✅ Bucket criado!")
9. **Recarregue o app** (F5 ou Cmd+R)
10. **Teste enviar um áudio**

---

## ✅ RESULTADO ESPERADO:

Após executar, você verá:
```
✅ Bucket criado!
id: images
name: images
public: true
```

---

## ❌ SE APARECER ERRO:

**Erro:** `syntax error at or near "{"` ou `import {`

**Causa:** Você executou um arquivo TypeScript (`.tsx`) em vez do SQL (`.sql`)

**Solução:** Execute o arquivo `criar-bucket-images-simples.sql` (não o `.tsx`)

---

## 🔍 COMO SABER SE É O ARQUIVO CORRETO:

**✅ CORRETO:**
- Nome termina com `.sql`
- Primeira linha: `-- ============================================`

**❌ ERRADO:**
- Nome termina com `.tsx` ou `.ts`
- Primeira linha: `import {` ou `export`

---

## 📞 PRECISA DE AJUDA?

Se ainda não funcionar, envie:
1. Captura de tela do resultado do SQL
2. O erro exato que aparece

