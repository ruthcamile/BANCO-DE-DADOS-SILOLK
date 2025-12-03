-- ============================================
-- SCRIPT DE PROCEDURES E FUNÇÕES - SiloLK
-- PROCEDURES E FUNÇÕES COM SP/SQL
-- ============================================

USE SiloLK;

-- Alterar o delimitador para criar procedures e functions
DELIMITER $$

-- ============================================
-- FUNÇÕES (FUNCTIONS)
-- ============================================

-- FUNÇÃO 1️ - Calcular dias de armazenamento de um lote
-- Objetivo: Retornar quantos dias um lote está/esteve armazenado
DROP FUNCTION IF EXISTS fn_dias_armazenamento$$
CREATE FUNCTION fn_dias_armazenamento(p_id_lote INT) -- ATIVA (ruth) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_dias INT;
    DECLARE v_data_entrada DATETIME;
    DECLARE v_data_saida DATETIME;
    
    SELECT data_entrada, data_saida 
    INTO v_data_entrada, v_data_saida
    FROM lote 
    WHERE id_lote = p_id_lote;
    
    SET v_dias = DATEDIFF(COALESCE(v_data_saida, NOW()), v_data_entrada);
    
    RETURN v_dias;
END$$

-- FUNÇÃO 2 - Verificar status de um lote
-- Objetivo: Retornar o status atual do lote (Em Armazenamento, Em Transporte, Entregue)
DROP FUNCTION IF EXISTS fn_status_lote$$
CREATE FUNCTION fn_status_lote(p_id_lote INT) -- ATIVA (ruth)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_data_saida DATETIME;
    DECLARE v_transporte_ativo INT;
    
    SELECT data_saida INTO v_data_saida
    FROM lote WHERE id_lote = p_id_lote;
    
    SELECT COUNT(*) INTO v_transporte_ativo
    FROM transporte 
    WHERE id_lote = p_id_lote AND data_fim IS NULL;
    
    IF v_data_saida IS NOT NULL THEN
        SET v_status = 'Entregue';
    ELSEIF v_transporte_ativo > 0 THEN
        SET v_status = 'Em Transporte';
    ELSE
        SET v_status = 'Em Armazenamento';
    END IF;
    
    RETURN v_status;
END$$

-- FUNÇÃO 3️ - Calcular total de alertas críticos de um lote
-- Objetivo: Contar quantos alertas críticos um lote gerou
DROP FUNCTION IF EXISTS fn_total_alertas_criticos$$
CREATE FUNCTION fn_total_alertas_criticos(p_id_lote INT) -- ATIVA (ruth)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(*) INTO v_total
    FROM alerta
    WHERE id_lote = p_id_lote AND nivel_risco = 'Crítico';
    
    RETURN v_total;
END$$

-- FUNÇÃO 4️ - Calcular temperatura média de um lote
-- Objetivo: Retornar a temperatura média registrada para um lote
DROP FUNCTION IF EXISTS fn_temperatura_media_lote$$
CREATE FUNCTION fn_temperatura_media_lote(p_id_lote INT) -- ATIVA (ruth)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_temp_media DECIMAL(10,2);
    
    SELECT COALESCE(ROUND(AVG(valor_temperatura), 2), 0)
    INTO v_temp_media
    FROM leitura
    WHERE id_lote = p_id_lote;
    
    RETURN v_temp_media;
END$$

-- FUNÇÃO 5️ - Verificar se local precisa de manutenção
-- Objetivo: Analisar se um local tem muitos alertas e precisa de atenção
DROP FUNCTION IF EXISTS fn_local_precisa_manutencao$$
CREATE FUNCTION fn_local_precisa_manutencao(p_id_local INT) -- ATIVA (ruth)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_alertas INT;
    DECLARE v_resultado VARCHAR(20);
    
    SELECT COUNT(*) INTO v_total_alertas
    FROM alerta
    WHERE id_local = p_id_local;
    
    IF v_total_alertas > 5 THEN
        SET v_resultado = 'URGENTE';
    ELSEIF v_total_alertas > 2 THEN
        SET v_resultado = 'ATENÇÃO';
    ELSE
        SET v_resultado = 'OK';
    END IF;
    
    RETURN v_resultado;
END$$

-- FUNÇÃO 6️ - Calcular tempo médio de transporte entre origem e destino
-- Objetivo: Retornar média de horas de transporte para uma rota específica
DROP FUNCTION IF EXISTS fn_tempo_medio_rota$$
CREATE FUNCTION fn_tempo_medio_rota(p_origem VARCHAR(255), p_destino VARCHAR(255)) -- ATIVA (ruth)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_media_horas DECIMAL(10,2);
    
    SELECT COALESCE(AVG(TIMESTAMPDIFF(HOUR, data_inicio, data_fim)), 0)
    INTO v_media_horas
    FROM transporte
    WHERE origem = p_origem 
      AND destino = p_destino 
      AND data_fim IS NOT NULL;
    
    RETURN v_media_horas;
END$$

-- ============================================
-- PROCEDURES (STORED PROCEDURES)
-- ============================================

-- PROCEDURE 1️ - Registrar novo lote no sistema
-- Objetivo: Cadastrar um novo lote com validações
DROP PROCEDURE IF EXISTS sp_registrar_lote$$
CREATE PROCEDURE sp_registrar_lote( -- ATIVA (ruth)
    IN p_tipo_semente VARCHAR(100),
    IN p_quantidade DECIMAL(10,2),
    IN p_id_empresa_dona INT,
    IN p_id_comprador INT,
    OUT p_id_lote_gerado INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_empresa_existe INT;
    DECLARE v_comprador_existe INT;
    
    -- Validações
    SELECT COUNT(*) INTO v_empresa_existe FROM empresa WHERE id_empresa = p_id_empresa_dona;
    SELECT COUNT(*) INTO v_comprador_existe FROM comprador WHERE id_comprador = p_id_comprador;
    
    IF v_empresa_existe = 0 THEN
        SET p_mensagem = 'ERRO: Empresa não encontrada!';
        SET p_id_lote_gerado = NULL;
    ELSEIF v_comprador_existe = 0 THEN
        SET p_mensagem = 'ERRO: Comprador não encontrado!';
        SET p_id_lote_gerado = NULL;
    ELSEIF p_quantidade <= 0 THEN
        SET p_mensagem = 'ERRO: Quantidade deve ser maior que zero!';
        SET p_id_lote_gerado = NULL;
    ELSE
        INSERT INTO lote (tipo_semente, quantidade, data_entrada, data_saida, id_empresa_dona, id_comprador)
        VALUES (p_tipo_semente, p_quantidade, NOW(), NULL, p_id_empresa_dona, p_id_comprador);
        
        SET p_id_lote_gerado = LAST_INSERT_ID();
        SET p_mensagem = CONCAT('Lote registrado com sucesso! ID: ', p_id_lote_gerado);
    END IF;
END$$

-- PROCEDURE 2️ - Registrar leitura de sensor
-- Objetivo: Inserir nova leitura e verificar se está fora dos limites
DROP PROCEDURE IF EXISTS sp_registrar_leitura$$
CREATE PROCEDURE sp_registrar_leitura( -- ATIVA (ruth)
    IN p_id_sensor INT,
    IN p_id_local INT,
    IN p_id_lote INT,
    IN p_temperatura DECIMAL(10,2),
    IN p_umidade DECIMAL(10,2),
    IN p_luminosidade DECIMAL(10,2),
    OUT p_alerta_gerado BOOLEAN,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_sensor_ativo VARCHAR(50);
    
    -- Verificar se sensor está ativo
    SELECT status INTO v_sensor_ativo FROM sensor WHERE id_sensor = p_id_sensor;
    
    IF v_sensor_ativo != 'Ativo' THEN
        SET p_mensagem = 'ERRO: Sensor não está ativo!';
        SET p_alerta_gerado = FALSE;
    ELSE
        -- Inserir leitura
        INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote)
        VALUES (p_temperatura, p_umidade, p_luminosidade, NOW(), p_id_sensor, p_id_local, p_id_lote);
        
        SET p_alerta_gerado = FALSE;
        SET p_mensagem = 'Leitura registrada com sucesso!';
        
        -- Verificar se precisa gerar alerta (será feito por trigger)
        IF p_temperatura > 30 OR p_temperatura < 10 OR p_umidade > 70 OR p_umidade < 20 OR p_luminosidade > 500 THEN
            SET p_alerta_gerado = TRUE;
            SET p_mensagem = CONCAT(p_mensagem, ' ATENÇÃO: Valores fora dos limites!');
        END IF;
    END IF;
END$$

-- PROCEDURE 3️ - Iniciar transporte de lote
-- Objetivo: Registrar início de transporte com validações
DROP PROCEDURE IF EXISTS sp_iniciar_transporte$$
CREATE PROCEDURE sp_iniciar_transporte( -- ATIVA (ruth)
    IN p_id_lote INT,
    IN p_id_local_veiculo INT,
    IN p_origem VARCHAR(255),
    IN p_destino VARCHAR(255),
    OUT p_id_transporte INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_lote_existe INT;
    DECLARE v_veiculo_tipo VARCHAR(100);
    DECLARE v_transporte_ativo INT;
    
    SELECT COUNT(*) INTO v_lote_existe FROM lote WHERE id_lote = p_id_lote;
    SELECT tipo_local INTO v_veiculo_tipo FROM local_armazenamento WHERE id_local = p_id_local_veiculo;
    SELECT COUNT(*) INTO v_transporte_ativo FROM transporte WHERE id_lote = p_id_lote AND data_fim IS NULL;
    
    IF v_lote_existe = 0 THEN
        SET p_mensagem = 'ERRO: Lote não encontrado!';
        SET p_id_transporte = NULL;
    ELSEIF v_veiculo_tipo != 'Veículo' THEN
        SET p_mensagem = 'ERRO: Local informado não é um veículo!';
        SET p_id_transporte = NULL;
    ELSEIF v_transporte_ativo > 0 THEN
        SET p_mensagem = 'ERRO: Lote já está em transporte!';
        SET p_id_transporte = NULL;
    ELSE
        INSERT INTO transporte (data_inicio, data_fim, origem, destino, id_lote, id_local_veiculo)
        VALUES (NOW(), NULL, p_origem, p_destino, p_id_lote, p_id_local_veiculo);
        
        SET p_id_transporte = LAST_INSERT_ID();
        SET p_mensagem = CONCAT('Transporte iniciado com sucesso! ID: ', p_id_transporte);
    END IF;
END$$

-- PROCEDURE 4️ - Finalizar transporte
-- Objetivo: Registrar conclusão do transporte
DROP PROCEDURE IF EXISTS sp_finalizar_transporte$$ 
CREATE PROCEDURE sp_finalizar_transporte( -- ATIVA (ruth)
    IN p_id_transporte INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_transporte_existe INT;
    DECLARE v_data_fim DATETIME;
    
    SELECT COUNT(*), data_fim INTO v_transporte_existe, v_data_fim
    FROM transporte 
    WHERE id_transporte = p_id_transporte;
    
    IF v_transporte_existe = 0 THEN
        SET p_mensagem = 'ERRO: Transporte não encontrado!';
    ELSEIF v_data_fim IS NOT NULL THEN
        SET p_mensagem = 'ERRO: Transporte já foi finalizado!';
    ELSE
        UPDATE transporte 
        SET data_fim = NOW() 
        WHERE id_transporte = p_id_transporte;
        
        SET p_mensagem = 'Transporte finalizado com sucesso!';
    END IF;
END$$

-- PROCEDURE 5️ - Marcar alerta como visualizado
-- Objetivo: Registrar que um usuário visualizou um alerta
DROP PROCEDURE IF EXISTS sp_visualizar_alerta$$
CREATE PROCEDURE sp_visualizar_alerta( -- ATIVA (ruth)
    IN p_id_alerta INT,
    IN p_id_usuario INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_alerta_existe INT;
    DECLARE v_usuario_existe INT;
    DECLARE v_ja_visualizado INT;
    
    SELECT COUNT(*) INTO v_alerta_existe FROM alerta WHERE id_alerta = p_id_alerta;
    SELECT COUNT(*) INTO v_usuario_existe FROM usuario WHERE id_usuario = p_id_usuario;
    SELECT COUNT(*) INTO v_ja_visualizado FROM alerta WHERE id_alerta = p_id_alerta AND id_usuario_visualizou IS NOT NULL;
    
    IF v_alerta_existe = 0 THEN
        SET p_mensagem = 'ERRO: Alerta não encontrado!';
    ELSEIF v_usuario_existe = 0 THEN
        SET p_mensagem = 'ERRO: Usuário não encontrado!';
    ELSEIF v_ja_visualizado > 0 THEN
        SET p_mensagem = 'AVISO: Alerta já foi visualizado anteriormente!';
    ELSE
        UPDATE alerta 
        SET id_usuario_visualizou = p_id_usuario 
        WHERE id_alerta = p_id_alerta;
        
        SET p_mensagem = 'Alerta marcado como visualizado!';
    END IF;
END$$

-- PROCEDURE 6️ - Atualizar status do sensor
-- Objetivo: Ativar ou desativar um sensor
DROP PROCEDURE IF EXISTS sp_atualizar_status_sensor$$
CREATE PROCEDURE sp_atualizar_status_sensor( -- ATIVA (ruth)
    IN p_id_sensor INT,
    IN p_novo_status VARCHAR(50),
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_sensor_existe INT;
    
    SELECT COUNT(*) INTO v_sensor_existe FROM sensor WHERE id_sensor = p_id_sensor;
    
    IF v_sensor_existe = 0 THEN
        SET p_mensagem = 'ERRO: Sensor não encontrado!';
    ELSEIF p_novo_status NOT IN ('Ativo', 'Inativo') THEN
        SET p_mensagem = 'ERRO: Status deve ser Ativo ou Inativo!';
    ELSE
        UPDATE sensor 
        SET status = p_novo_status 
        WHERE id_sensor = p_id_sensor;
        
        SET p_mensagem = CONCAT('Status do sensor atualizado para: ', p_novo_status);
    END IF;
END$$

-- PROCEDURE 7️ - Gerar relatório de lote
-- Objetivo: Retornar informações consolidadas de um lote
DROP PROCEDURE IF EXISTS sp_relatorio_lote$$
CREATE PROCEDURE sp_relatorio_lote(IN p_id_lote INT) -- ATIVA (ruth)
BEGIN
    SELECT 
        l.id_lote,
        l.tipo_semente,
        l.quantidade,
        l.data_entrada,
        l.data_saida,
        fn_dias_armazenamento(l.id_lote) AS dias_armazenado,
        fn_status_lote(l.id_lote) AS status_atual,
        e.nome AS empresa,
        c.nome AS comprador,
        COUNT(DISTINCT lei.id_leitura) AS total_leituras,
        fn_temperatura_media_lote(l.id_lote) AS temperatura_media,
        COUNT(DISTINCT a.id_alerta) AS total_alertas,
        fn_total_alertas_criticos(l.id_lote) AS alertas_criticos,
        COUNT(DISTINCT t.id_transporte) AS total_transportes
    FROM lote l
    INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
    INNER JOIN comprador c ON l.id_comprador = c.id_comprador
    LEFT JOIN leitura lei ON l.id_lote = lei.id_lote
    LEFT JOIN alerta a ON l.id_lote = a.id_lote
    LEFT JOIN transporte t ON l.id_lote = t.id_lote
    WHERE l.id_lote = p_id_lote
    GROUP BY l.id_lote, l.tipo_semente, l.quantidade, l.data_entrada, l.data_saida,
             e.nome, c.nome;
END$$

-- PROCEDURE 8️ - Listar alertas pendentes de uma empresa
-- Objetivo: Mostrar todos os alertas não visualizados de uma empresa
DROP PROCEDURE IF EXISTS sp_alertas_pendentes_empresa$$
CREATE PROCEDURE sp_alertas_pendentes_empresa(IN p_id_empresa INT) -- ATIVA (ruth)
BEGIN
    SELECT 
        a.id_alerta,
        a.tipo_alerta,
        a.nivel_risco,
        a.valor_lido,
        a.data_hora,
        DATEDIFF(NOW(), a.data_hora) AS dias_pendente,
        l.tipo_semente,
        loc.nome_local,
        s.tipo_sensor
    FROM alerta a
    INNER JOIN local_armazenamento loc ON a.id_local = loc.id_local
    INNER JOIN lote l ON a.id_lote = l.id_lote
    INNER JOIN sensor s ON a.id_sensor = s.id_sensor
    WHERE loc.id_empresa = p_id_empresa
      AND a.id_usuario_visualizou IS NULL
    ORDER BY a.nivel_risco DESC, a.data_hora DESC;
END$$

-- PROCEDURE 9️ - Calcular estatísticas de um comprador
-- Objetivo: Retornar resumo completo das compras de um comprador
DROP PROCEDURE IF EXISTS sp_estatisticas_comprador$$
CREATE PROCEDURE sp_estatisticas_comprador(IN p_id_comprador INT) -- ATIVA (ruth)
BEGIN
    SELECT 
        c.nome AS comprador,
        c.documento,
        c.contato,
        COUNT(l.id_lote) AS total_lotes,
        SUM(l.quantidade) AS total_kg,
        COUNT(DISTINCT l.tipo_semente) AS variedades,
        MIN(l.data_entrada) AS primeira_compra,
        MAX(l.data_entrada) AS ultima_compra,
        COUNT(DISTINCT t.id_transporte) AS total_transportes,
        COUNT(DISTINCT a.id_alerta) AS alertas_relacionados,
        SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) AS alertas_criticos
    FROM comprador c
    INNER JOIN lote l ON c.id_comprador = l.id_comprador
    LEFT JOIN transporte t ON l.id_lote = t.id_lote
    LEFT JOIN alerta a ON l.id_lote = a.id_lote
    WHERE c.id_comprador = p_id_comprador
    GROUP BY c.id_comprador, c.nome, c.documento, c.contato;
END$$

-- PROCEDURE 10 - Verificar sensores inativos
-- Objetivo: Listar sensores que precisam de manutenção
DROP PROCEDURE IF EXISTS sp_verificar_sensores_inativos$$
CREATE PROCEDURE sp_verificar_sensores_inativos() -- ATIVA (ruth)
BEGIN
    SELECT 
        s.id_sensor,
        s.tipo_sensor,
        s.status,
        loc.nome_local,
        e.nome AS empresa,
        MAX(lei.data_hora) AS ultima_leitura,
        DATEDIFF(NOW(), MAX(lei.data_hora)) AS dias_sem_leitura,
        fn_local_precisa_manutencao(loc.id_local) AS prioridade
    FROM sensor s
    INNER JOIN local_armazenamento loc ON s.id_local = loc.id_local
    INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
    LEFT JOIN leitura lei ON s.id_sensor = lei.id_sensor
    WHERE s.status = 'Inativo' 
       OR DATEDIFF(NOW(), (SELECT MAX(data_hora) FROM leitura WHERE id_sensor = s.id_sensor)) > 7
       OR (SELECT MAX(data_hora) FROM leitura WHERE id_sensor = s.id_sensor) IS NULL
    GROUP BY s.id_sensor, s.tipo_sensor, s.status, loc.nome_local, e.nome, loc.id_local
    ORDER BY prioridade DESC, dias_sem_leitura DESC;
END$$

-- PROCEDURE 1️1 - Finalizar lote (marcar como entregue)
-- Objetivo: Registrar a saída/entrega de um lote
DROP PROCEDURE IF EXISTS sp_finalizar_lote$$
CREATE PROCEDURE sp_finalizar_lote( -- ATIVA (ruth)
    IN p_id_lote INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_lote_existe INT;
    DECLARE v_data_saida DATETIME;
    DECLARE v_transporte_ativo INT;
    
    SELECT COUNT(*), data_saida INTO v_lote_existe, v_data_saida
    FROM lote 
    WHERE id_lote = p_id_lote;
    
    SELECT COUNT(*) INTO v_transporte_ativo
    FROM transporte
    WHERE id_lote = p_id_lote AND data_fim IS NULL;
    
    IF v_lote_existe = 0 THEN
        SET p_mensagem = 'ERRO: Lote não encontrado!';
    ELSEIF v_data_saida IS NOT NULL THEN
        SET p_mensagem = 'ERRO: Lote já foi finalizado!';
    ELSEIF v_transporte_ativo > 0 THEN
        SET p_mensagem = 'ERRO: Lote ainda está em transporte!';
    ELSE
        UPDATE lote 
        SET data_saida = NOW() 
        WHERE id_lote = p_id_lote;
        
        SET p_mensagem = 'Lote finalizado e marcado como entregue!';
    END IF;
END$$

-- PROCEDURE 1️2 - Transferir sensor para outro local
-- Objetivo: Mover um sensor de um local para outro
DROP PROCEDURE IF EXISTS sp_transferir_sensor$$
CREATE PROCEDURE sp_transferir_sensor( -- ATIVA (ruth)
    IN p_id_sensor INT,
    IN p_id_novo_local INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_sensor_existe INT;
    DECLARE v_local_existe INT;
    
    SELECT COUNT(*) INTO v_sensor_existe FROM sensor WHERE id_sensor = p_id_sensor;
    SELECT COUNT(*) INTO v_local_existe FROM local_armazenamento WHERE id_local = p_id_novo_local;
    
    IF v_sensor_existe = 0 THEN
        SET p_mensagem = 'ERRO: Sensor não encontrado!';
    ELSEIF v_local_existe = 0 THEN
        SET p_mensagem = 'ERRO: Local não encontrado!';
    ELSE
        UPDATE sensor 
        SET id_local = p_id_novo_local 
        WHERE id_sensor = p_id_sensor;
        
        SET p_mensagem = 'Sensor transferido com sucesso!';
    END IF;
END$$

-- PROCEDURE 1️3 - Listar lotes com alertas críticos não tratados
-- Objetivo: Identificar lotes que precisam de atenção urgente
DROP PROCEDURE IF EXISTS sp_lotes_atencao_urgente$$
CREATE PROCEDURE sp_lotes_atencao_urgente() -- ATIVA (ruth)
BEGIN
    SELECT 
        l.id_lote,
        l.tipo_semente,
        l.quantidade,
        e.nome AS empresa,
        c.nome AS comprador,
        COUNT(a.id_alerta) AS alertas_criticos_pendentes,
        MAX(a.data_hora) AS ultimo_alerta,
        DATEDIFF(NOW(), MAX(a.data_hora)) AS dias_sem_tratamento,
        GROUP_CONCAT(DISTINCT a.tipo_alerta SEPARATOR ', ') AS tipos_alertas
    FROM lote l
    INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
    INNER JOIN comprador c ON l.id_comprador = c.id_comprador
    INNER JOIN alerta a ON l.id_lote = a.id_lote
    WHERE a.nivel_risco = 'Crítico'
      AND a.id_usuario_visualizou IS NULL
      AND l.data_saida IS NULL
    GROUP BY l.id_lote, l.tipo_semente, l.quantidade, e.nome, c.nome
    HAVING alertas_criticos_pendentes > 0
    ORDER BY alertas_criticos_pendentes DESC, dias_sem_tratamento DESC;
END$$

-- PROCEDURE 14 - Gerar dashboard resumido de uma empresa
-- Objetivo: KPIs principais de uma empresa
DROP PROCEDURE IF EXISTS sp_dashboard_empresa$$
CREATE PROCEDURE sp_dashboard_empresa(IN p_id_empresa INT) -- ATIVA (ruth)
BEGIN
    SELECT 
        e.nome AS empresa,
        COUNT(DISTINCT l.id_lote) AS total_lotes,
        SUM(CASE WHEN l.data_saida IS NULL THEN l.quantidade ELSE 0 END) AS estoque_atual_kg,
        COUNT(DISTINCT CASE WHEN l.data_saida IS NULL THEN l.id_lote END) AS lotes_ativos,
        COUNT(DISTINCT loc.id_local) AS total_locais,
        COUNT(DISTINCT s.id_sensor) AS total_sensores,
        SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) AS sensores_ativos,
        COUNT(DISTINCT a.id_alerta) AS total_alertas,
        SUM(CASE WHEN a.nivel_risco = 'Crítico' AND a.id_usuario_visualizou IS NULL THEN 1 ELSE 0 END) AS alertas_criticos_pendentes,
        COUNT(DISTINCT t.id_transporte) AS total_transportes,
        SUM(CASE WHEN t.data_fim IS NULL THEN 1 ELSE 0 END) AS transportes_em_andamento
    FROM empresa e
    LEFT JOIN lote l ON e.id_empresa = l.id_empresa_dona
    LEFT JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
    LEFT JOIN sensor s ON loc.id_local = s.id_local
    LEFT JOIN alerta a ON loc.id_local = a.id_local
    LEFT JOIN transporte t ON l.id_lote = t.id_lote
    WHERE e.id_empresa = p_id_empresa
    GROUP BY e.id_empresa, e.nome;
END$$

-- Restaurar o delimitador padrão
DELIMITER ;