# 🏆 Explicação da Tabela `user_badges`

## 📋 O Que É?

A tabela `user_badges` é uma **tabela de relacionamento** (tabela intermediária) que conecta **usuários** com os **badges** (conquistas) que eles conquistaram.

É uma tabela **many-to-many** que permite:
- Um usuário ter múltiplos badges
- Um badge ser conquistado por múltiplos usuários

---

## 🗂️ Estrutura da Tabela

```sql
CREATE TABLE public.user_badges (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  badge_id UUID REFERENCES public.badges(id) ON DELETE CASCADE NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, badge_id)
);
```

### **Colunas:**

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `user_id` | UUID | ID do usuário que conquistou o badge |
| `badge_id` | UUID | ID do badge conquistado |
| `earned_at` | TIMESTAMP | Data/hora em que o badge foi conquistado |
| `UNIQUE(user_id, badge_id)` | Constraint | Garante que um usuário não pode ter o mesmo badge duas vezes |

---

## 🎯 Para Que Serve?

### **1. Sistema de Conquistas (Badges)**

A tabela armazena quais badges cada usuário conquistou. Exemplos de badges:
- 🌱 **Iniciante** - 0 pontos
- ⭐ **Ativo** - 50 pontos
- 🔥 **Engajado** - 150 pontos
- 💪 **Influenciador** - 300 pontos
- 👑 **Lenda** - 500 pontos

### **2. Exibição no Perfil e Posts**

Os badges aparecem:
- ✅ No perfil do usuário
- ✅ Nos posts que o usuário cria
- ✅ No ranking da comunidade

### **3. Gamificação**

Motiva os usuários a:
- Fazer mais posts
- Interagir mais na comunidade
- Ganhar mais pontos
- Conquistar mais badges

---

## 🔄 Como Funciona?

### **1. Atribuição Automática**

Quando um usuário ganha pontos, um **trigger automático** verifica se ele atingiu os requisitos para algum badge:

```sql
-- Trigger que executa quando os pontos do usuário mudam
CREATE TRIGGER trigger_auto_assign_badges
    AFTER UPDATE OF points ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_badges_on_points_update();
```

### **2. Função de Verificação**

A função `check_and_assign_badges()` verifica:
1. Quantos pontos o usuário tem
2. Quais badges ele já pode conquistar (baseado em `points_required`)
3. Insere na tabela `user_badges` se ainda não tiver

### **3. Exemplo Prático**

**Cenário:**
- Usuário tem **75 pontos**
- Badge "Ativo" requer **50 pontos**
- Badge "Engajado" requer **150 pontos**

**Resultado:**
- ✅ Badge "Ativo" é adicionado em `user_badges`
- ❌ Badge "Engajado" ainda não é adicionado (precisa de 150 pontos)

---

## 📊 Relacionamentos

### **Tabelas Relacionadas:**

```
auth.users (usuários)
    ↓
user_badges (conquistas dos usuários)
    ↓
badges (tipos de badges disponíveis)
```

### **Fluxo de Dados:**

1. **Usuário ganha pontos** → Tabela `profiles.points` é atualizada
2. **Trigger detecta mudança** → Executa `auto_assign_badges_on_points_update()`
3. **Função verifica badges** → `check_and_assign_badges()` verifica quais badges o usuário pode ter
4. **Badge é atribuído** → Registro é inserido em `user_badges`
5. **Badge aparece no app** → Frontend busca `user_badges` e exibe os badges

---

## 💻 Como É Usado no Código

### **1. Buscar Badges de um Usuário**

```typescript
// Hook useUserBadges
const { data: userBadges } = await supabase
  .from('user_badges')
  .select(`
    *,
    badges (*)
  `)
  .eq('user_id', user.id);
```

### **2. Exibir Badges nos Posts**

```typescript
// Em PostCard.tsx
<PostBadges badges={post.user_badges} maxDisplay={3} />
```

### **3. Ver Badges no Ranking**

```typescript
// Em Ranking.tsx
{userBadges?.map(badge => (
  <Badge key={badge.id}>
    {badge.badges.icon} {badge.badges.name}
  </Badge>
))}
```

---

## 🔍 Consultas Úteis

### **Ver todos os badges de um usuário:**

```sql
SELECT 
  ub.earned_at,
  b.name,
  b.icon,
  b.points_required
FROM user_badges ub
JOIN badges b ON b.id = ub.badge_id
WHERE ub.user_id = 'USER_ID_AQUI'
ORDER BY ub.earned_at DESC;
```

### **Ver quantos usuários têm cada badge:**

```sql
SELECT 
  b.name,
  b.icon,
  COUNT(ub.user_id) as total_usuarios
FROM badges b
LEFT JOIN user_badges ub ON ub.badge_id = b.id
GROUP BY b.id, b.name, b.icon
ORDER BY total_usuarios DESC;
```

### **Ver usuários sem badges:**

```sql
SELECT 
  p.username,
  p.points
FROM profiles p
WHERE NOT EXISTS (
  SELECT 1 FROM user_badges ub WHERE ub.user_id = p.user_id
);
```

---

## ⚙️ Políticas de Segurança (RLS)

```sql
-- Todos podem ver os badges dos usuários
CREATE POLICY "User badges are viewable by everyone" 
ON public.user_badges 
FOR SELECT 
USING (true);
```

**Isso significa:**
- ✅ Qualquer usuário pode ver os badges de outros usuários
- ✅ Badges são públicos (aparecem nos posts e perfis)
- ✅ Apenas o sistema pode inserir badges (via trigger/função)

---

## 📈 Estatísticas

### **Tamanho Estimado:**

- **Por registro**: ~200 bytes
- **10.000 usuários com 3 badges cada**: ~6 MB
- **Muito eficiente em espaço!**

### **Performance:**

- ✅ Índices automáticos em `user_id` e `badge_id`
- ✅ Constraint `UNIQUE` previne duplicatas
- ✅ Queries rápidas com JOIN

---

## 🎨 Badges Padrão do Sistema

O sistema vem com estes badges pré-configurados:

| Badge | Ícone | Pontos Necessários |
|-------|-------|-------------------|
| Iniciante | 🌱 | 0 |
| Ativo | ⭐ | 50 |
| Engajado | 🔥 | 150 |
| Influenciador | 💪 | 300 |
| Lenda | 👑 | 500 |

---

## 🔧 Manutenção

### **Atribuir Badges Manualmente:**

```sql
-- Atribuir badge específico para um usuário
INSERT INTO user_badges (user_id, badge_id)
VALUES ('USER_ID', 'BADGE_ID')
ON CONFLICT (user_id, badge_id) DO NOTHING;
```

### **Recalcular Badges de Todos os Usuários:**

```sql
-- Executar função para todos os usuários
DO $$
DECLARE
    v_user RECORD;
BEGIN
    FOR v_user IN SELECT user_id FROM profiles
    LOOP
        PERFORM public.check_and_assign_badges(v_user.user_id);
    END LOOP;
END $$;
```

### **Remover Badge de um Usuário:**

```sql
DELETE FROM user_badges 
WHERE user_id = 'USER_ID' 
AND badge_id = 'BADGE_ID';
```

---

## ✅ Resumo

A tabela `user_badges` é essencial para:

1. ✅ **Gamificação** - Sistema de conquistas
2. ✅ **Motivação** - Incentiva usuários a participar mais
3. ✅ **Visualização** - Badges aparecem em posts e perfis
4. ✅ **Automação** - Badges são atribuídos automaticamente baseado em pontos
5. ✅ **Estatísticas** - Permite ver quais badges são mais comuns

É uma tabela **simples mas poderosa** que adiciona gamificação ao app! 🎮

