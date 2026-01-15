# ⚠️ ATENÇÃO: QUAL ARQUIVO EXECUTAR?

## ❌ NÃO EXECUTE ESTES ARQUIVOS NO SQL EDITOR:
- `src/pages/Support.tsx` ❌
- `src/pages/Chat.tsx` ❌
- Qualquer arquivo `.tsx` ❌
- Qualquer arquivo `.ts` ❌
- Qualquer arquivo `.js` ❌
- Qualquer arquivo `.md` ❌

## ✅ EXECUTE APENAS ESTE ARQUIVO:
- `criar-bucket-images-simples.sql` ✅

---

## 🔍 COMO IDENTIFICAR O ARQUIVO CORRETO:

### ✅ ARQUIVO SQL (CORRETO):
```
Nome: criar-bucket-images-simples.sql
Primeira linha: -- ============================================
```

### ❌ ARQUIVO TYPESCRIPT (ERRADO):
```
Nome: Support.tsx ou Chat.tsx
Primeira linha: import { useState, useEffect, useRef } from 'react';
```

---

## 📋 PASSO A PASSO:

1. **No seu computador**, abra o arquivo: `criar-bucket-images-simples.sql`
2. **Copie TODO o conteúdo** (deve começar com `--`)
3. **No Supabase**, vá em **SQL Editor**
4. **Cole o conteúdo**
5. **Clique em RUN**

---

## ✅ RESULTADO ESPERADO:

Após executar, você deve ver:
```
✅ Bucket criado!
id: images
name: images
public: true
```

---

## ❌ SE VOCÊ VER ESTE ERRO:

```
ERROR: 42601: syntax error at or near "{"
LINE 1: import { useState, useEffect, useRef } from 'react';
```

**Significa que você executou o arquivo ERRADO!**

**Solução:** Execute o arquivo `criar-bucket-images-simples.sql` (não o `.tsx`)



