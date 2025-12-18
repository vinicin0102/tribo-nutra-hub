# 📋 Como Executar o Teste no Console

## Passo a Passo Completo

### 1. Abra o App no Navegador

1. Abra o app (onde você testa normalmente)
2. Faça login se necessário

### 2. Abra o Console do Navegador

**Opção A - Tecla de Atalho:**
- Pressione **F12** no teclado
- Ou **Ctrl+Shift+I** (Windows/Linux)
- Ou **Cmd+Option+I** (Mac)

**Opção B - Menu:**
- Clique com botão direito em qualquer lugar da página
- Clique em **"Inspecionar"** ou **"Inspect"**
- Vá na aba **"Console"** (geralmente já abre nela)

### 3. Localize a Área de Código

No console, você verá:
- Uma área em branco na parte inferior (onde você digita)
- Ou um prompt `>` onde você pode digitar código

### 4. Cole o Código de Teste

**Copie este código completo:**

```javascript
(async () => {
  const reg = await navigator.serviceWorker.ready;
  const key = 'BGlpREcbTdz2SRMHeOGGCBCeRGwqx6i9LpcSXg6dD1_yPkLSCNV6TDWtlHNGYPHe6mqKoiW5TVPtBi2lCY3w7xY';
  const padding = '='.repeat((4 - (key.length % 4)) % 4);
  const base64 = (key + padding).replace(/-/g, '+').replace(/_/g, '/');
  const raw = window.atob(base64);
  const arr = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) arr[i] = raw.charCodeAt(i);
  console.log('Chave:', arr.length, 'bytes, primeiro:', arr[0]);
  try {
    const sub = await reg.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: arr
    });
    console.log('✅ FUNCIONOU!', sub.endpoint);
  } catch (e) {
    console.error('❌ ERRO:', e.message);
  }
})();
```

**Como colar:**
1. Selecione todo o código acima (do `(async` até o `})();`)
2. Pressione **Ctrl+C** (ou Cmd+C no Mac) para copiar
3. Clique na área do console
4. Pressione **Ctrl+V** (ou Cmd+V no Mac) para colar

### 5. Execute o Código

**Pressione Enter** no teclado

### 6. Veja os Resultados

Você verá uma das seguintes mensagens:

**Se funcionar:**
```
Chave: 65 bytes, primeiro: 4
✅ FUNCIONOU! https://fcm.googleapis.com/...
```

**Se não funcionar:**
```
Chave: 65 bytes, primeiro: 4
❌ ERRO: applicationServerKey must contain a valid P-256 public key
```

## 📸 Screenshot do Console

O console deve parecer assim:

```
> (async () => {
    const reg = await navigator.serviceWorker.ready;
    ...
  })();
  
Chave: 65 bytes, primeiro: 4
✅ FUNCIONOU! https://fcm.googleapis.com/...
```

## ⚠️ Problemas Comuns

### "navigator.serviceWorker is not defined"
- O Service Worker não está registrado
- Recarregue a página e tente novamente

### "Cannot read property 'ready' of undefined"
- O navegador não suporta Service Workers
- Use Chrome, Firefox ou Edge

### "Permission denied"
- A permissão de notificações foi negada
- Vá em Configurações do Site e permita notificações

## 📋 O Que Fazer com os Resultados

**Me envie:**
1. ✅ Se apareceu "FUNCIONOU!" - O problema está no código do app
2. ❌ Se apareceu "ERRO:" - Copie a mensagem de erro completa
3. 📸 Se possível, envie um screenshot do console

## 🎯 Próximos Passos

**Se funcionou no console:**
- O problema está no código do app
- Vou corrigir o código baseado nisso

**Se não funcionou no console:**
- O problema é mais fundamental
- Pode ser navegador, Service Worker, ou permissões
- Vou investigar mais a fundo

