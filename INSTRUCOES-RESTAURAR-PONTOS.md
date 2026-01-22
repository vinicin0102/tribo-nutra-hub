# 🏆 Guia: Restaurar e Testar o Sistema de Pontos (ATUALIZADO V2)

**Atualização:** O arquivo SQL foi corrigido para resolver o erro `cannot change return type of existing function`. Agora ele remove as versões antigas antes de criar as novas.

## 🚀 Passo 1: Aplicar a Correção (Versão Atualizada)

1. Vá novamente ao **Supabase SQL Editor**.
2. **Crie uma NOVA Query** (ou limpe a anterior).
3. Copie **TODO** o conteúdo atualizado do arquivo:
   👉 `SOLUCAO-RESTABELECER-PONTOS.sql`
   *(Certifique-se de pegar a versão que começa com "SOLUÇÃO DEFINITIVA... (V2 - CORRIGIDA)")*
4. Cole no editor e clique em **RUN**.

> **O que mudou?**
> Adicionei comandos `DROP FUNCTION` para garantir que versões antigas das funções não conflitem com a nova correção. Isso resolve o erro que apareceu.

---

## 🧪 Passo 2: Validar a Correção

Após executar o script acima com sucesso (`Success`):

1. Limpe o editor SQL e copie o conteúdo de:
   👉 `TESTAR-SISTEMA-PONTOS.sql`
2. Execute (RUN).
3. Verifique os resultados:
   - As tabelas devem aparecer como `true`.
   - Os triggers devem aparecer listados para `posts`, `likes` e `comments`.

---

## 📱 Passo 3: Teste Prático no App

1. **Recarregue sua aplicação** (`F5` no navegador).
2. **Faça um teste de interação**:
   - Dê um **Like** em algum post.
   - Veja se sua pontuação sobe.
   - O login diário deve funcionar corretamente agora.

## ❓ Detalhes da Pontuação

- **Login Diário**: 8 pts
- **Publicação**: 5 pts
- **Curtida**: 1 pt
- **Comentário**: 1 pt
- **Limite Diário**: 100 pts
