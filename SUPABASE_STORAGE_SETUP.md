# Configuração do Supabase Storage

Para que o upload de imagens funcione, é necessário configurar o bucket de storage no Supabase.

## Passos para configurar:

1. Acesse o painel do Supabase: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Storage** no menu lateral
4. Clique em **Create a new bucket**
5. Configure o bucket:
   - **Name**: `images`
   - **Public bucket**: ✅ Marque como público
   - **File size limit**: 5 MB (ou o valor desejado)
   - **Allowed MIME types**: `image/*`

6. Após criar o bucket, configure as políticas de acesso:

### Política de Upload (INSERT)
```sql
CREATE POLICY "Users can upload images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');
```

### Política de Leitura (SELECT)
```sql
CREATE POLICY "Public can view images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'images');
```

### Política de Deletar (DELETE)
```sql
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'images' AND (storage.foldername(name))[1] = auth.uid()::text);
```

## Estrutura de pastas:
- `images/avatars/` - Fotos de perfil
- `images/posts/` - Imagens dos posts

## Nota:
As políticas acima permitem que usuários autenticados façam upload e que qualquer pessoa possa visualizar as imagens. Ajuste conforme necessário para seus requisitos de segurança.

