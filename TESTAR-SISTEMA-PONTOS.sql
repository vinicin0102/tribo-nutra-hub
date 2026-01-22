-- =====================================================
-- SCRIPT DE TESTE DO SISTEMA DE PONTOS
-- =====================================================
-- Este script vai ajudar a verificar se o sistema está funcionando.
-- Siga as instruções nos comentários.

-- 1. VERIFICAR SE AS TABELAS EXISTEM
SELECT 
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'daily_points') as tabela_daily_points_existe,
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_daily_logins') as tabela_user_daily_logins_existe,
  EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'profiles') as tabela_profiles_existe;

-- 2. VERIFICAR SE AS FUNÇÕES EXISTEM
SELECT 
  routine_name, 
  routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('add_points_with_limit', 'record_daily_login', 'add_points_for_post', 'add_points_for_daily_login');

-- 3. VERIFICAR SE OS TRIGGERS ESTÃO ATIVOS
SELECT 
  event_object_table as tabela,
  trigger_name,
  event_manipulation as evento,
  action_statement as acao
FROM information_schema.triggers
WHERE event_object_table IN ('posts', 'likes', 'comments')
ORDER BY event_object_table;

-- 4. CONSULTAR SEUS PONTOS ATUAIS (Substitua SEU_ID_AQUI pelo seu UUID se souber, ou pegue os top 5)
SELECT user_id, email, points, points_earned_today 
FROM profiles 
LEFT JOIN (
    SELECT user_id as dp_user_id, points_earned as points_earned_today 
    FROM daily_points 
    WHERE points_date = CURRENT_DATE
) dp ON profiles.user_id = dp.dp_user_id
ORDER BY points DESC
LIMIT 5;

-- 5. TESTAR ADIÇÃO MANUAL DE PONTOS (Simulação)
-- Para testar de verdade, substitua o ID abaixo pelo seu ID de usuário
-- SELECT public.add_points_with_limit('SEU_UUID_AQUI', 1, 'teste_manual', 'Teste de verificação');

-- Se tudo acima retornar resultados positivos (TRUE para existências, listas de triggers preenchidas),
-- então o sistema está configurado corretamente no banco de dados.
