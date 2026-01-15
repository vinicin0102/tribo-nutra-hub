-- Inserir prêmios específicos na tabela rewards
-- Execute este script no SQL Editor do Supabase

-- Limpar prêmios existentes (opcional - descomente se quiser resetar)
-- DELETE FROM rewards;

-- Inserir os novos prêmios
INSERT INTO rewards (name, description, points_cost, stock, image_url, created_at) VALUES
  (
    'Pix Misterioso',
    'Receba um valor surpresa via Pix! Pode ser de R$ 10 a R$ 100!',
    250,
    999,
    NULL,
    NOW()
  ),
  (
    'Um Dia de Anúncios',
    'Ganhe um dia completo de anúncios gerenciados por minha conta profissional!',
    500,
    50,
    NULL,
    NOW()
  ),
  (
    'Dia com a Equipe',
    'Passe um dia comigo e com minha equipe, com direito a almoço, lanche e networking!',
    700,
    20,
    NULL,
    NOW()
  ),
  (
    'Viagem Tudo Pago',
    'Uma viagem completa com todas as despesas pagas! Hospedagem, alimentação e transporte inclusos.',
    1500,
    5,
    NULL,
    NOW()
  ),
  (
    'iPhone Novo',
    'Ganhe um iPhone novinho em folha! O modelo mais recente disponível.',
    2500,
    3,
    NULL,
    NOW()
  )
ON CONFLICT DO NOTHING;

-- Verificar os prêmios inseridos
SELECT id, name, description, points_cost, stock 
FROM rewards 
ORDER BY points_cost ASC;

