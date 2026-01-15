# 🔄 Como Aplicar as Mudanças do Header

## ⚠️ IMPORTANTE: As mudanças precisam ser aplicadas!

Se você ainda está vendo "NutraHub" ou "Nutra Elite", siga estes passos:

---

## 📋 Passo a Passo

### 1. Fazer Build do Projeto

```bash
npm run build
```

Isso vai compilar todas as mudanças.

---

### 2. Fazer Deploy no Vercel

1. As mudanças já foram enviadas para o GitHub
2. O Vercel deve fazer deploy automaticamente
3. Ou faça deploy manual:
   ```bash
   vercel --prod
   ```

---

### 3. Limpar Cache do Navegador

**No Desktop (Chrome/Firefox):**
- Pressione `Ctrl + Shift + R` (Windows) ou `Cmd + Shift + R` (Mac)
- Ou vá em DevTools (F12) → Network → Marque "Disable cache" → Recarregue

**No Mobile (iPhone):**
1. Vá em **Configurações** → **Safari**
2. Toque em **Limpar Histórico e Dados do Site**
3. Confirme

**No Mobile (Android):**
1. Abra **Chrome**
2. Vá em **Configurações** → **Privacidade e segurança**
3. Toque em **Limpar dados de navegação**
4. Marque **Imagens e arquivos em cache**
5. Toque em **Limpar dados**

---

### 4. Se Estiver Usando PWA Instalado

**Desinstalar e Reinstalar:**

**iPhone:**
1. Toque e segure o ícone do app
2. Toque em **Remover App**
3. Acesse o site novamente
4. Toque em **Compartilhar** → **Adicionar à Tela de Início**

**Android:**
1. Toque e segure o ícone do app
2. Arraste para **Desinstalar**
3. Acesse o site novamente
4. Use o prompt de instalação ou Menu → **Adicionar à tela inicial**

---

## ✅ Verificar se Funcionou

Depois de limpar o cache e fazer deploy, você deve ver:

- **Navbar (topo):** "Sociedade Nutra"
- **Header do Feed:** "Sociedade Nutra" (não "NutraHub")
- **Subtítulo:** "Comunidade • X publicações"

---

## 🐛 Se Ainda Não Funcionar

1. **Verifique o console do navegador:**
   - Pressione F12
   - Vá na aba "Console"
   - Procure por erros em vermelho

2. **Verifique se o deploy foi feito:**
   - Acesse o Vercel Dashboard
   - Veja se há um deploy recente
   - Verifique se o build foi bem-sucedido

3. **Teste em modo anônimo:**
   - Abra uma janela anônima/privada
   - Acesse o site
   - Veja se as mudanças aparecem

---

## 📝 Checklist

- [ ] Build feito (`npm run build`)
- [ ] Deploy feito no Vercel
- [ ] Cache do navegador limpo
- [ ] PWA desinstalado e reinstalado (se aplicável)
- [ ] Testado em modo anônimo
- [ ] Verificado console para erros

---

**💡 Dica:** Se você está testando localmente, execute:
```bash
npm run dev
```

E acesse `http://localhost:8080` para ver as mudanças imediatamente.

