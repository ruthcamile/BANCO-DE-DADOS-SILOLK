-- ============================================
-- SCRIPT DE CRIAÇÃO DE TRIGGERS - SiloLK
-- TRIGGERS PARA AUTOMAÇÃO E VALIDAÇÃO
-- ============================================

USE SiloLK;

-- Alterar o delimitador para criar triggers
DELIMITER $$

-- ============================================
-- TRIGGERS DE VALIDAÇÃO E INTEGRIDADE
-- ============================================

-- TRIGGER 1️ - Validar quantidade do lote antes de inserir
-- Objetivo: Garantir que quantidade seja sempre positiva
DROP TRIGGER IF EXISTS trg_validar_quantidade_lote_insert$$
CREATE TRIGGER trg_validar_quantidade_lote_insert -- ATIVA (ruth)
BEFORE INSERT ON lote
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: A quantidade do lote deve ser maior que zero!';
    END IF;
    
    IF NEW.tipo_semente IS NULL OR TRIM(NEW.tipo_semente) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: O tipo de semente é obrigatório!';
    END IF;
END$$

-- TRIGGER 2️ - Validar quantidade do lote antes de atualizar
-- Objetivo: Garantir que quantidade não seja alterada para valor inválido
DROP TRIGGER IF EXISTS trg_validar_quantidade_lote_update$$
CREATE TRIGGER trg_validar_quantidade_lote_update -- ATIVA (ruth)
BEFORE UPDATE ON lote
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: A quantidade do lote deve ser maior que zero!';
    END IF;
    
    -- Impedir alteração de data_entrada
    IF NEW.data_entrada != OLD.data_entrada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: A data de entrada não pode ser alterada!';
    END IF;
END$$

-- TRIGGER 3️ - Validar datas de transporte
-- Objetivo: Garantir que data_fim seja posterior a data_inicio
DROP TRIGGER IF EXISTS trg_validar_datas_transporte$$
CREATE TRIGGER trg_validar_datas_transporte -- ATIVA (ruth)
BEFORE UPDATE ON transporte
FOR EACH ROW
BEGIN
    IF NEW.data_fim IS NOT NULL AND NEW.data_fim < NEW.data_inicio THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Data de término não pode ser anterior à data de início!';
    END IF;
END$$

-- TRIGGER 4️ - Validar tipo de local para transporte
-- Objetivo: Garantir que apenas veículos sejam usados em transportes
DROP TRIGGER IF EXISTS trg_validar_veiculo_transporte$$
CREATE TRIGGER trg_validar_veiculo_transporte -- ATIVA (ruth)
BEFORE INSERT ON transporte
FOR EACH ROW
BEGIN
    DECLARE v_tipo_local VARCHAR(100);
    
    SELECT tipo_local INTO v_tipo_local
    FROM local_armazenamento
    WHERE id_local = NEW.id_local_veiculo;
    
    IF v_tipo_local != 'Veículo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Apenas locais do tipo Veículo podem ser usados em transportes!';
    END IF;
END$$

-- ============================================
-- TRIGGERS DE GERAÇÃO AUTOMÁTICA DE ALERTAS
-- ============================================

-- TRIGGER 5️ - Gerar alerta automático ao inserir leitura com temperatura fora do padrão
-- Objetivo: Criar alerta quando temperatura estiver fora dos limites (10-30°C)
DROP TRIGGER IF EXISTS trg_gerar_alerta_temperatura$$
CREATE TRIGGER trg_gerar_alerta_temperatura -- ATIVA (ruth)
AFTER INSERT ON leitura
FOR EACH ROW
BEGIN
    DECLARE v_tipo_alerta VARCHAR(255);
    DECLARE v_nivel_risco VARCHAR(50);
    DECLARE v_descricao TEXT;
    
    -- Verificar temperatura alta
    IF NEW.valor_temperatura > 30 THEN
        SET v_tipo_alerta = 'Temperatura Alta';
        
        IF NEW.valor_temperatura > 35 THEN
            SET v_nivel_risco = 'Crítico';
            SET v_descricao = CONCAT('CRÍTICO: Temperatura muito alta detectada: ', NEW.valor_temperatura, '°C. Risco de deterioração das sementes!');
        ELSE
            SET v_nivel_risco = 'Alto';
            SET v_descricao = CONCAT('Temperatura acima do limite recomendado: ', NEW.valor_temperatura, '°C. Recomenda-se resfriamento.');
        END IF;
        
        INSERT INTO alerta (tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou)
        VALUES (v_tipo_alerta, NEW.valor_temperatura, v_descricao, v_nivel_risco, NEW.data_hora, NEW.id_sensor, NEW.id_lote, NEW.id_local, NULL);
    END IF;
    
    -- Verificar temperatura baixa
    IF NEW.valor_temperatura < 10 THEN
        SET v_tipo_alerta = 'Temperatura Baixa';
        
        IF NEW.valor_temperatura < 5 THEN
            SET v_nivel_risco = 'Crítico';
            SET v_descricao = CONCAT('CRÍTICO: Temperatura muito baixa detectada: ', NEW.valor_temperatura, '°C. Risco de danos às sementes!');
        ELSE
            SET v_nivel_risco = 'Médio';
            SET v_descricao = CONCAT('Temperatura abaixo do limite recomendado: ', NEW.valor_temperatura, '°C.');
        END IF;
        
        INSERT INTO alerta (tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou)
        VALUES (v_tipo_alerta, NEW.valor_temperatura, v_descricao, v_nivel_risco, NEW.data_hora, NEW.id_sensor, NEW.id_lote, NEW.id_local, NULL);
    END IF;
END$$

-- TRIGGER 6️ - Gerar alerta automático para umidade fora do padrão
-- Objetivo: Criar alerta quando umidade estiver fora dos limites (20-70%)
DROP TRIGGER IF EXISTS trg_gerar_alerta_umidade$$
CREATE TRIGGER trg_gerar_alerta_umidade -- ATIVA (ruth)
AFTER INSERT ON leitura
FOR EACH ROW
BEGIN
    DECLARE v_tipo_alerta VARCHAR(255);
    DECLARE v_nivel_risco VARCHAR(50);
    DECLARE v_descricao TEXT;
    
    -- Verificar umidade alta
    IF NEW.valor_umidade > 70 THEN
        SET v_tipo_alerta = 'Umidade Alta';
        
        IF NEW.valor_umidade > 85 THEN
            SET v_nivel_risco = 'Crítico';
            SET v_descricao = CONCAT('CRÍTICO: Umidade muito alta detectada: ', NEW.valor_umidade, '%. Alto risco de fungos e deterioração!');
        ELSE
            SET v_nivel_risco = 'Alto';
            SET v_descricao = CONCAT('Umidade acima do limite recomendado: ', NEW.valor_umidade, '%. Risco de desenvolvimento de fungos.');
        END IF;
        
        INSERT INTO alerta (tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou)
        VALUES (v_tipo_alerta, NEW.valor_umidade, v_descricao, v_nivel_risco, NEW.data_hora, NEW.id_sensor, NEW.id_lote, NEW.id_local, NULL);
    END IF;
    
    -- Verificar umidade baixa
    IF NEW.valor_umidade < 20 THEN
        SET v_tipo_alerta = 'Umidade Baixa';
        
        IF NEW.valor_umidade < 10 THEN
            SET v_nivel_risco = 'Alto';
            SET v_descricao = CONCAT('Umidade muito baixa detectada: ', NEW.valor_umidade, '%. Risco de ressecamento das sementes.');
        ELSE
            SET v_nivel_risco = 'Médio';
            SET v_descricao = CONCAT('Umidade abaixo do limite recomendado: ', NEW.valor_umidade, '%.');
        END IF;
        
        INSERT INTO alerta (tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou)
        VALUES (v_tipo_alerta, NEW.valor_umidade, v_descricao, v_nivel_risco, NEW.data_hora, NEW.id_sensor, NEW.id_lote, NEW.id_local, NULL);
    END IF;
END$$

-- TRIGGER 7️ - Gerar alerta automático para luminosidade excessiva
-- Objetivo: Criar alerta quando luminosidade estiver muito alta (> 500 lux)
DROP TRIGGER IF EXISTS trg_gerar_alerta_luminosidade$$
CREATE TRIGGER trg_gerar_alerta_luminosidade -- ATIVA (ruth)
AFTER INSERT ON leitura
FOR EACH ROW
BEGIN
    DECLARE v_tipo_alerta VARCHAR(255);
    DECLARE v_nivel_risco VARCHAR(50);
    DECLARE v_descricao TEXT;
    
    -- Verificar luminosidade alta
    IF NEW.valor_luminosidade > 500 THEN
        SET v_tipo_alerta = 'Luminosidade Alta';
        
        IF NEW.valor_luminosidade > 800 THEN
            SET v_nivel_risco = 'Alto';
            SET v_descricao = CONCAT('Luminosidade excessiva detectada: ', NEW.valor_luminosidade, ' lux. Exposição à luz pode reduzir viabilidade das sementes.');
        ELSE
            SET v_nivel_risco = 'Médio';
            SET v_descricao = CONCAT('Luminosidade acima do recomendado: ', NEW.valor_luminosidade, ' lux. Verificar proteção contra luz.');
        END IF;
        
        INSERT INTO alerta (tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou)
        VALUES (v_tipo_alerta, NEW.valor_luminosidade, v_descricao, v_nivel_risco, NEW.data_hora, NEW.id_sensor, NEW.id_lote, NEW.id_local, NULL);
    END IF;
END$$

-- ============================================
-- TRIGGERS DE AUDITORIA E LOG
-- ============================================

-- Criar tabela de log de auditoria
CREATE TABLE IF NOT EXISTS log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(50),
    operacao VARCHAR(20),
    id_registro INT,
    data_hora DATETIME,
    usuario_sistema VARCHAR(100),
    dados_antigos TEXT,
    dados_novos TEXT
);

-- TRIGGER 8️ - Auditar inserção de lotes
-- Objetivo: Registrar criação de novos lotes para auditoria
DROP TRIGGER IF EXISTS trg_auditar_lote_insert$$
CREATE TRIGGER trg_auditar_lote_insert -- ATIVA (ruth)
AFTER INSERT ON lote
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, operacao, id_registro, data_hora, usuario_sistema, dados_antigos, dados_novos)
    VALUES (
        'lote',
        'INSERT',
        NEW.id_lote,
        NOW(),
        USER(),
        NULL,
        CONCAT('Tipo: ', NEW.tipo_semente, ', Quantidade: ', NEW.quantidade, ' kg, Empresa: ', NEW.id_empresa_dona, ', Comprador: ', NEW.id_comprador)
    );
END$$

-- TRIGGER 9️ - Auditar atualização de lotes
-- Objetivo: Registrar alterações em lotes existentes
DROP TRIGGER IF EXISTS trg_auditar_lote_update$$
CREATE TRIGGER trg_auditar_lote_update -- ATIVA (ruth)
AFTER UPDATE ON lote
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, operacao, id_registro, data_hora, usuario_sistema, dados_antigos, dados_novos)
    VALUES (
        'lote',
        'UPDATE',
        NEW.id_lote,
        NOW(),
        USER(),
        CONCAT('Tipo: ', OLD.tipo_semente, ', Quantidade: ', OLD.quantidade, ', Data Saída: ', COALESCE(OLD.data_saida, 'NULL')),
        CONCAT('Tipo: ', NEW.tipo_semente, ', Quantidade: ', NEW.quantidade, ', Data Saída: ', COALESCE(NEW.data_saida, 'NULL'))
    );
END$$

-- TRIGGER 10 - Auditar deleção de lotes
-- Objetivo: Registrar exclusão de lotes (se permitido)
DROP TRIGGER IF EXISTS trg_auditar_lote_delete$$
CREATE TRIGGER trg_auditar_lote_delete -- ATIVA (ruth)
AFTER DELETE ON lote
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela, operacao, id_registro, data_hora, usuario_sistema, dados_antigos, dados_novos)
    VALUES (
        'lote',
        'DELETE',
        OLD.id_lote,
        NOW(),
        USER(),
        CONCAT('Tipo: ', OLD.tipo_semente, ', Quantidade: ', OLD.quantidade, ' kg'),
        NULL
    );
END$$

-- TRIGGER 1️1 - Auditar mudanças em transportes
-- Objetivo: Registrar início e finalização de transportes
DROP TRIGGER IF EXISTS trg_auditar_transporte_update$$
CREATE TRIGGER trg_auditar_transporte_update -- ATIVA (ruth)
AFTER UPDATE ON transporte
FOR EACH ROW
BEGIN
    IF OLD.data_fim IS NULL AND NEW.data_fim IS NOT NULL THEN
        INSERT INTO log_auditoria (tabela, operacao, id_registro, data_hora, usuario_sistema, dados_antigos, dados_novos)
        VALUES (
            'transporte',
            'FINALIZADO',
            NEW.id_transporte,
            NOW(),
            USER(),
            CONCAT('Origem: ', OLD.origem, ', Destino: ', OLD.destino, ', Início: ', OLD.data_inicio),
            CONCAT('Finalizado em: ', NEW.data_fim, ', Duração: ', TIMESTAMPDIFF(HOUR, OLD.data_inicio, NEW.data_fim), ' horas')
        );
    END IF;
END$$

-- ============================================
-- TRIGGERS DE REGRAS DE NEGÓCIO
-- ============================================

-- TRIGGER 1️2 - Impedir exclusão de lotes com leituras
-- Objetivo: Proteger integridade dos dados impedindo exclusão de lotes com histórico
DROP TRIGGER IF EXISTS trg_impedir_delete_lote_com_leituras$$
CREATE TRIGGER trg_impedir_delete_lote_com_leituras -- ATIVA (ruth)
BEFORE DELETE ON lote
FOR EACH ROW
BEGIN
    DECLARE v_total_leituras INT;
    
    SELECT COUNT(*) INTO v_total_leituras
    FROM leitura
    WHERE id_lote = OLD.id_lote;
    
    IF v_total_leituras > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Não é possível excluir lote que possui leituras registradas!';
    END IF;
END$$

-- TRIGGER 1️3 - Impedir leitura de sensor inativo
-- Objetivo: Garantir que apenas sensores ativos registrem leituras
DROP TRIGGER IF EXISTS trg_validar_sensor_ativo$$
CREATE TRIGGER trg_validar_sensor_ativo -- ATIVA (ruth)
BEFORE INSERT ON leitura
FOR EACH ROW
BEGIN
    DECLARE v_status_sensor VARCHAR(50);
    
    SELECT status INTO v_status_sensor
    FROM sensor
    WHERE id_sensor = NEW.id_sensor;
    
    IF v_status_sensor != 'Ativo' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Não é possível registrar leitura de sensor inativo!';
    END IF;
END$$

-- TRIGGER 14 - Atualizar automaticamente data_entrada ao criar lote
-- Objetivo: Garantir que todo lote tenha data_entrada definida
DROP TRIGGER IF EXISTS trg_definir_data_entrada_lote$$
CREATE TRIGGER trg_definir_data_entrada_lote -- ATIVA (ruth)
BEFORE INSERT ON lote
FOR EACH ROW
BEGIN
    IF NEW.data_entrada IS NULL THEN
        SET NEW.data_entrada = NOW();
    END IF;
END$$

-- TRIGGER 15 - Validar email de usuário
-- Objetivo: Garantir formato válido de email ao cadastrar usuário
DROP TRIGGER IF EXISTS trg_validar_email_usuario$$
CREATE TRIGGER trg_validar_email_usuario -- ATIVA (ruth)
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    IF NEW.email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Email inválido! Formato esperado: exemplo@dominio.com';
    END IF;
    
    IF NEW.senha IS NULL OR LENGTH(NEW.senha) < 6 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO: Senha deve ter no mínimo 6 caracteres!';
    END IF;
END$$

-- Restaurar o delimitador padrão
DELIMITER ;

-- ============================================
-- FIM DO SCRIPT DE CRIAÇÃO DE TRIGGERS
-- Total: 15 Triggers criadas
-- ============================================

-- Verificação das triggers criadas
SELECT 
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    EVENT_OBJECT_TABLE,
    ACTION_TIMING
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'SiloLK'
ORDER BY EVENT_OBJECT_TABLE, ACTION_TIMING, EVENT_MANIPULATION;