# ✅ Adicionar APP_URL no Supabase

## 📋 URL Fornecida:

```
tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app
```

---

## ⚠️ Importante: URL de Produção vs Preview

A URL que você forneceu parece ser uma **URL de preview** do Vercel. 

**Recomendação:** Use a **URL de produção** (domínio principal) se você tiver configurado.

### Opções:

1. **Se você tem domínio customizado:**
   ```
   APP_URL=https://seudominio.com
   ```

2. **Se você tem URL de produção no Vercel:**
   ```
   APP_URL=https://tribo-nutra-hub.vercel.app
   ```
   (ou o nome que você configurou)

3. **Se você quer usar a URL de preview (para testes):**
   ```
   APP_URL=https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app
   ```

---

## ✅ Como Adicionar no Supabase:

1. **Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**
2. Clique em **"Add new secret"** ou edite se já existir
3. **Name:** `APP_URL`
4. **Value:** `https://tribo-nutra-4a0vanjq1-vinicius-projects-565bddd1.vercel.app`
   (ou use a URL de produção se tiver)
5. Clique em **Save**

---

## 🎯 Próximos Passos:

Agora que você tem todas as secrets principais:

- [x] STRIPE_SECRET_KEY
- [x] STRIPE_PUBLISHABLE_KEY
- [x] STRIPE_PRICE_ID
- [ ] **APP_URL** ← Adicionar agora!
- [ ] Deploy Edge Functions
- [ ] Configurar Webhook
- [ ] STRIPE_WEBHOOK_SECRET
- [ ] Executar SQL das tabelas

---

## 💡 Dica:

Se você mudar a URL depois (por exemplo, configurar um domínio customizado), basta atualizar o secret `APP_URL` no Supabase!

---

**🚀 Depois de adicionar o APP_URL, podemos fazer o deploy das Edge Functions!**

