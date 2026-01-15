-- Adicionar coluna pdf_url na tabela lessons se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'lessons' 
    AND column_name = 'pdf_url'
  ) THEN
    ALTER TABLE public.lessons 
    ADD COLUMN pdf_url TEXT;
    
    RAISE NOTICE 'Coluna pdf_url adicionada com sucesso à tabela lessons';
  ELSE
    RAISE NOTICE 'Coluna pdf_url já existe na tabela lessons';
  END IF;
END $$;

-- Verificar se a coluna foi criada
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'lessons' 
  AND column_name = 'pdf_url';

