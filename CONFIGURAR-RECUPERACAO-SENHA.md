# 🔐 Configurar Recuperação de Senha

## ✅ Funcionalidade Implementada

A recuperação de senha foi adicionada à página de login. Os alunos agora podem:

1. Clicar em **"Esqueci minha senha"** na tela de login
2. Inserir seu email
3. Receber um email com link de recuperação
4. Clicar no link e definir uma nova senha

---

## 📋 Configuração no Supabase

### 1. Configurar Email Templates

1. Acesse: **https://supabase.com/dashboard**
2. Selecione seu projeto
3. Vá em: **Authentication** → **Email Templates**
4. Selecione: **Reset Password**

### 2. Personalizar Template (Opcional)

Você pode personalizar o template de email. O template padrão já funciona, mas você pode:

- Adicionar logo da sua marca
- Personalizar o texto
- Alterar cores

**Variáveis disponíveis:**
- `{{ .ConfirmationURL }}` - Link de recuperação
- `{{ .Email }}` - Email do usuário
- `{{ .Token }}` - Token de recuperação

### 3. Configurar URL de Redirecionamento

1. Vá em: **Authentication** → **URL Configuration**
2. Em **Redirect URLs**, adicione:
   - `https://seudominio.com/reset-password`
   - `http://localhost:5173/reset-password` (para desenvolvimento)

3. Clique em **Save**

**⚠️ Importante:** A URL deve corresponder exatamente ao seu domínio.

---

## 🧪 Como Testar

### Passo 1: Solicitar Recuperação

1. Acesse a página de login
2. Clique em **"Esqueci minha senha"**
3. Digite um email cadastrado
4. Clique em **"Enviar link de recuperação"**

### Passo 2: Verificar Email

1. Verifique a caixa de entrada do email
2. Abra o email do Supabase
3. Clique no link de recuperação

### Passo 3: Redefinir Senha

1. Você será redirecionado para `/reset-password`
2. Digite a nova senha (mínimo 6 caracteres)
3. Confirme a senha
4. Clique em **"Atualizar senha"**
5. Você será redirecionado para o login

---

## 🎨 Interface

### Tela de Login
- Link **"Esqueci minha senha"** aparece abaixo do botão de login
- Ao clicar, abre um formulário simples para inserir o email

### Tela de Recuperação
- Formulário limpo com apenas o campo de email
- Botão "Voltar para login" para cancelar

### Tela de Redefinição
- Dois campos: Nova senha e Confirmar senha
- Botões para mostrar/ocultar senha
- Validação de senha (mínimo 6 caracteres)
- Verificação de senhas coincidentes

---

## 🆘 Problemas Comuns

### Email não chega

**Possíveis causas:**
1. Email está na caixa de spam
2. Email não está cadastrado
3. Configuração de email do Supabase não está configurada

**Solução:**
- Verifique a caixa de spam
- Verifique se o email está correto
- No Supabase Dashboard, vá em **Settings** → **Auth** → **SMTP Settings** e configure um provedor SMTP (ou use o padrão do Supabase)

### Link expirado ou inválido

**Causa:**
- Links de recuperação expiram após um tempo (padrão: 1 hora)

**Solução:**
- Solicite um novo link de recuperação

### Erro ao atualizar senha

**Possíveis causas:**
1. Link expirado
2. Senha muito curta (menos de 6 caracteres)
3. Senhas não coincidem

**Solução:**
- Verifique se a senha tem pelo menos 6 caracteres
- Certifique-se de que as duas senhas são iguais
- Se o link expirou, solicite um novo

---

## 📧 Configurar SMTP Personalizado (Opcional)

Para usar seu próprio servidor SMTP:

1. No Supabase Dashboard: **Settings** → **Auth** → **SMTP Settings**
2. Configure:
   - **Host:** seu servidor SMTP
   - **Port:** porta SMTP (geralmente 587 ou 465)
   - **Username:** seu usuário SMTP
   - **Password:** sua senha SMTP
   - **Sender email:** email que enviará os emails
   - **Sender name:** nome que aparecerá nos emails

3. Clique em **Save**

---

## ✅ Checklist

- [ ] URL de redirecionamento configurada no Supabase
- [ ] Template de email verificado (ou personalizado)
- [ ] Teste de solicitação de recuperação funcionando
- [ ] Email chegando na caixa de entrada
- [ ] Link de recuperação funcionando
- [ ] Redefinição de senha funcionando

---

## 🎉 Pronto!

Agora os alunos podem recuperar suas senhas facilmente! 🔐

