# 🏆 Sistema de Ranking e Premiação

## ✅ Funcionalidades Implementadas

### 1. Sistema de Níveis (Tiers)

O sistema possui 5 níveis baseados em pontos:

- **🥉 Bronze** - Primeira postagem (0-29 pontos)
- **🥈 Prata** - 30-99 pontos
- **🥇 Ouro** - 100-249 pontos
- **⚪ Platina** - 250-499 pontos
- **💎 Diamante** - 500+ pontos

### 2. Sistema de Pontos

**Como ganhar pontos:**
- ✅ **Publicação:** +2 pontos (primeira publicação concede Bronze)
- ✅ **Curtida em sua publicação:** +1 ponto
- ✅ **Comentário em sua publicação:** +1 ponto

### 3. Página de Premiação

- ✅ Nova aba "Premiação" no menu inferior (substituiu "Notificações")
- ✅ Lista de prêmios disponíveis
- ✅ Sistema de resgate de prêmios com pontos
- ✅ Histórico de resgates
- ✅ Controle de estoque

### 4. Ranking Atualizado

- ✅ Exibe o nível (tier) de cada usuário
- ✅ Badges visuais para cada nível
- ✅ Ranking ordenado por pontos

## 📋 Como Aplicar

### Passo 1: Executar a Migração

1. Acesse o Supabase Dashboard: https://app.supabase.com
2. Selecione o projeto `oglakfbpuosrhhtbyprw`
3. Vá em **SQL Editor**
4. Execute o arquivo `ranking-and-rewards-migration.sql`

### Passo 2: Verificar

Após executar, você deve ver:
- ✅ Coluna tier em profiles
- ✅ Tabela rewards
- ✅ Tabela redemptions

### Passo 3: Criar Prêmios (Opcional)

Para adicionar prêmios, execute no SQL Editor:

```sql
INSERT INTO public.rewards (name, description, points_cost, stock, is_active)
VALUES
  ('Camiseta Exclusiva', 'Camiseta oficial da comunidade', 50, 10, true),
  ('Kit de Suplementos', 'Kit completo de suplementos', 100, 5, true),
  ('Consulta Personalizada', 'Consulta com nutricionista', 200, -1, true);
```

## 🎯 Estrutura do Banco

### Tabela `profiles` (atualizada)
- `tier` - Nível do usuário (bronze, silver, gold, platinum, diamond)
- `points` - Pontos acumulados

### Tabela `rewards`
- `id` - ID do prêmio
- `name` - Nome do prêmio
- `description` - Descrição
- `image_url` - URL da imagem
- `points_cost` - Custo em pontos
- `stock` - Estoque (-1 = ilimitado)
- `is_active` - Se está ativo

### Tabela `redemptions`
- `id` - ID do resgate
- `user_id` - ID do usuário
- `reward_id` - ID do prêmio
- `points_spent` - Pontos gastos
- `status` - Status (pending, approved, delivered, cancelled)

## 🔄 Triggers e Funções

### `add_points_for_post()`
- Adiciona 2 pontos ao criar post
- Concede Bronze na primeira postagem

### `add_points_for_comment()`
- Adiciona 1 ponto ao autor do post quando recebe comentário

### `update_post_likes_count()`
- Adiciona 1 ponto ao autor do post quando recebe curtida

### `update_user_tier()`
- Atualiza automaticamente o tier baseado nos pontos

### `redeem_reward()`
- Função RPC para resgatar prêmios
- Valida pontos e estoque
- Deduz pontos e cria resgate

## 📱 Interface

### BottomNav
- Removido: "Notificações"
- Adicionado: "Premiação" (ícone Gift)

### Página de Premiação (`/rewards`)
- Aba "Prêmios" - Lista de prêmios disponíveis
- Aba "Meus Resgates" - Histórico de resgates
- Card com pontos do usuário
- Botões de resgate com validação

### Página de Ranking (`/ranking`)
- Exibe tier de cada usuário
- Badges visuais para níveis
- Ranking ordenado por pontos

## ⚠️ Importante

- A primeira postagem de um usuário automaticamente concede o nível Bronze
- Os pontos são atualizados automaticamente via triggers
- O tier é atualizado automaticamente quando os pontos mudam
- Prêmios podem ter estoque limitado ou ilimitado (-1)

## 🆘 Troubleshooting

### Tier não está sendo atualizado
- Verifique se o trigger `on_points_update_tier` foi criado
- Verifique se a função `update_user_tier()` existe

### Pontos não estão sendo adicionados
- Verifique se os triggers foram criados corretamente
- Verifique os logs do Supabase para erros

### Prêmios não aparecem
- Verifique se `is_active = true` na tabela rewards
- Verifique as políticas RLS

