# 📊 Capacidade de Usuários Simultâneos

## 🎯 Resumo Rápido

**Supabase Free Tier:**
- **Conexões simultâneas ao banco**: ~60 conexões
- **Usuários simultâneos estimados**: **50-100 usuários** (dependendo do uso)
- **API Requests**: 50.000/mês (gratuito) ou ilimitado (Pro)

**Supabase Pro Tier ($25/mês):**
- **Conexões simultâneas**: ~200 conexões
- **Usuários simultâneos estimados**: **150-300 usuários**
- **API Requests**: Ilimitado

## 📈 Detalhamento

### 1. Limites do Banco de Dados (PostgreSQL)

O Supabase usa PostgreSQL com connection pooling:

- **Free Tier**: 
  - Pool de conexões: ~60 conexões simultâneas
  - Cada usuário ativo pode usar 1-2 conexões
  - **Estimativa realista: 30-60 usuários simultâneos ativos**

- **Pro Tier**:
  - Pool de conexões: ~200 conexões simultâneas  
  - **Estimativa realista: 100-200 usuários simultâneos ativos**

### 2. Limites da API (REST/Realtime)

- **Free Tier**: 50.000 requisições/mês
- **Pro Tier**: Ilimitado

**Cálculo aproximado:**
- Cada usuário faz ~10-20 requisições por sessão
- Free tier: ~2.500-5.000 sessões/mês
- Pro tier: Ilimitado

### 3. Realtime (WebSockets)

- **Free Tier**: 200 conexões simultâneas
- **Pro Tier**: 500 conexões simultâneas

### 4. Storage

- **Free Tier**: 1GB
- **Pro Tier**: 100GB

## 🚀 Recomendações

### Para começar (Free Tier):
- ✅ **Até 50 usuários simultâneos**: Funciona bem
- ⚠️ **50-100 usuários**: Pode ter lentidão em picos
- ❌ **Acima de 100**: Necessário upgrade para Pro

### Para crescimento (Pro Tier):
- ✅ **Até 200 usuários simultâneos**: Funciona bem
- ⚠️ **200-300 usuários**: Monitorar performance
- 🔄 **Acima de 300**: Considerar otimizações ou upgrade

## 📊 Fatores que Afetam a Capacidade

1. **Tipo de uso**:
   - Feed (leitura): Menos conexões
   - Chat (Realtime): Mais conexões
   - Upload de imagens: Mais recursos

2. **Otimizações aplicadas**:
   - ✅ React Query (cache de dados)
   - ✅ Paginação de posts
   - ✅ Lazy loading de imagens
   - ✅ Connection pooling (Supabase)

3. **Picos de tráfego**:
   - Horários de maior uso podem reduzir capacidade
   - Realtime (chat) consome mais recursos

## 🎯 Estimativa Realista para Seu App

Considerando que o app tem:
- Feed de posts (leitura frequente)
- Chat em tempo real (Realtime)
- Upload de imagens
- Sistema de pontos e badges

**Free Tier:**
- **Usuários simultâneos**: **40-60 usuários**
- **Usuários totais**: Ilimitado (mas com limite de requisições)

**Pro Tier ($25/mês):**
- **Usuários simultâneos**: **150-250 usuários**
- **Usuários totais**: Ilimitado

## 💡 Dicas para Aumentar Capacidade

1. **Otimizar queries**: Usar índices no banco
2. **Cache**: React Query já está implementado ✅
3. **CDN**: Para imagens estáticas
4. **Paginação**: Já implementada ✅
5. **Lazy loading**: Já implementado ✅

## 🔍 Como Monitorar

1. **Supabase Dashboard** > **Database** > **Connection Pooling**
2. **API** > **Logs** para ver requisições
3. **Realtime** > **Channels** para conexões WebSocket

## ⚠️ Quando Fazer Upgrade

Considere upgrade para Pro quando:
- Muitas conexões simultâneas (>50 no Free)
- Limite de API requests atingido
- Lentidão percebida pelos usuários
- Mais de 1GB de storage necessário

## 📞 Suporte Supabase

- Documentação: https://supabase.com/docs
- Limites: https://supabase.com/pricing
- Suporte: Disponível no dashboard

---

**Conclusão**: Para começar com os alunos, o **Free Tier suporta bem até 50 usuários simultâneos**. Se crescer além disso, o upgrade para Pro ($25/mês) é recomendado.

