# 📊 Limites do Plano Free do Supabase

## 👥 Limites de Usuários e Dados

### **Usuários (Auth)**
- ✅ **Ilimitado** - Não há limite de número de usuários no plano Free
- ✅ Você pode ter quantos usuários quiser cadastrados
- ✅ Todos os recursos de autenticação estão disponíveis

### **Armazenamento de Dados (Database)**
- 📦 **500 MB** de espaço no banco de dados PostgreSQL
- 📊 **2 GB** de transferência de dados por mês
- 🔄 **2 milhões** de requisições de API por mês

### **Armazenamento de Arquivos (Storage)**
- 📁 **1 GB** de armazenamento de arquivos
- 📤 **2 GB** de transferência de arquivos por mês

### **Realtime**
- 🔌 **200 conexões simultâneas** de Realtime
- ⚡ **5 mensagens por segundo** por conexão

### **Edge Functions**
- ⚙️ **500.000 invocações por mês**
- ⏱️ **2 segundos** de tempo de execução por função

---

## 📈 Estimativa de Capacidade

### **Quantos Usuários Você Pode Ter?**

Com **500 MB** de espaço no banco, você pode ter aproximadamente:

#### **Cenário Conservador (dados mínimos por usuário)**
- **Perfil básico**: ~2 KB por usuário
- **500 MB ÷ 2 KB = ~250.000 usuários**

#### **Cenário Realista (com posts, comentários, etc.)**
- **Perfil completo**: ~5-10 KB por usuário
- **Posts/comentários**: ~1-5 KB por post
- **Estimativa**: **50.000 - 100.000 usuários ativos**

#### **Cenário com Muitos Dados (posts, imagens, etc.)**
- **Perfil + posts + interações**: ~20-50 KB por usuário
- **Estimativa**: **10.000 - 25.000 usuários ativos**

### **Fatores que Afetam o Espaço:**

1. **Tabela `profiles`** (por usuário):
   - ~2-5 KB (username, email, avatar_url, pontos, etc.)

2. **Tabela `posts`** (por post):
   - ~1-3 KB (conteúdo, metadata)
   - Imagens são armazenadas no Storage, não no DB

3. **Tabela `comments`** (por comentário):
   - ~500 bytes - 1 KB

4. **Tabela `likes`** (por like):
   - ~200 bytes

5. **Tabela `chat_messages`** (por mensagem):
   - ~500 bytes - 2 KB

6. **Tabela `user_badges`** (por badge):
   - ~200 bytes

7. **Tabela `support_chat`** (por mensagem):
   - ~1-3 KB

---

## 🎯 Recomendações

### **Para Maximizar a Capacidade:**

1. **Otimizar Armazenamento:**
   - ✅ Armazene imagens no Storage (1 GB disponível), não no DB
   - ✅ Use compressão para textos longos
   - ✅ Limpe dados antigos periodicamente (posts/comentários muito antigos)

2. **Monitorar Uso:**
   - Verifique o uso no Dashboard do Supabase
   - Configure alertas quando chegar a 80% do limite

3. **Otimizar Queries:**
   - Use índices nas colunas mais consultadas
   - Limite resultados com paginação
   - Evite queries que retornam muitos dados

### **Quando Considerar Upgrade:**

Considere o plano **Pro ($25/mês)** quando:
- 📊 Banco de dados > 400 MB (80% de 500 MB)
- 👥 Mais de 50.000 usuários ativos
- 📤 Mais de 1.5 GB de transferência por mês
- 🔌 Mais de 150 conexões Realtime simultâneas

---

## 📊 Comparação: Free vs Pro

| Recurso | Free | Pro ($25/mês) |
|---------|------|----------------|
| **Usuários** | Ilimitado | Ilimitado |
| **Database** | 500 MB | 8 GB |
| **Transferência DB** | 2 GB/mês | 50 GB/mês |
| **Storage** | 1 GB | 100 GB |
| **Transferência Storage** | 2 GB/mês | 200 GB/mês |
| **API Requests** | 2M/mês | 50M/mês |
| **Realtime Connections** | 200 | 500 |
| **Edge Functions** | 500K/mês | 2M/mês |

---

## 🔍 Como Verificar Seu Uso Atual

No Dashboard do Supabase:
1. Vá em **Settings** → **Usage**
2. Veja:
   - **Database Size**: Espaço usado no banco
   - **API Requests**: Requisições do mês
   - **Storage**: Espaço usado no storage
   - **Bandwidth**: Transferência de dados

---

## 💡 Dicas para Economizar Espaço

1. **Limpar Dados Antigos:**
   ```sql
   -- Exemplo: Deletar posts muito antigos (mais de 1 ano)
   DELETE FROM posts 
   WHERE created_at < NOW() - INTERVAL '1 year';
   ```

2. **Arquivar em vez de Deletar:**
   - Crie uma tabela `posts_archived` para dados antigos
   - Mova dados antigos para lá em vez de deletar

3. **Comprimir Dados:**
   - Use JSONB para dados estruturados (mais eficiente)
   - Comprima textos longos se necessário

4. **Otimizar Imagens:**
   - Redimensione imagens antes de upload
   - Use formatos eficientes (WebP, JPEG otimizado)

---

## ⚠️ Limites Importantes

- **Database**: 500 MB (hard limit)
- **API Requests**: 2M/mês (soft limit - pode continuar, mas com throttling)
- **Storage**: 1 GB (hard limit)
- **Realtime**: 200 conexões simultâneas (hard limit)

---

## 📞 Suporte

Se você estiver próximo dos limites:
1. Monitore o uso no Dashboard
2. Considere otimizações
3. Avalie upgrade para Pro se necessário
4. Entre em contato com o suporte do Supabase para dúvidas

---

**Última atualização**: Dezembro 2024
**Fonte**: [Supabase Pricing](https://supabase.com/pricing)

