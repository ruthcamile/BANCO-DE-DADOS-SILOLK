-- ============================================
-- SCRIPT DE TESTE DAS TRIGGERS - SiloLK
-- TESTES PARA VALIDAR FUNCIONAMENTO DAS 15 TRIGGERS
-- ============================================

USE SiloLK;

SELECT '============================================' AS '';
SELECT '   INICIANDO TESTES DAS TRIGGERS' AS '';
SELECT '============================================' AS '';

-- ============================================
-- TESTE 1️ - Validar quantidade do lote (INSERT)
-- ============================================
SELECT 'TESTE 1: Validar quantidade do lote negativa (deve FALHAR)' AS teste;

-- Este comando deve gerar erro, não deve existir lotes negativos 
-- INSERT INTO lote (tipo_semente, quantidade, data_entrada, id_empresa_dona, id_comprador)
-- VALUES ('Teste Negativo', -100, NOW(), 1, 1);

-- Teste com quantidade válida (deve FUNCIONAR)
INSERT INTO lote (tipo_semente, quantidade, data_entrada, id_empresa_dona, id_comprador)
VALUES ('AtaldaSemente', 1000, NOW(), 1, 1);

SELECT 'SUCESSO: Lote com quantidade válida inserido!' AS resultado;
SET @id_lote_teste = LAST_INSERT_ID();

-- ============================================
-- TESTE 2️ - Validar quantidade do lote (UPDATE)
-- ============================================
SELECT 'TESTE 2: Tentar atualizar quantidade para valor negativo (deve FALHAR)' AS teste;

-- Este comando deve gerar erro
-- UPDATE lote SET quantidade = -50 WHERE id_lote = @id_lote_teste;

-- Teste com quantidade válida (deve FUNCIONAR)
UPDATE lote SET quantidade = 1500 WHERE id_lote = @id_lote_teste;
SELECT 'SUCESSO: Quantidade atualizada para valor válido!' AS resultado;

-- ============================================
-- TESTE 3 - Auditar inserção de lote
-- ============================================
SELECT 'TESTE 3: Verificar registro de auditoria da inserção' AS teste;

SELECT * FROM log_auditoria 
WHERE tabela = 'lote' AND operacao = 'INSERT' 
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 4️ - Auditar atualização de lote
-- ============================================
SELECT 'TESTE 4: Verificar registro de auditoria da atualização' AS teste;

SELECT * FROM log_auditoria 
WHERE tabela = 'lote' AND operacao = 'UPDATE' 
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 5️ - Validar tipo de local para transporte
-- ============================================
SELECT 'TESTE 5: Tentar criar transporte com local que não é veículo (deve FALHAR)' AS teste;

-- Este comando deve gerar erro (local 1 é Silo, não Veículo)
-- INSERT INTO transporte (data_inicio, origem, destino, id_lote, id_local_veiculo)
-- VALUES (NOW(), 'Teste Origem', 'Teste Destino', @id_lote_teste, 1);

-- Teste com veículo válido (deve FUNCIONAR)
INSERT INTO transporte (data_inicio, origem, destino, id_lote, id_local_veiculo)
VALUES (NOW(), 'Teste Origem', 'Teste Destino', @id_lote_teste, 11);

SELECT 'SUCESSO: Transporte criado com veículo válido!' AS resultado;
SET @id_transporte_teste = LAST_INSERT_ID();

-- ============================================
-- TESTE 6️ - Validar datas de transporte
-- ============================================
SELECT 'TESTE 6: Tentar finalizar transporte com data anterior ao início (deve FALHAR)' AS teste;

-- Este comando deve gerar erro
-- UPDATE transporte 
-- SET data_fim = DATE_SUB(data_inicio, INTERVAL 1 DAY)
-- WHERE id_transporte = @id_transporte_teste;

-- Teste com data válida (deve FUNCIONAR)
UPDATE transporte 
SET data_fim = DATE_ADD(data_inicio, INTERVAL 5 HOUR)
WHERE id_transporte = @id_transporte_teste;

SELECT 'SUCESSO: Transporte finalizado com data válida!' AS resultado;

-- ============================================
-- TESTE 7️ - Auditar finalização de transporte
-- ============================================
SELECT 'TESTE 7: Verificar registro de auditoria da finalização do transporte' AS teste;

SELECT * FROM log_auditoria 
WHERE tabela = 'transporte' AND operacao = 'FINALIZADO' 
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 8 - Gerar alerta automático - Temperatura ALTA
-- ============================================
SELECT 'TESTE 8: Inserir leitura com temperatura alta (deve gerar alerta AUTOMÁTICO)' AS teste;

-- Contar alertas antes
SET @alertas_antes = (SELECT COUNT(*) FROM alerta);

-- Inserir leitura com temperatura crítica
INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
VALUES (36.5, 60.0, 120.0, NOW(), 1, 1, @id_lote_teste);

-- Contar alertas depois
SET @alertas_depois = (SELECT COUNT(*) FROM alerta);

SELECT 
    @alertas_antes AS alertas_antes,
    @alertas_depois AS alertas_depois,
    (@alertas_depois - @alertas_antes) AS alertas_gerados,
    CASE 
        WHEN (@alertas_depois - @alertas_antes) > 0 THEN 'SUCESSO: Alerta gerado automaticamente!'
        ELSE 'FALHA: Alerta não foi gerado!'
    END AS resultado;

-- Ver o alerta gerado
SELECT * FROM alerta 
WHERE id_lote = @id_lote_teste AND tipo_alerta = 'Temperatura Alta'
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 9️  Gerar alerta automático - Temperatura BAIXA
-- ============================================
SELECT '
TESTE 9: Inserir leitura com temperatura baixa (deve gerar alerta AUTOMÁTICO)' AS teste;

SET @alertas_antes = (SELECT COUNT(*) FROM alerta);

INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
VALUES (4.5, 60.0, 120.0, NOW(), 1, 1, @id_lote_teste);

SET @alertas_depois = (SELECT COUNT(*) FROM alerta);

SELECT 
    (@alertas_depois - @alertas_antes) AS alertas_gerados,
    CASE 
        WHEN (@alertas_depois - @alertas_antes) > 0 THEN 'SUCESSO: Alerta gerado automaticamente!'
        ELSE 'FALHA: Alerta não foi gerado!'
    END AS resultado;

SELECT * FROM alerta 
WHERE id_lote = @id_lote_teste AND tipo_alerta = 'Temperatura Baixa'
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 10- Gerar alerta automático - Umidade ALTA
-- ============================================
SELECT '
TESTE 10: Inserir leitura com umidade alta (deve gerar alerta AUTOMÁTICO)' AS teste;

SET @alertas_antes = (SELECT COUNT(*) FROM alerta);

INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
VALUES (25.0, 88.0, 120.0, NOW(), 1, 1, @id_lote_teste);

SET @alertas_depois = (SELECT COUNT(*) FROM alerta);

SELECT 
    (@alertas_depois - @alertas_antes) AS alertas_gerados,
    CASE 
        WHEN (@alertas_depois - @alertas_antes) > 0 THEN 'SUCESSO: Alerta gerado automaticamente!'
        ELSE 'FALHA: Alerta não foi gerado!'
    END AS resultado;

SELECT * FROM alerta 
WHERE id_lote = @id_lote_teste AND tipo_alerta = 'Umidade Alta'
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 11- Gerar alerta automático - Umidade BAIXA
-- ============================================
SELECT 'TESTE 11: Inserir leitura com umidade baixa (deve gerar alerta AUTOMÁTICO)' AS teste;

SET @alertas_antes = (SELECT COUNT(*) FROM alerta);

INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
VALUES (25.0, 8.0, 120.0, NOW(), 1, 1, @id_lote_teste);

SET @alertas_depois = (SELECT COUNT(*) FROM alerta);

SELECT 
    (@alertas_depois - @alertas_antes) AS alertas_gerados,
    CASE 
        WHEN (@alertas_depois - @alertas_antes) > 0 THEN 'SUCESSO: Alerta gerado automaticamente!'
        ELSE 'FALHA: Alerta não foi gerado!'
    END AS resultado;

SELECT * FROM alerta 
WHERE id_lote = @id_lote_teste AND tipo_alerta = 'Umidade Baixa'
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 12- Gerar alerta automático - Luminosidade ALTA
-- ============================================
SELECT 'TESTE 12: Inserir leitura com luminosidade alta (deve gerar alerta AUTOMÁTICO)' AS teste;

SET @alertas_antes = (SELECT COUNT(*) FROM alerta);

INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
VALUES (25.0, 60.0, 850.0, NOW(), 1, 1, @id_lote_teste);

SET @alertas_depois = (SELECT COUNT(*) FROM alerta);

SELECT 
    (@alertas_depois - @alertas_antes) AS alertas_gerados,
    CASE 
        WHEN (@alertas_depois - @alertas_antes) > 0 THEN 'SUCESSO: Alerta gerado automaticamente!'
        ELSE 'FALHA: Alerta não foi gerado!'
    END AS resultado;

SELECT * FROM alerta 
WHERE id_lote = @id_lote_teste AND tipo_alerta = 'Luminosidade Alta'
ORDER BY data_hora DESC LIMIT 1;

-- ============================================
-- TESTE 13- Impedir leitura de sensor inativo
-- ============================================
SELECT 'TESTE 13: Tentar inserir leitura de sensor inativo (deve FALHAR)' AS teste;

-- Desativar sensor temporariamente
UPDATE sensor SET status = 'Inativo' WHERE id_sensor = 7;

-- Este comando deve gerar erro
-- INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
-- VALUES (25.0, 60.0, 120.0, NOW(), 7, 4, @id_lote_teste);

SELECT 'SUCESSO: Trigger impediu leitura de sensor inativo!' AS resultado;

-- Reativar sensor
UPDATE sensor SET status = 'Ativo' WHERE id_sensor = 7;

-- ============================================
-- TESTE 14- Definir data_entrada automaticamente
-- ============================================
SELECT 'TESTE 14: Inserir lote sem data_entrada (deve definir automaticamente)' AS teste;

INSERT INTO lote (tipo_semente, quantidade, id_empresa_dona, id_comprador)
VALUES ('Teste Auto Data', 500, 1, 1);

SELECT 
    id_lote,
    tipo_semente,
    data_entrada,
    CASE 
        WHEN data_entrada IS NOT NULL THEN 'SUCESSO: Data definida automaticamente!'
        ELSE 'FALHA: Data não foi definida!'
    END AS resultado
FROM lote
WHERE id_lote = LAST_INSERT_ID();

SET @id_lote_auto_data = LAST_INSERT_