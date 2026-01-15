# 🚀 Configurar Push Notifications - Passo a Passo

## ✅ O que já está implementado:

1. ✅ Service Worker com handlers de push (`public/sw.js`)
2. ✅ Hook `usePushNotifications` para gerenciar subscriptions
3. ✅ Componente `NotificationToggle` no perfil
4. ✅ Chaves VAPID geradas (veja abaixo)

## 🔧 Passos para ativar:

### 1. Executar SQL no Supabase

Execute o script `GARANTIR-PUSH-NOTIFICATIONS-FUNCIONANDO.sql` no Supabase SQL Editor para criar a tabela `push_subscriptions`.

### 2. Configurar Chave VAPID no .env

As chaves VAPID foram geradas. Adicione no seu `.env`:

```env
VITE_VAPID_PUBLIC_KEY=BA52B0h6ULoRZOwoRfQrRnj9hxFCS0ZugOgxOeeLV4jQ6kZyBrDTS2SKRIyREVFHrEbD_ddsQO2HK2exX3ZUBo8
```

**⚠️ IMPORTANTE**: Se você já tem uma chave no `.env`, mantenha a que está lá. Se não tem, adicione esta.

### 3. Testar no Navegador

1. Abra o app no navegador (Chrome, Firefox ou Edge)
2. Vá em **Perfil** → **Notificações Push**
3. Clique em **"Ativar Notificações"**
4. Permita notificações quando o navegador solicitar
5. Verifique se aparece "✅ Notificações Ativadas"

### 4. Verificar se está funcionando

Execute no Supabase SQL Editor:

```sql
SELECT 
  u.email,
  ps.endpoint,
  ps.created_at
FROM push_subscriptions ps
JOIN auth.users u ON u.id = ps.user_id
ORDER BY ps.created_at DESC;
```

Se aparecer sua subscription, está funcionando! 🎉

## 📱 Para enviar notificações reais (opcional - futuro)

Quando quiser enviar notificações push reais, você precisará:

1. Criar uma Supabase Edge Function
2. Adicionar a chave privada VAPID nas Supabase Secrets
3. Chamar a function quando uma notificação for criada

Por enquanto, o sistema está pronto para receber e salvar as subscriptions. As notificações push reais precisarão da Edge Function.

## 🔍 Troubleshooting

### "Push notifications não são suportadas"
- Use Chrome, Firefox ou Edge
- Certifique-se de estar em HTTPS (ou localhost)

### "Erro ao ativar notificações"
- Verifique se a chave VAPID está no `.env`
- Verifique se a tabela `push_subscriptions` foi criada
- Verifique os logs do console do navegador

### "Permissão negada"
- Vá nas configurações do navegador e permita notificações para o site
- Recarregue a página e tente novamente

