-- Atualizar prêmios com imagens ilustrativas
-- Execute este script no SQL Editor do Supabase após inserir os prêmios

-- Atualizar Pix Misterioso
UPDATE rewards 
SET image_url = 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=400&h=300&fit=crop'
WHERE name = 'Pix Misterioso';

-- Atualizar Um Dia de Anúncios
UPDATE rewards 
SET image_url = 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=300&fit=crop'
WHERE name = 'Um Dia de Anúncios';

-- Atualizar Dia com a Equipe
UPDATE rewards 
SET image_url = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400&h=300&fit=crop'
WHERE name = 'Dia com a Equipe';

-- Atualizar Viagem Tudo Pago
UPDATE rewards 
SET image_url = 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400&h=300&fit=crop'
WHERE name = 'Viagem Tudo Pago';

-- Atualizar iPhone Novo
UPDATE rewards 
SET image_url = 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=400&h=300&fit=crop'
WHERE name = 'iPhone Novo';

-- Verificar as atualizações
SELECT id, name, points_cost, 
       CASE 
         WHEN image_url IS NOT NULL THEN '✓ Com imagem'
         ELSE '✗ Sem imagem'
       END as status_imagem
FROM rewards 
ORDER BY points_cost ASC;

