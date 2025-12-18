# 🔍 Como Verificar se a Chave VAPID Está Carregada

## ❌ ERRO COMUM

**NÃO execute `import.meta.env.VITE_VAPID_PUBLIC_KEY` no SQL Editor do Supabase!**

Isso é código **JavaScript**, não SQL. O SQL Editor é para comandos SQL apenas.

## ✅ FORMA CORRETA

### 1. Abra o Console do Navegador

1. Abra o app no navegador (não no Supabase)
2. Pressione **F12** (ou clique com botão direito → Inspecionar)
3. Vá na aba **Console**

### 2. Digite no Console do Navegador

```javascript
import.meta.env.VITE_VAPID_PUBLIC_KEY
```

**Ou:**

```javascript
console.log('Chave VAPID:', import.meta.env.VITE_VAPID_PUBLIC_KEY)
```

### 3. O que você deve ver

Se a chave estiver carregada:
```
"BGlpREcbTdz2SRMHeOGGCBCeRGwqx6i9LpcSXg6dD1_yPkLSCNV6TDWtlHNGYPHe6mqKoiW5TVPtBi2lCY3w7xY"
```

Se não estiver carregada:
```
undefined
```

## 🔧 Se Mostrar `undefined`

Isso significa que o servidor não foi reiniciado após atualizar o `.env`.

### Solução:

1. **Pare o servidor** (`npm run dev`) - pressione Ctrl+C
2. **Reinicie o servidor**:
   ```bash
   npm run dev
   ```
3. **Recarregue o app** no navegador (Ctrl+Shift+R)
4. **Teste novamente** no console

## 📋 Checklist Completo

- [ ] Servidor foi reiniciado após mudar `.env`
- [ ] App foi recarregado no navegador
- [ ] Console do navegador mostra a chave (não `undefined`)
- [ ] Service Worker está ativo (DevTools → Application → Service Workers)
- [ ] Tentou ativar notificações e viu os logs `[Push]` no console

## 🐛 Logs para Verificar

Quando tentar ativar notificações, no console você deve ver:

```
[Push] Verificando chave VAPID...
[Push] Chave existe? true
[Push] Tipo: string
[Push] Chave limpa, tamanho: 87 caracteres
[Push] Convertendo chave VAPID para Uint8Array...
[Push] Base64 decodificado, tamanho: 65 bytes
[Push] ✅ Chave convertida com sucesso!
[Push] Subscription criada com sucesso!
```

## 💡 Dica

Se ainda não funcionar, verifique também:

1. **Service Worker está registrado?**
   - DevTools → Application → Service Workers
   - Deve mostrar um Service Worker ativo

2. **Permissão de notificações foi concedida?**
   - DevTools → Application → Notifications
   - Verifique o status da permissão

3. **Navegador suporta push?**
   - Chrome ✅
   - Firefox ✅
   - Edge ✅
   - Safari ⚠️ (suporte limitado)

