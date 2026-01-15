# 🎯 RESUMO: Integração de Pagamento Doppus

## 📋 O QUE VOCÊ PRECISA FAZER

### 1️⃣ Criar conta na Doppus
- Acesse: https://doppus.com/
- Crie sua conta
- Confirme e-mail

### 2️⃣ Criar produto/assinatura
- Doppus Dashboard → **Produtos** → **Novo Produto**
- Nome: "Plano Diamond - Nutra Elite"
- Tipo: **Assinatura**
- Valor: **R$ 197,00**
- Recorrência: **Mensal**
- **COPIAR O ID DO PRODUTO** (ex: `prod_abc123`)

### 3️⃣ Obter API Token
- Doppus Dashboard → **Configurações** → **API**
- **COPIAR O API TOKEN** (ex: `sk_test_xxxxxxxxxxxxx`)
- ⚠️ Use token de **TESTE** primeiro (`sk_test_`)

### 4️⃣ Ter URL do seu app
- URL do Vercel: `https://seuapp.vercel.app`
- Ou seu domínio personalizado

---

## 📤 O QUE VOCÊ PRECISA ME ENVIAR

Envie apenas **2 informações**:

1. **API Token da Doppus**
   ```
   sk_test_xxxxxxxxxxxxx
   ```

2. **URL do seu App**
   ```
   https://seuapp.vercel.app
   ```

---

## ✅ DEPOIS QUE VOCÊ ME ENVIAR

Eu vou:
1. ✅ Configurar as Edge Functions
2. ✅ Configurar os Secrets no Supabase
3. ✅ Configurar o webhook
4. ✅ Fazer o deploy
5. ✅ Testar tudo

---

## 🧪 TESTE RÁPIDO

Depois de configurado, você pode testar com:
- **Cartão:** `4111 1111 1111 1111` | CVV: `123` | Validade: `12/30`
- **Pix:** Qualquer código (ambiente de teste aprova automaticamente)

---

**🎯 RESUMO FINAL:**

1. Criar conta Doppus
2. Criar produto R$ 197/mês
3. Copiar API Token
4. Me enviar: Token + URL do App
5. Eu configuro tudo! 🚀

