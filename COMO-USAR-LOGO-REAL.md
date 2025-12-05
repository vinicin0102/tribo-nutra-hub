# 🎨 Como Usar a Imagem Real do Logo Nutra Club

## 📋 Opção 1: Usar PNG/JPG (Recomendado)

1. **Salve a imagem do logo** como `logo.png` ou `logo.jpg`
2. **Coloque em:** `public/logo.png` (ou `public/logo.jpg`)
3. **Execute:** `npm run generate-icons`

O script detectará automaticamente e usará a imagem!

---

## 📋 Opção 2: Converter para SVG

Se você tem a imagem em formato vetorial (AI, EPS, etc.):

1. Abra no Illustrator ou Inkscape
2. Exporte como SVG
3. Salve como `public/logo-nutra-club.svg`
4. Execute: `npm run generate-icons`

---

## 📋 Opção 3: Usar a Imagem Atual

Se você já tem a imagem salva em algum lugar:

1. **Copie a imagem** para `public/logo.png`
2. **Execute:** `npm run generate-icons`

---

## ✅ Ordem de Prioridade do Script

O script procura nesta ordem:
1. `public/logo-nutra-club.svg`
2. `public/logo.png`
3. `public/logo.svg`
4. `public/favicon.svg` (fallback)

---

## 🎯 Formato Recomendado

- **Tamanho mínimo:** 512x512 pixels
- **Formato:** PNG (com fundo transparente) ou JPG
- **Qualidade:** Alta resolução
- **Fundo:** Transparente (PNG) ou preto (JPG)

---

## 🚀 Depois de Colocar a Imagem

```bash
# Regenerar os ícones
npm run generate-icons

# Build do projeto
npm run build

# Testar
npm run preview
```

---

**💡 Dica:** Se você tem a imagem em outro formato, converta para PNG usando qualquer editor de imagens (Photoshop, GIMP, etc.)

