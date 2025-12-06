# 📋 Informações Necessárias para Conectar o Gateway

## 🎯 O que eu preciso de você:

---

## 1️⃣ ESCOLHA DO GATEWAY

Qual gateway você quer usar?
- [ ] **Peper**
- [ ] **Doppus**
- [ ] **Outro** (qual?)

---

## 2️⃣ CREDENCIAIS DE API

### Para Peper:
```
✅ API Key: _______________________
✅ API Secret: _______________________
✅ Merchant ID: _______________________ (se necessário)
```

### Para Doppus:
```
✅ API Token: _______________________
   (Formato: sk_test_... ou sk_live_...)
```

**Onde encontrar:**
- Painel do Gateway → Configurações → API
- ⚠️ Use credenciais de **TESTE** primeiro!

---

## 3️⃣ URL DO SEU APP

```
✅ URL de Produção: _______________________
```

**Exemplos:**
- `https://tribo-nutra-hub.vercel.app`
- `https://seudominio.com.br`

**Onde encontrar:**
- Vercel Dashboard → Settings → Domains
- Ou me diga qual é o domínio do seu app

---

## 4️⃣ INFORMAÇÕES DO SUPABASE

### Project ID:
```
✅ Supabase Project ID: _______________________
```

**Onde encontrar:**
- Supabase Dashboard → Settings → General → Reference ID
- Formato: `abcdefghijklmnop` (letras e números)

**OU** me diga a URL do seu Supabase:
- Exemplo: `https://abcdefghijklmnop.supabase.co`
- Eu extraio o Project ID da URL

---

## 5️⃣ INFORMAÇÕES DO PRODUTO/PLANO

### Se você já criou o produto no gateway:
```
✅ Product ID: _______________________
✅ Valor: R$ 197,00 (confirmar?)
✅ Nome do Plano: Plano Diamond - Nutra Elite (confirmar?)
```

### Se ainda não criou:
- Não precisa me passar nada
- Eu te ajudo a criar depois

---

## 6️⃣ DOCUMENTAÇÃO DA API (Opcional, mas útil)

Se você tiver acesso à documentação da API do gateway:
- [ ] URL da documentação: _______________________
- [ ] Exemplos de requisições/respostas
- [ ] Formato de webhooks

**Se não tiver:** Não tem problema! Eu adapto conforme o padrão comum.

---

## 📝 RESUMO: O MÍNIMO NECESSÁRIO

Para eu começar a configurar, preciso **APENAS** de:

1. ✅ **Qual gateway** (Peper ou Doppus)
2. ✅ **API Key/Token** (credencial de teste)
3. ✅ **URL do seu App** (ex: `https://seuapp.vercel.app`)
4. ✅ **Supabase Project ID** (ou URL do Supabase)

**Isso é o suficiente para começar!** 🚀

---

## 📤 COMO ME ENVIAR

Você pode me enviar assim:

```
Gateway: Peper
API Key: pk_test_abc123xyz...
API Secret: sk_test_def456...
URL do App: https://tribo-nutra-hub.vercel.app
Supabase Project ID: abcdefghijklmnop
```

**OU** simplesmente me diga:
- "Quero usar Peper"
- "Minha API Key é: pk_test_..."
- "Meu app está em: https://..."
- "Meu Supabase Project ID é: ..."

---

## ⚠️ IMPORTANTE

### Segurança:
- ✅ Use credenciais de **TESTE** primeiro
- ✅ Não compartilhe credenciais de produção publicamente
- ✅ Depois de testar, trocamos para produção

### O que eu vou fazer:
1. ✅ Configurar secrets no Supabase
2. ✅ Criar Edge Functions
3. ✅ Fazer deploy das functions
4. ✅ Configurar webhooks
5. ✅ Testar a integração

---

## 🎯 PRÓXIMOS PASSOS

1. **Você:** Me envia as informações acima
2. **Eu:** Configuro tudo e faço o deploy
3. **Você:** Testa o fluxo de pagamento
4. **Você:** Me avisa se funcionou ou se precisa ajustar

---

## ❓ DÚVIDAS?

Se você não souber onde encontrar alguma informação:
- **API Key:** Me diga qual gateway e eu te ajudo a encontrar
- **URL do App:** Me diga onde está hospedado (Vercel, etc)
- **Supabase Project ID:** Me diga a URL do Supabase ou eu te ajudo a encontrar

**Estou aqui para ajudar!** 😊

---

**🚀 Pronto para começar? Me envie as informações e eu configuro tudo!**

