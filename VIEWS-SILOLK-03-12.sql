-- ============================================
-- SCRIPT DE VIEWS (DDL) - SiloLK
-- VIEWS DOS PRINCIPAIS RELATÓRIOS
-- ============================================

USE SiloLK;

-- ============================================
-- VIEWS DE MONITORAMENTO E ALERTAS
-- ============================================

-- VIEW 1️ - DASHBOARD DE ALERTAS ATIVOS
-- Objetivo: Visão consolidada de todos os alertas para monitoramento em tempo real
CREATE OR REPLACE VIEW vw_dashboard_alertas AS
SELECT -- FUNCIONANDO (ruth)
    a.id_alerta,
    a.tipo_alerta,
    a.nivel_risco,
    a.valor_lido,
    a.data_hora,
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    s.tipo_sensor,
    s.status AS status_sensor,
    u.nome AS visualizado_por,
    u.cargo,
    CASE 
        WHEN u.id_usuario IS NOT NULL THEN 'Visualizado'
        ELSE 'Pendente'
    END AS status_visualizacao,
    DATEDIFF(NOW(), a.data_hora) AS dias_desde_alerta
FROM alerta a
INNER JOIN lote l ON a.id_lote = l.id_lote
INNER JOIN local_armazenamento loc ON a.id_local = loc.id_local
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
INNER JOIN sensor s ON a.id_sensor = s.id_sensor
LEFT JOIN usuario u ON a.id_usuario_visualizou = u.id_usuario
ORDER BY a.data_hora DESC;

-- VIEW 2️ - CONDIÇÕES AMBIENTAIS ATUAIS
-- Objetivo: Última leitura de cada sensor para monitoramento em tempo real
CREATE OR REPLACE VIEW vw_condicoes_ambientais_atuais AS
SELECT -- FUNCIONANDO (ruth)
    s.id_sensor,
    s.tipo_sensor,
    s.status,
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    l.id_lote,
    l.tipo_semente,
    lei.valor_temperatura,
    lei.valor_umidade,
    lei.valor_luminosidade,
    lei.data_hora AS ultima_leitura,
    CASE 
        WHEN lei.valor_temperatura > 30 THEN 'Temperatura Alta'
        WHEN lei.valor_temperatura < 10 THEN 'Temperatura Baixa'
        WHEN lei.valor_umidade > 70 THEN 'Umidade Alta'
        WHEN lei.valor_umidade < 20 THEN 'Umidade Baixa'
        WHEN lei.valor_luminosidade > 500 THEN 'Luminosidade Alta'
        ELSE 'Normal'
    END AS status_condicao
FROM sensor s
INNER JOIN local_armazenamento loc ON s.id_local = loc.id_local
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
INNER JOIN leitura lei ON s.id_sensor = lei.id_sensor
INNER JOIN lote l ON lei.id_lote = l.id_lote
WHERE lei.data_hora = (
    SELECT MAX(lei2.data_hora)
    FROM leitura lei2
    WHERE lei2.id_sensor = s.id_sensor
)
ORDER BY lei.data_hora DESC;

-- ============================================
-- VIEWS DE RASTREABILIDADE
-- ============================================

-- VIEW 3️ - RASTREABILIDADE COMPLETA DE LOTES
-- Objetivo: Visão completa da jornada de cada lote do sistema
CREATE OR REPLACE VIEW vw_rastreabilidade_lotes AS
SELECT -- FUNCIONANDO (ruth)
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    l.data_entrada,
    l.data_saida,
    DATEDIFF(COALESCE(l.data_saida, NOW()), l.data_entrada) AS dias_no_sistema,
    e.nome AS empresa_dona,
    e.tipo AS tipo_empresa,
    c.nome AS comprador,
    c.documento,
    c.contato,
    COUNT(DISTINCT lei.id_leitura) AS total_leituras,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    COUNT(DISTINCT t.id_transporte) AS total_transportes,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media,
    CASE 
        WHEN l.data_saida IS NULL THEN 'Em Armazenamento'
        WHEN EXISTS(SELECT 1 FROM transporte t2 WHERE t2.id_lote = l.id_lote AND t2.data_fim IS NULL) THEN 'Em Transporte'
        ELSE 'Entregue'
    END AS status_atual
FROM lote l
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN leitura lei ON l.id_lote = lei.id_lote
LEFT JOIN alerta a ON l.id_lote = a.id_lote
LEFT JOIN transporte t ON l.id_lote = t.id_lote
GROUP BY l.id_lote, l.tipo_semente, l.quantidade, l.data_entrada, l.data_saida,
         e.nome, e.tipo, c.nome, c.documento, c.contato
ORDER BY l.data_entrada DESC;

-- VIEW 4️ - TRANSPORTES EM ANDAMENTO
-- Objetivo: Monitorar todos os transportes ativos no momento
CREATE OR REPLACE VIEW vw_transportes_ativos AS
SELECT -- FUNCIONANDO (ruth)
    t.id_transporte,
    t.data_inicio,
    t.origem,
    t.destino,
    DATEDIFF(NOW(), t.data_inicio) AS dias_em_transito,
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    loc.nome_local AS veiculo,
    e.nome AS empresa_responsavel,
    c.nome AS comprador_destino,
    c.contato,
    COUNT(DISTINCT lei.id_leitura) AS leituras_durante_transporte,
    COUNT(DISTINCT a.id_alerta) AS alertas_durante_transporte,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media_transporte,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media_transporte
FROM transporte t
INNER JOIN lote l ON t.id_lote = l.id_lote
INNER JOIN local_armazenamento loc ON t.id_local_veiculo = loc.id_local
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN leitura lei ON l.id_lote = lei.id_lote 
    AND lei.data_hora BETWEEN t.data_inicio AND COALESCE(t.data_fim, NOW())
LEFT JOIN alerta a ON l.id_lote = a.id_lote 
    AND a.data_hora BETWEEN t.data_inicio AND COALESCE(t.data_fim, NOW())
WHERE t.data_fim IS NULL
GROUP BY t.id_transporte, t.data_inicio, t.origem, t.destino,
         l.id_lote, l.tipo_semente, l.quantidade, loc.nome_local,
         e.nome, c.nome, c.contato
ORDER BY dias_em_transito DESC;

-- ============================================
-- VIEWS DE GESTÃO E ESTOQUE
-- ============================================

-- VIEW 5️ - ESTOQUE ATUAL POR EMPRESA
-- Objetivo: Visão do estoque disponível em cada empresa
CREATE OR REPLACE VIEW vw_estoque_atual AS
SELECT -- FUNCIONANDO (ruth)
    e.id_empresa,
    e.nome AS empresa,
    e.tipo AS tipo_empresa,
    l.tipo_semente,
    COUNT(l.id_lote) AS total_lotes,
    SUM(l.quantidade) AS quantidade_total_kg,
    AVG(l.quantidade) AS media_kg_por_lote,
    MIN(l.data_entrada) AS lote_mais_antigo,
    MAX(l.data_entrada) AS lote_mais_recente,
    COUNT(DISTINCT loc.id_local) AS locais_utilizados,
    COUNT(DISTINCT s.id_sensor) AS sensores_ativos
FROM empresa e
INNER JOIN lote l ON e.id_empresa = l.id_empresa_dona
LEFT JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
LEFT JOIN sensor s ON loc.id_local = s.id_local AND s.status = 'Ativo'
WHERE l.data_saida IS NULL
GROUP BY e.id_empresa, e.nome, e.tipo, l.tipo_semente
ORDER BY e.nome, quantidade_total_kg DESC;

-- VIEW 6️⃣ - PERFORMANCE DE LOCAIS DE ARMAZENAMENTO
-- Objetivo: Analisar a eficiência e utilização de cada local
CREATE OR REPLACE VIEW vw_performance_locais AS
SELECT -- FUNCIONANDO (ruth)
    loc.id_local,
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    COUNT(DISTINCT lei.id_lote) AS lotes_armazenados,
    COUNT(DISTINCT s.id_sensor) AS total_sensores,
    SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) AS sensores_ativos,
    COUNT(lei.id_leitura) AS total_leituras,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) AS alertas_criticos,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media,
    ROUND(AVG(lei.valor_luminosidade), 2) AS luminosidade_media,
    CASE 
        WHEN COUNT(DISTINCT a.id_alerta) = 0 THEN 'Excelente'
        WHEN COUNT(DISTINCT a.id_alerta) <= 2 THEN 'Bom'
        WHEN COUNT(DISTINCT a.id_alerta) <= 5 THEN 'Regular'
        ELSE 'Crítico'
    END AS avaliacao_performance
FROM local_armazenamento loc
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
LEFT JOIN sensor s ON loc.id_local = s.id_local
LEFT JOIN leitura lei ON loc.id_local = lei.id_local
LEFT JOIN alerta a ON loc.id_local = a.id_local
GROUP BY loc.id_local, loc.nome_local, loc.tipo_local, e.nome
ORDER BY total_alertas ASC, total_leituras DESC;

-- ============================================
-- VIEWS DE ANÁLISE E RELATÓRIOS
-- ============================================

-- VIEW 7️ - RANKING DE COMPRADORES
-- Objetivo: Analisar o perfil e volume de compras de cada comprador
CREATE OR REPLACE VIEW vw_ranking_compradores AS
SELECT -- FUNCIONANDO (ruth)
    c.id_comprador,
    c.nome AS comprador,
    c.documento,
    c.contato,
    COUNT(l.id_lote) AS total_lotes_comprados,
    SUM(l.quantidade) AS total_kg_comprados,
    COUNT(DISTINCT l.tipo_semente) AS variedades_compradas,
    COUNT(DISTINCT l.id_empresa_dona) AS empresas_fornecedoras,
    MIN(l.data_entrada) AS primeira_compra,
    MAX(l.data_entrada) AS ultima_compra,
    DATEDIFF(MAX(l.data_entrada), MIN(l.data_entrada)) AS dias_como_cliente,
    COUNT(DISTINCT t.id_transporte) AS total_transportes,
    COUNT(DISTINCT a.id_alerta) AS alertas_relacionados,
    ROUND(SUM(l.quantidade) / COUNT(l.id_lote), 2) AS media_kg_por_compra
FROM comprador c
INNER JOIN lote l ON c.id_comprador = l.id_comprador
LEFT JOIN transporte t ON l.id_lote = t.id_lote
LEFT JOIN alerta a ON l.id_lote = a.id_lote
GROUP BY c.id_comprador, c.nome, c.documento, c.contato
ORDER BY total_kg_comprados DESC;

-- VIEW 8️ - INDICADORES DE QUALIDADE POR TIPO DE SEMENTE
-- Objetivo: Monitorar a qualidade do armazenamento por tipo de semente
CREATE OR REPLACE VIEW vw_qualidade_sementes AS
SELECT -- FUNCIONANDO (ruth)
    l.tipo_semente,
    COUNT(DISTINCT l.id_lote) AS total_lotes,
    SUM(l.quantidade) AS quantidade_total_kg,
    COUNT(DISTINCT lei.id_leitura) AS total_leituras,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media,
    ROUND(STDDEV(lei.valor_temperatura), 2) AS temp_desvio_padrao,
    ROUND(MIN(lei.valor_temperatura), 2) AS temp_minima,
    ROUND(MAX(lei.valor_temperatura), 2) AS temp_maxima,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media,
    ROUND(STDDEV(lei.valor_umidade), 2) AS umidade_desvio_padrao,
    ROUND(MIN(lei.valor_umidade), 2) AS umidade_minima,
    ROUND(MAX(lei.valor_umidade), 2) AS umidade_maxima,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) AS alertas_criticos,
    ROUND(COUNT(DISTINCT a.id_alerta) * 100.0 / COUNT(DISTINCT l.id_lote), 2) AS taxa_alertas_por_lote,
    CASE 
        WHEN COUNT(DISTINCT a.id_alerta) = 0 THEN 'Excelente'
        WHEN COUNT(DISTINCT a.id_alerta) * 100.0 / COUNT(DISTINCT l.id_lote) < 10 THEN 'Muito Bom'
        WHEN COUNT(DISTINCT a.id_alerta) * 100.0 / COUNT(DISTINCT l.id_lote) < 30 THEN 'Bom'
        WHEN COUNT(DISTINCT a.id_alerta) * 100.0 / COUNT(DISTINCT l.id_lote) < 50 THEN 'Regular'
        ELSE 'Necessita Atenção'
    END AS classificacao_qualidade
FROM lote l
LEFT JOIN leitura lei ON l.id_lote = lei.id_lote
LEFT JOIN alerta a ON l.id_lote = a.id_lote
GROUP BY l.tipo_semente
ORDER BY l.tipo_semente;

-- VIEW 9️ - HISTÓRICO DE SENSORES E MANUTENÇÃO
-- Objetivo: Monitorar o desempenho e necessidade de manutenção dos sensores
CREATE OR REPLACE VIEW vw_status_sensores AS
SELECT -- FUNCIONANDO (ruth)
    s.id_sensor,
    s.tipo_sensor,
    s.status,
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    COUNT(lei.id_leitura) AS total_leituras,
    MIN(lei.data_hora) AS primeira_leitura,
    MAX(lei.data_hora) AS ultima_leitura,
    DATEDIFF(NOW(), MAX(lei.data_hora)) AS dias_sem_leitura,
    COUNT(DISTINCT a.id_alerta) AS alertas_gerados,
    ROUND(COUNT(DISTINCT a.id_alerta) * 100.0 / NULLIF(COUNT(lei.id_leitura), 0), 2) AS taxa_alertas,
    CASE 
        WHEN s.status = 'Inativo' THEN 'Desativado - Verificar'
        WHEN DATEDIFF(NOW(), MAX(lei.data_hora)) > 7 THEN 'Sem Leituras Recentes'
        WHEN COUNT(DISTINCT a.id_alerta) * 100.0 / NULLIF(COUNT(lei.id_leitura), 0) > 50 THEN 'Alto Índice de Alertas'
        WHEN COUNT(lei.id_leitura) < 10 THEN 'Poucas Leituras'
        ELSE 'Operando Normalmente'
    END AS diagnostico
FROM sensor s
INNER JOIN local_armazenamento loc ON s.id_local = loc.id_local
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
LEFT JOIN leitura lei ON s.id_sensor = lei.id_sensor
LEFT JOIN alerta a ON s.id_sensor = a.id_sensor
GROUP BY s.id_sensor, s.tipo_sensor, s.status, loc.nome_local, loc.tipo_local, e.nome
ORDER BY dias_sem_leitura DESC, alertas_gerados DESC;

-- VIEW 10 - EFICIÊNCIA DE TRANSPORTES
-- Objetivo: Analisar a performance e eficiência das operações de transporte
CREATE OR REPLACE VIEW vw_analise_transportes AS
SELECT -- FUNCIONANDO (ruth)
    CONCAT(t.origem, ' → ', t.destino) AS rota,
    COUNT(t.id_transporte) AS total_viagens,
    SUM(l.quantidade) AS kg_transportados,
    ROUND(AVG(l.quantidade), 2) AS media_kg_viagem,
    COUNT(DISTINCT loc.id_local) AS veiculos_diferentes,
    COUNT(DISTINCT l.tipo_semente) AS tipos_sementes,
    AVG(TIMESTAMPDIFF(HOUR, t.data_inicio, t.data_fim)) AS media_horas,
    MIN(TIMESTAMPDIFF(HOUR, t.data_inicio, t.data_fim)) AS tempo_minimo,
    MAX(TIMESTAMPDIFF(HOUR, t.data_inicio, t.data_fim)) AS tempo_maximo,
    COUNT(DISTINCT a.id_alerta) AS alertas_em_transporte,
    SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) AS alertas_criticos_transporte,
    CASE 
        WHEN COUNT(DISTINCT a.id_alerta) = 0 THEN 'Excelente'
        WHEN COUNT(DISTINCT a.id_alerta) <= 2 THEN 'Bom'
        WHEN COUNT(DISTINCT a.id_alerta) <= 5 THEN 'Regular'
        ELSE 'Necessita Melhoria'
    END AS avaliacao_rota
FROM transporte t
INNER JOIN lote l ON t.id_lote = l.id_lote
INNER JOIN local_armazenamento loc ON t.id_local_veiculo = loc.id_local
LEFT JOIN alerta a ON l.id_lote = a.id_lote 
    AND a.data_hora BETWEEN t.data_inicio AND COALESCE(t.data_fim, NOW())
WHERE t.data_fim IS NOT NULL
GROUP BY t.origem, t.destino
HAVING total_viagens >= 1
ORDER BY total_viagens DESC, kg_transportados DESC;

-- ============================================
-- VIEWS DE GESTÃO DE USUÁRIOS
-- ============================================

-- VIEW 1️1 - ATIVIDADE DE USUÁRIOS
-- Objetivo: Monitorar a atividade e engajamento dos usuários do sistema
CREATE OR REPLACE VIEW vw_atividade_usuarios AS
SELECT -- FUNCIONANDO (ruth)
    u.id_usuario,
    u.nome AS usuario,
    u.cargo,
    u.email,
    u.nivel_acesso,
    e.nome AS empresa,
    COUNT(DISTINCT a.id_alerta) AS alertas_visualizados,
    COUNT(DISTINCT a.id_lote) AS lotes_monitorados,
    COUNT(DISTINCT CASE WHEN a.nivel_risco = 'Crítico' THEN a.id_alerta END) AS alertas_criticos_tratados,
    MIN(a.data_hora) AS primeiro_acesso_alerta,
    MAX(a.data_hora) AS ultimo_acesso_alerta,
    DATEDIFF(NOW(), MAX(a.data_hora)) AS dias_sem_atividade,
    CASE 
        WHEN COUNT(DISTINCT a.id_alerta) = 0 THEN 'Sem Atividade'
        WHEN DATEDIFF(NOW(), MAX(a.data_hora)) > 30 THEN 'Inativo'
        WHEN DATEDIFF(NOW(), MAX(a.data_hora)) > 7 THEN 'Baixa Atividade'
        ELSE 'Ativo'
    END AS status_atividade
FROM usuario u
INNER JOIN empresa e ON u.id_empresa = e.id_empresa
LEFT JOIN alerta a ON u.id_usuario = a.id_usuario_visualizou
GROUP BY u.id_usuario, u.nome, u.cargo, u.email, u.nivel_acesso, e.nome
ORDER BY alertas_visualizados DESC;

-- VIEW 1️2 - DASHBOARD EXECUTIVO
-- Objetivo: Visão consolidada de KPIs para gestão executiva
CREATE OR REPLACE VIEW vw_dashboard_executivo AS
SELECT -- FUNCIONANDO (ruth)
    e.id_empresa,
    e.nome AS empresa,
    e.tipo AS tipo_empresa,
    COUNT(DISTINCT l.id_lote) AS total_lotes_ativos,
    SUM(CASE WHEN l.data_saida IS NULL THEN l.quantidade ELSE 0 END) AS estoque_kg,
    COUNT(DISTINCT CASE WHEN l.data_saida IS NULL THEN l.id_lote END) AS lotes_em_estoque,
    COUNT(DISTINCT loc.id_local) AS locais_operacionais,
    COUNT(DISTINCT s.id_sensor) AS total_sensores,
    SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) AS sensores_ativos,
    COUNT(DISTINCT t.id_transporte) AS transportes_realizados,
    SUM(CASE WHEN t.data_fim IS NULL THEN 1 ELSE 0 END) AS transportes_em_andamento,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) AS alertas_criticos,
    SUM(CASE WHEN a.id_usuario_visualizou IS NULL THEN 1 ELSE 0 END) AS alertas_pendentes,
    COUNT(DISTINCT u.id_usuario) AS usuarios_cadastrados,
    COUNT(DISTINCT c.id_comprador) AS clientes_ativos,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media_geral,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media_geral,
    CASE 
        WHEN SUM(CASE WHEN a.nivel_risco = 'Crítico' THEN 1 ELSE 0 END) > 5 THEN 'Atenção Requerida'
        WHEN SUM(CASE WHEN a.id_usuario_visualizou IS NULL THEN 1 ELSE 0 END) > 10 THEN 'Alertas Pendentes'
        WHEN SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT s.id_sensor) < 80 THEN 'Verificar Sensores'
        ELSE 'Operação Normal'
    END AS status_operacional
FROM empresa e
LEFT JOIN lote l ON e.id_empresa = l.id_empresa_dona
LEFT JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
LEFT JOIN sensor s ON loc.id_local = s.id_local
LEFT JOIN transporte t ON l.id_lote = t.id_lote
LEFT JOIN alerta a ON loc.id_local = a.id_local
LEFT JOIN usuario u ON e.id_empresa = u.id_empresa
LEFT JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN leitura lei ON loc.id_local = lei.id_local
GROUP BY e.id_empresa, e.nome, e.tipo
ORDER BY total_lotes_ativos DESC;

-- ============================================
-- FIM DAS VIEWS
-- ============================================

-- SCRIPT PARA TESTAR TODAS AS VIEWS
-- Execute os comandos abaixo para verificar se todas as views foram criadas corretamente

SELECT 'vw_dashboard_alertas' AS view_name, COUNT(*) AS total_registros FROM vw_dashboard_alertas
UNION ALL
SELECT 'vw_condicoes_ambientais_atuais', COUNT(*) FROM vw_condicoes_ambientais_atuais
UNION ALL
SELECT 'vw_rastreabilidade_lotes', COUNT(*) FROM vw_rastreabilidade_lotes
UNION ALL
SELECT 'vw_transportes_ativos', COUNT(*) FROM vw_transportes_ativos
UNION ALL
SELECT 'vw_estoque_atual', COUNT(*) FROM vw_estoque_atual
UNION ALL
SELECT 'vw_performance_locais', COUNT(*) FROM vw_performance_locais
UNION ALL
SELECT 'vw_ranking_compradores', COUNT(*) FROM vw_ranking_compradores
UNION ALL
SELECT 'vw_qualidade_sementes', COUNT(*) FROM vw_qualidade_sementes
UNION ALL
SELECT 'vw_status_sensores', COUNT(*) FROM vw_status_sensores
UNION ALL
SELECT 'vw_analise_transportes', COUNT(*) FROM vw_analise_transportes
UNION ALL
SELECT 'vw_atividade_usuarios', COUNT(*) FROM vw_atividade_usuarios
UNION ALL
SELECT 'vw_dashboard_executivo', COUNT(*) FROM vw_dashboard_executivo;