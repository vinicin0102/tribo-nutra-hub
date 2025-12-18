# 🔍 Diagnóstico de Push Notifications

## Erro Encontrado

**"applicationServerKey must contain a valid P-256 public key"**

Este erro ocorre quando a chave VAPID não está no formato correto ou não está sendo carregada.

## ✅ Correções Aplicadas

1. **Validação da chave VAPID** antes de usar
2. **Limpeza da chave** (remove espaços e quebras de linha)
3. **Logs detalhados** para debug
4. **Mensagens de erro mais claras**

## 🧪 Como Testar Agora

1. **Recarregue o app completamente** (Ctrl+Shift+R ou Cmd+Shift+R)
2. **Abra o Console do Navegador** (F12 → Console)
3. **Vá em Perfil → Notificações Push**
4. **Clique em "Ativar Notificações"**
5. **Verifique os logs no console**:
   - `[Push] Tentando criar subscription com chave VAPID...`
   - `[Push] Chave (primeiros 20 chars): ...`
   - `[Push] Subscription criada com sucesso!` ou erro específico

## 🔧 Se Ainda Não Funcionar

### Opção 1: Regenerar Chaves VAPID

```bash
node scripts/generate-vapid-keys.js
```

Depois, atualize o `.env` com a nova chave pública.

### Opção 2: Verificar Service Worker

1. Abra DevTools → Application → Service Workers
2. Verifique se o Service Worker está ativo
3. Se não estiver, clique em "Unregister" e recarregue a página

### Opção 3: Limpar Cache

1. DevTools → Application → Storage
2. Clique em "Clear site data"
3. Recarregue a página

## 📋 Checklist

- [ ] Chave VAPID está no `.env` como `VITE_VAPID_PUBLIC_KEY=...`
- [ ] App foi recarregado completamente após mudanças
- [ ] Service Worker está registrado e ativo
- [ ] Permissão de notificações foi concedida
- [ ] Navegador suporta push (Chrome/Firefox/Edge)
- [ ] Está em HTTPS ou localhost

## 🐛 Logs para Verificar

No console do navegador, procure por:

- `[SW] Service Worker registrado com sucesso`
- `[Push] Tentando criar subscription...`
- `[Push] Subscription criada com sucesso!`
- Qualquer erro começando com `[Push]` ou `[SW]`

