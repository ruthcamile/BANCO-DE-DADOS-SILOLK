-- ============================================
-- SCRIPT DE TESTE DAS PROCEDURES E FUNÇÕES
-- ============================================

-- TESTES DAS FUNÇÕES
SELECT '========== TESTANDO FUNÇÕES ==========' AS teste;

-- Teste 1: Função de dias de armazenamento
SELECT 
    id_lote,
    tipo_semente,
    fn_dias_armazenamento(id_lote) AS dias_armazenado
FROM lote 
LIMIT 5;

-- Teste 2: Função de status do lote
SELECT 
    id_lote,
    tipo_semente,
    fn_status_lote(id_lote) AS status_atual
FROM lote 
LIMIT 5;

-- Teste 3: Função de alertas críticos
SELECT 
    id_lote,
    tipo_semente,
    fn_total_alertas_criticos(id_lote) AS alertas_criticos
FROM lote 
LIMIT 5;

-- Teste 4: Função de temperatura média
SELECT 
    id_lote,
    tipo_semente,
    fn_temperatura_media_lote(id_lote) AS temp_media
FROM lote 
LIMIT 5;

-- Teste 5: Função de verificação de manutenção de local
SELECT 
    id_local,
    nome_local,
    fn_local_precisa_manutencao(id_local) AS status_manutencao
FROM local_armazenamento 
LIMIT 5;

-- Teste 6: Função de tempo médio de rota
SELECT fn_tempo_medio_rota('Fazenda 01', 'Silo Central 01') AS tempo_medio_horas;

-- TESTES DAS PROCEDURES
SELECT '========== TESTANDO PROCEDURES ==========' AS teste;

-- Teste 1: Registrar novo lote
CALL sp_registrar_lote('Arroz', 1500.00, 1, 1, @id_lote, @msg);
SELECT @id_lote AS lote_criado, @msg AS mensagem;

-- Teste 2: Registrar leitura
CALL sp_registrar_leitura(1, 1, 1, 25.5, 60.0, 120.0, @alerta, @msg);
SELECT @alerta AS alerta_gerado, @msg AS mensagem;

-- Teste 3: Iniciar transporte
CALL sp_iniciar_transporte(1, 11, 'Silo Central 01', 'Doca 01', @id_transp, @msg);
SELECT @id_transp AS transporte_id, @msg AS mensagem;

-- Teste 4: Visualizar alerta
CALL sp_visualizar_alerta(1, 1, @msg);
SELECT @msg AS mensagem;

-- Teste 5: Atualizar status de sensor
CALL sp_atualizar_status_sensor(1, 'Ativo', @msg);
SELECT @msg AS mensagem;

-- Teste 6: Gerar relatório de lote
CALL sp_relatorio_lote(1);

-- Teste 7: Listar alertas pendentes de empresa
CALL sp_alertas_pendentes_empresa(1);

-- Teste 8: Estatísticas de comprador
CALL sp_estatisticas_comprador(1);

-- Teste 9: Verificar sensores inativos
CALL sp_verificar_sensores_inativos();

-- Teste 10: Dashboard de empresa
CALL sp_dashboard_empresa(1);

-- Teste 11: Listar lotes com atenção urgente
CALL sp_lotes_atencao_urgente();

-- Teste 12: Finalizar transporte
CALL sp_finalizar_transporte(1, @msg);
SELECT @msg AS mensagem;

-- Teste 13: Finalizar lote
CALL sp_finalizar_lote(50, @msg);
SELECT @msg AS mensagem;

-- Teste 14: Transferir sensor
CALL sp_transferir_sensor(1, 2, @msg);
SELECT @msg AS mensagem;

SELECT '========== TESTES CONCLUÍDOS ==========' AS resultado;