# 🧹 Limpeza do Feed e Chat

## Como executar a limpeza

### Opção 1: Via Supabase Dashboard (Recomendado)

1. Acesse o **Supabase Dashboard** do seu projeto
2. Vá em **SQL Editor**
3. Execute o seguinte script:

```sql
-- Desabilitar triggers
ALTER TABLE public.posts DISABLE TRIGGER on_post_created;
ALTER TABLE public.comments DISABLE TRIGGER on_comment_change;
ALTER TABLE public.likes DISABLE TRIGGER on_like_change;
ALTER TABLE public.chat_messages DISABLE TRIGGER on_chat_message;

-- Limpar dados
DELETE FROM public.likes;
DELETE FROM public.comments;
DELETE FROM public.posts;
DELETE FROM public.chat_messages;

-- Reabilitar triggers
ALTER TABLE public.posts ENABLE TRIGGER on_post_created;
ALTER TABLE public.comments ENABLE TRIGGER on_comment_change;
ALTER TABLE public.likes ENABLE TRIGGER on_like_change;
ALTER TABLE public.chat_messages ENABLE TRIGGER on_chat_message;
```

### Opção 2: Via Migration

O arquivo `supabase/migrations/20251212170000_clean_feed_and_chat.sql` foi criado, mas **NÃO execute como migration** pois migrations são permanentes.

Em vez disso, copie o conteúdo e execute diretamente no SQL Editor do Supabase.

## ⚠️ Importante

- **Backup**: Faça backup antes de executar se quiser manter os dados
- **Storage**: As imagens/vídeos no Supabase Storage **NÃO** são deletadas automaticamente
  - Acesse **Storage** > **posts** no dashboard e delete manualmente se necessário
- **Pontos**: Os pontos dos usuários **NÃO** serão revertidos automaticamente
  - Se quiser resetar pontos também, execute: `UPDATE public.profiles SET points = 0;`

## 📊 Verificação

Após executar, verifique:
- Feed vazio: `SELECT COUNT(*) FROM public.posts;` (deve retornar 0)
- Chat vazio: `SELECT COUNT(*) FROM public.chat_messages;` (deve retornar 0)

