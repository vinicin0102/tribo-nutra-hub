# 🎨 Como Usar Nova Imagem como Ícone PWA

## 📋 Passo a Passo

### 1. Adicionar a Imagem
Coloque sua imagem (PNG, JPG ou SVG) no diretório `public/` com um destes nomes:

**Prioridade:**
- `logo-sociedade-nutra.png` (ou `.jpg`, `.jpeg`)
- `logo.png` (ou `.jpg`, `.jpeg`)

### 2. Gerar os Ícones PWA
Execute os comandos:

```bash
# Gerar ícones padrão
npm run generate-icons

# Gerar ícones maskable (para Android)
node scripts/generate-maskable-icons.js
```

### 3. Verificar os Ícones
Os ícones serão gerados em `public/icons/`:
- `icon-72x72.png` até `icon-512x512.png`
- `icon-maskable-192x192.png`
- `icon-maskable-512x512.png`

### 4. Rebuild e Testar
```bash
npm run build
```

## ✅ Formatos Aceitos
- PNG (recomendado para imagens com fundo)
- JPG/JPEG
- SVG

## 💡 Dica
Se sua imagem tem fundo laranja com borda azul (como descrito), use PNG para manter as cores exatas!

