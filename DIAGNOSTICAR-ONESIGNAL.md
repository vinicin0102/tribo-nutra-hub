# 🔍 Diagnosticar Problemas com OneSignal

## 📋 Checklist de Diagnóstico

### 1. Verificar Console do Navegador (F12)

Abra o Console (F12 → Console) e procure por logs que começam com `[OneSignal]`:

**Logs esperados:**
```
[OneSignal] ========== INICIANDO CHECK ==========
[OneSignal] Window disponível? true
[OneSignal] OneSignal disponível? false (inicialmente)
[OneSignal] App ID: e1e6712a-5457-4991-a922-f22b1f151c25
[OneSignal] Script não carregado ainda, carregando...
[OneSignal] Script adicionado ao head
[OneSignal] ✅ Script carregado com sucesso
[OneSignal] ========== INICIALIZANDO ==========
[OneSignal] ✅ Inicializado com sucesso
[OneSignal] Push notifications habilitadas? false
```

**Se não aparecer nenhum log:**
- O componente `NotificationToggle` não está sendo renderizado
- Verifique se está na página de Perfil

**Se aparecer erro:**
- Copie o erro completo e me envie

---

### 2. Verificar se o Script Está Carregando

No Console, execute:
```javascript
// Verificar se o script foi adicionado
document.querySelector('script[src*="OneSignal"]')

// Verificar se OneSignal está disponível
window.OneSignal

// Verificar App ID
import.meta.env.VITE_ONESIGNAL_APP_ID
```

**Se `window.OneSignal` for `undefined`:**
- O script não carregou
- Verifique se há bloqueadores de anúncio
- Verifique a conexão com a internet

---

### 3. Verificar Variáveis de Ambiente

No Console, execute:
```javascript
console.log('VITE_ONESIGNAL_APP_ID:', import.meta.env.VITE_ONESIGNAL_APP_ID);
```

**Se for `undefined`:**
- A variável não está configurada
- Verifique o arquivo `.env`
- Faça rebuild: `npm run build`

---

### 4. Verificar Network Tab

1. Abra o DevTools (F12)
2. Vá em **Network**
3. Recarregue a página
4. Procure por: `OneSignalSDK.page.js`
5. Verifique se o status é `200` (sucesso)

**Se der erro 404 ou outro:**
- Problema de conexão
- CDN do OneSignal pode estar bloqueado

---

### 5. Verificar se o Componente Está Sendo Renderizado

No Console, execute:
```javascript
// Verificar se o componente existe
document.querySelector('[class*="NotificationToggle"]')
```

**Se não encontrar:**
- O componente não está sendo renderizado
- Verifique se está na página `/profile`

---

### 6. Testar Inicialização Manual

No Console, execute:
```javascript
// Aguardar script carregar
await new Promise(resolve => {
  if (window.OneSignal) {
    resolve(true);
  } else {
    const script = document.createElement('script');
    script.src = 'https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js';
    script.onload = () => resolve(true);
    document.head.appendChild(script);
  }
});

// Inicializar
await window.OneSignal.init({
  appId: 'e1e6712a-5457-4991-a922-f22b1f151c25',
  allowLocalhostAsSecureOrigin: true
});

// Verificar status
await window.OneSignal.isPushNotificationsEnabled();
```

**Se funcionar manualmente:**
- O problema é no hook ou no componente
- Verifique os logs do hook

---

## 🆘 Problemas Comuns e Soluções

### Problema: "OneSignal não está disponível"

**Possíveis causas:**
1. Script não carregou
2. Bloqueador de anúncio bloqueando o script
3. Problema de conexão

**Solução:**
- Desabilite bloqueadores de anúncio
- Verifique a conexão
- Tente em outro navegador

---

### Problema: "App ID não encontrado"

**Causa:**
- Variável `VITE_ONESIGNAL_APP_ID` não configurada

**Solução:**
1. Crie/atualize `.env`:
   ```env
   VITE_ONESIGNAL_APP_ID=e1e6712a-5457-4991-a922-f22b1f151c25
   ```
2. Faça rebuild: `npm run build`
3. Reinicie o servidor: `npm run dev`

---

### Problema: Script carrega mas não inicializa

**Causa:**
- Erro na inicialização do OneSignal
- App ID inválido

**Solução:**
- Verifique os logs no Console
- Verifique se o App ID está correto
- Verifique se o domínio está autorizado no OneSignal Dashboard

---

### Problema: Botão não funciona

**Causa:**
- Hook não está retornando as funções corretamente
- Estado não está atualizando

**Solução:**
- Verifique os logs do hook
- Verifique se `isInitialized` é `true`
- Verifique se `isSupported` é `true`

---

## 📊 Informações para Enviar

Se ainda não funcionar, me envie:

1. **Logs do Console** (todos os logs que começam com `[OneSignal]`)
2. **Erros do Console** (qualquer erro em vermelho)
3. **Resultado do teste manual** (passo 6 acima)
4. **Screenshot** da página de Perfil
5. **Navegador e versão** (ex: Chrome 120, Safari 17)

---

## ✅ Teste Rápido

Execute no Console:
```javascript
// Teste completo
(async () => {
  console.log('1. Verificando script...');
  if (!window.OneSignal) {
    console.log('   Carregando script...');
    await new Promise((resolve) => {
      const s = document.createElement('script');
      s.src = 'https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.page.js';
      s.onload = resolve;
      document.head.appendChild(s);
    });
  }
  
  console.log('2. Inicializando...');
  await window.OneSignal.init({
    appId: 'e1e6712a-5457-4991-a922-f22b1f151c25',
    allowLocalhostAsSecureOrigin: true
  });
  
  console.log('3. Verificando status...');
  const enabled = await window.OneSignal.isPushNotificationsEnabled();
  console.log('   Habilitado?', enabled);
  
  console.log('4. Obtendo User ID...');
  const userId = await window.OneSignal.getUserId();
  console.log('   User ID:', userId);
  
  console.log('✅ Teste completo!');
})();
```

**Se este teste funcionar, o problema é no hook ou componente.**

