# 🧹 Como Limpar o Banco de Dados

## ⚠️ PROBLEMA:
- Feed mostrando publicações diferentes/incorretas
- Posts duplicados ou inválidos
- Posts sem perfil associado

---

## 🔧 SOLUÇÃO:

### 1️⃣ Executar Script de Diagnóstico

**No Supabase Dashboard:**
1. Vá em **SQL Editor**
2. Abra o arquivo: `diagnostico-geral-banco.sql`
3. **Copie TODO o conteúdo**
4. **Cole no SQL Editor**
5. **Execute** (botão "Run" ou F5)
6. **Veja os resultados** - isso vai mostrar:
   - Quantos posts problemáticos existem
   - Posts duplicados
   - Posts com user_id inválido
   - Contagens incorretas

---

### 2️⃣ Executar Script de Limpeza

**⚠️ ATENÇÃO: Este script vai DELETAR posts problemáticos!**

**No Supabase Dashboard:**
1. Vá em **SQL Editor**
2. Abra o arquivo: `limpar-posts-problematicos.sql`
3. **Copie TODO o conteúdo**
4. **Cole no SQL Editor**
5. **Leia cuidadosamente** o que será deletado
6. **Execute** (botão "Run" ou F5)

**O que será deletado:**
- Posts com conteúdo vazio
- Posts com user_id inválido
- Posts duplicados (mantém apenas o mais recente)
- Posts com datas inválidas

**O que será corrigido:**
- Contagens de likes e comentários
- Contagens nos perfis (posts_count, likes_given_count, etc.)

---

### 3️⃣ Verificar Resultado

Após executar o script de limpeza, execute novamente o script de diagnóstico para ver:
- Quantos posts restaram
- Se as contagens estão corretas
- Se ainda há problemas

---

## ✅ O que foi corrigido no código:

1. **Filtro de posts válidos:**
   - Apenas posts com conteúdo não vazio
   - Apenas posts com perfil associado (validação indireta de user_id válido)
   - Limite de 100 posts para performance

2. **Ordenação correta:**
   - Posts ordenados por data (mais recente primeiro)
   - Validação de datas antes de ordenar

3. **Logs melhorados:**
   - Mostra quantos posts foram filtrados
   - Mostra quantos posts sem perfil foram removidos

---

## 📋 Checklist:

- [ ] Executar script de diagnóstico
- [ ] Verificar resultados do diagnóstico
- [ ] Executar script de limpeza (se necessário)
- [ ] Verificar resultado após limpeza
- [ ] Limpar cache do navegador (Ctrl+Shift+R)
- [ ] Testar o feed novamente

---

## 🆘 Se ainda tiver problemas:

1. Me diga o que apareceu no diagnóstico
2. Me diga quantos posts foram deletados na limpeza
3. Me diga se o feed ainda está mostrando posts incorretos

---

**🚀 Execute primeiro o diagnóstico, depois a limpeza se necessário!**

