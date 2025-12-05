# 🔄 Forçar Atualização do PWA - Passo a Passo

## ⚠️ Se as mudanças não aparecem, siga ESTES passos:

---

## 1️⃣ Desinstalar o PWA Completamente

### iPhone/iPad:
1. Toque e segure o ícone do app
2. Toque em **"Remover App"**
3. Toque em **"Remover"** para confirmar
4. Vá em **Configurações** → **Safari** → **Limpar Histórico e Dados do Site**

### Android:
1. Toque e segure o ícone do app
2. Arraste para **"Desinstalar"**
3. Abra **Chrome** → **Configurações** → **Privacidade e segurança**
4. Toque em **"Limpar dados de navegação"**
5. Marque **"Imagens e arquivos em cache"**
6. Toque em **"Limpar dados"**

---

## 2️⃣ Limpar Service Worker (Desktop)

1. Abra o site no navegador
2. Pressione **F12** (DevTools)
3. Vá em **Application** → **Service Workers**
4. Se houver um service worker registrado:
   - Clique em **"Unregister"**
   - Clique em **"Clear storage"** → **"Clear site data"**
5. Feche o DevTools
6. Pressione **Ctrl + Shift + R** (ou **Cmd + Shift + R** no Mac) para recarregar

---

## 3️⃣ Verificar se o Deploy Foi Feito

1. Acesse o **Vercel Dashboard**
2. Verifique se há um **deploy recente** (últimos minutos)
3. Verifique se o deploy foi **bem-sucedido** (status verde)
4. Se não houver deploy recente:
   - Faça push novamente: `git push origin main`
   - Ou faça deploy manual: `vercel --prod`

---

## 4️⃣ Testar em Modo Anônimo

1. Abra uma **janela anônima/privada**:
   - Chrome: `Ctrl + Shift + N` (Windows) ou `Cmd + Shift + N` (Mac)
   - Firefox: `Ctrl + Shift + P` (Windows) ou `Cmd + Shift + P` (Mac)
   - Safari: `Cmd + Shift + N`
2. Acesse o site
3. Veja se as mudanças aparecem

Se aparecer em modo anônimo, o problema é cache do navegador.

---

## 5️⃣ Verificar o Código no Servidor

1. Acesse: `https://seuapp.vercel.app/`
2. Pressione **F12** → **Network**
3. Recarregue a página
4. Procure por `index.html` ou `index-*.js`
5. Clique nele → **Preview** ou **Response**
6. Procure por "Sociedade Nutra" no código
7. Se ainda aparecer "NutraHub" ou "Nutra Elite", o deploy não foi feito corretamente

---

## 6️⃣ Forçar Atualização do Service Worker

Execute este código no console do navegador (F12 → Console):

```javascript
// Desregistrar service worker
navigator.serviceWorker.getRegistrations().then(function(registrations) {
  for(let registration of registrations) {
    registration.unregister();
  }
});

// Limpar todos os caches
caches.keys().then(function(names) {
  for (let name of names) {
    caches.delete(name);
  }
});

// Recarregar a página
location.reload(true);
```

---

## 7️⃣ Verificar Arquivos no Build

Execute localmente:

```bash
npm run build
```

Depois verifique:

```bash
# Verificar se sw.js está no dist
ls -la dist/sw.js

# Verificar conteúdo do index.html
grep -i "Sociedade Nutra" dist/index.html

# Verificar arquivos JS compilados
grep -r "Sociedade Nutra" dist/assets/ | head -5
```

---

## ✅ Checklist Final

- [ ] PWA desinstalado completamente
- [ ] Cache do navegador limpo
- [ ] Service Worker desregistrado
- [ ] Deploy feito no Vercel (verificado)
- [ ] Testado em modo anônimo
- [ ] Código verificado no servidor
- [ ] Build local verificado

---

## 🐛 Se Ainda Não Funcionar

Me envie:
1. Screenshot do que você está vendo
2. URL do site
3. Resultado do comando: `grep -r "NutraHub\|Nutra Elite" dist/` (após build)
4. Logs do console do navegador (F12 → Console)

---

**💡 Dica:** A versão do cache do Service Worker foi atualizada para `v2`. Isso deve forçar uma atualização automática quando você acessar o site novamente.

