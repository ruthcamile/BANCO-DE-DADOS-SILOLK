-- ============================================
-- SCRIPT DE CONSULTAS (DQL) - SiloLK
-- CONSULTAS SELECT COM JOIN E SUBSELECT
-- ============================================

USE SiloLK;

-- ============================================
-- CONSULTAS DE MONITORAMENTO E ALERTAS
-- ============================================

-- 1️ ALERTAS CRÍTICOS POR LOTE -- TESTADO (ruth)
-- Objetivo: Identificar todos os alertas críticos associados a cada lote, 
-- incluindo informações do comprador e empresa responsável
SELECT -- FUNCIONANDO (ruth)
    l.id_lote,
    l.tipo_semente,
    c.nome AS comprador,
    e.nome AS empresa_responsavel,
    COUNT(a.id_alerta) AS total_alertas_criticos,
    GROUP_CONCAT(DISTINCT a.tipo_alerta SEPARATOR ', ') AS tipos_alertas
FROM lote l
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
INNER JOIN alerta a ON l.id_lote = a.id_lote
WHERE a.nivel_risco = 'Crítico'
GROUP BY l.id_lote, l.tipo_semente, c.nome, e.nome
ORDER BY total_alertas_criticos DESC;

-- 2️ LEITURAS FORA DO PADRÃO 
-- Objetivo: Encontrar todas as leituras com temperatura acima de 30°C 
-- ou umidade fora da faixa ideal (20-70%)
SELECT -- TESTADO!!(Ruth) 
    lei.id_leitura,
    lei.data_hora,
    l.tipo_semente,
    loc.nome_local,
    s.tipo_sensor,
    lei.valor_temperatura,
    lei.valor_umidade,
    CASE 
        WHEN lei.valor_temperatura > 30 THEN 'Temperatura Alta'
        WHEN lei.valor_umidade < 20 THEN 'Umidade Baixa'
        WHEN lei.valor_umidade > 70 THEN 'Umidade Alta'
        ELSE 'Normal'
    END AS status_condicao
FROM leitura lei
INNER JOIN lote l ON lei.id_lote = l.id_lote
INNER JOIN local_armazenamento loc ON lei.id_local = loc.id_local
INNER JOIN sensor s ON lei.id_sensor = s.id_sensor
WHERE lei.valor_temperatura > 30 
   OR lei.valor_umidade < 20 
   OR lei.valor_umidade > 70
ORDER BY lei.data_hora DESC;

-- 3️ HISTÓRICO COMPLETO DE ALERTAS POR LOCAL
-- Objetivo: Ver todos os alertas gerados em cada local de armazenamento
-- com detalhes do sensor e usuário que visualizou
SELECT  -- TESTADO (ruth)
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    a.tipo_alerta,
    a.nivel_risco,
    a.data_hora,
    s.tipo_sensor,
    u.nome AS usuario_visualizou,
    u.cargo
FROM alerta a
INNER JOIN local_armazenamento loc ON a.id_local = loc.id_local
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
INNER JOIN sensor s ON a.id_sensor = s.id_sensor
LEFT JOIN usuario u ON a.id_usuario_visualizou = u.id_usuario
ORDER BY loc.nome_local, a.data_hora DESC;

-- 4️ SENSORES ATIVOS VS INATIVOS POR EMPRESA
-- Objetivo: Verificar o status dos sensores instalados em cada empresa
SELECT -- TESTADO (ruth)
    e.nome AS empresa,
    COUNT(DISTINCT s.id_sensor) AS total_sensores,
    SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) AS sensores_ativos,
    SUM(CASE WHEN s.status = 'Inativo' THEN 1 ELSE 0 END) AS sensores_inativos,
    ROUND(SUM(CASE WHEN s.status = 'Ativo' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS percentual_ativo
FROM empresa e
INNER JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
INNER JOIN sensor s ON loc.id_local = s.id_local
GROUP BY e.nome
ORDER BY sensores_ativos DESC;

-- ============================================
-- CONSULTAS DE RASTREABILIDADE E TRANSPORTE
-- ============================================

-- 5️ RASTREAMENTO COMPLETO DO LOTE
-- Objetivo: Acompanhar toda a jornada de um lote desde entrada até transporte
SELECT -- TESTADO (ruth)
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    l.data_entrada,
    l.data_saida,
    c.nome AS comprador,
    e.nome AS empresa_dona,
    t.origem,
    t.destino,
    t.data_inicio AS inicio_transporte,
    t.data_fim AS fim_transporte,
    loc.nome_local AS veiculo_utilizado
FROM lote l
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
LEFT JOIN transporte t ON l.id_lote = t.id_lote
LEFT JOIN local_armazenamento loc ON t.id_local_veiculo = loc.id_local
ORDER BY l.id_lote, t.data_inicio;

-- 6️ TRANSPORTES EM ANDAMENTO
-- Objetivo: Listar todos os transportes que ainda não foram finalizados
SELECT -- TESTADO, porem sem retorno pois nao tem nenhum 
-- transporte que ainda nao foi finalizado
    t.id_transporte,
    l.tipo_semente,
    l.quantidade,
    t.origem,
    t.destino,
    t.data_inicio,
    loc.nome_local AS veiculo,
    c.nome AS comprador_destino,
    DATEDIFF(NOW(), t.data_inicio) AS dias_em_transito
FROM transporte t
INNER JOIN lote l ON t.id_lote = l.id_lote
INNER JOIN local_armazenamento loc ON t.id_local_veiculo = loc.id_local
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
WHERE t.data_fim IS NULL
ORDER BY dias_em_transito DESC;

-- 7️ HISTÓRICO DE MOVIMENTAÇÕES POR COMPRADOR
-- Objetivo: Ver todos os lotes adquiridos por um comprador e seus transportes
SELECT -- TESTADO (ruth)
    c.nome AS comprador,
    c.contato,
    l.tipo_semente,
    l.quantidade,
    l.data_entrada,
    COUNT(DISTINCT t.id_transporte) AS total_transportes,
    GROUP_CONCAT(DISTINCT t.destino SEPARATOR ' → ') AS rotas
FROM comprador c
INNER JOIN lote l ON c.id_comprador = l.id_comprador
LEFT JOIN transporte t ON l.id_lote = t.id_lote
GROUP BY c.id_comprador, c.nome, c.contato, l.id_lote, l.tipo_semente, l.quantidade, l.data_entrada
ORDER BY c.nome;

-- 8️ VEÍCULOS MAIS UTILIZADOS PARA TRANSPORTE
-- Objetivo: Identificar quais veículos são mais usados e para quais empresas
SELECT -- TESTADO (ruth)
    loc.nome_local AS veiculo,
    e.nome AS empresa_proprietaria,
    COUNT(t.id_transporte) AS total_transportes_realizados,
    SUM(l.quantidade) AS total_kg_transportados,
    AVG(TIMESTAMPDIFF(HOUR, t.data_inicio, t.data_fim)) AS media_horas_transporte
FROM local_armazenamento loc
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
INNER JOIN transporte t ON loc.id_local = t.id_local_veiculo
INNER JOIN lote l ON t.id_lote = l.id_lote
WHERE loc.tipo_local = 'Veículo'
  AND t.data_fim IS NOT NULL
GROUP BY loc.id_local, loc.nome_local, e.nome
ORDER BY total_transportes_realizados DESC;

-- ============================================
-- CONSULTAS DE PRODUÇÃO E ESTOQUE
-- ============================================

-- 9️ LOTES ARMAZENADOS POR TIPO DE SEMENTE
-- Objetivo: Verificar o estoque atual de cada tipo de semente
SELECT -- TESTADO (ruth)
    l.tipo_semente,
    COUNT(l.id_lote) AS total_lotes,
    SUM(l.quantidade) AS quantidade_total_kg,
    AVG(l.quantidade) AS media_por_lote,
    MIN(l.data_entrada) AS lote_mais_antigo,
    MAX(l.data_entrada) AS lote_mais_recente
FROM lote l
WHERE l.data_saida IS NULL
GROUP BY l.tipo_semente
ORDER BY quantidade_total_kg DESC;

-- 10 LOTES COM MAIOR TEMPO DE ARMAZENAMENTO
-- Objetivo: Identificar lotes que estão armazenados há mais tempo
SELECT -- TESTADO (ruth) 
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    l.data_entrada,
    e.nome AS empresa_responsavel,
    DATEDIFF(COALESCE(l.data_saida, NOW()), l.data_entrada) AS dias_armazenado,
    CASE 
        WHEN l.data_saida IS NULL THEN 'Ainda Armazenado'
        ELSE 'Entregue'
    END AS status_lote
FROM lote l
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
ORDER BY dias_armazenado DESC
LIMIT 20;

-- 11 PRODUÇÃO POR EMPRESA E PERÍODO
-- Objetivo: Analisar a produção de cada empresa por ano
SELECT -- TESTADO (ruth) 
    e.nome AS empresa,
    YEAR(l.data_entrada) AS ano,
    COUNT(l.id_lote) AS total_lotes_recebidos,
    SUM(l.quantidade) AS total_kg_recebidos,
    COUNT(DISTINCT l.tipo_semente) AS variedades_diferentes
FROM empresa e
INNER JOIN lote l ON e.id_empresa = l.id_empresa_dona
GROUP BY e.id_empresa, e.nome, YEAR(l.data_entrada)
ORDER BY ano DESC, total_kg_recebidos DESC;

-- 12 LOCAIS COM MAIOR CAPACIDADE UTILIZADA
-- Objetivo: Ver quais locais têm mais lotes e leituras registradas
SELECT -- TESTADO (ruth)
    loc.nome_local,
    loc.tipo_local,
    e.nome AS empresa,
    COUNT(DISTINCT lei.id_lote) AS lotes_diferentes,
    COUNT(lei.id_leitura) AS total_leituras,
    COUNT(DISTINCT s.id_sensor) AS sensores_instalados
FROM local_armazenamento loc
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
LEFT JOIN leitura lei ON loc.id_local = lei.id_local
LEFT JOIN sensor s ON loc.id_local = s.id_local
GROUP BY loc.id_local, loc.nome_local, loc.tipo_local, e.nome
HAVING total_leituras > 0
ORDER BY total_leituras DESC;

-- ============================================
-- CONSULTAS COM SUBSELECT
-- ============================================

-- 13 LOTES COM ALERTAS ACIMA DA MÉDIA
-- Objetivo: Encontrar lotes que geraram mais alertas que a média geral
SELECT -- FUNCIONANDO, não retorna nada, apenas puxa esse dado para consultas futuras (ruth)
    l.id_lote,
    l.tipo_semente,
    c.nome AS comprador,
    COUNT(a.id_alerta) AS total_alertas
FROM lote l
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN alerta a ON l.id_lote = a.id_lote
GROUP BY l.id_lote, l.tipo_semente, c.nome
HAVING COUNT(a.id_alerta) > (
    SELECT AVG(alerta_count) 
    FROM (
        SELECT COUNT(*) AS alerta_count 
        FROM alerta 
        GROUP BY id_lote
    ) AS subquery
)
ORDER BY total_alertas DESC;

-- 14 EMPRESAS COM MAIOR NÚMERO DE ALERTAS CRÍTICOS
-- Objetivo: Ranking de empresas por alertas críticos, comparando com a média
SELECT -- FUNCIONANDO (ruth)
    e.nome AS empresa,
    COUNT(a.id_alerta) AS alertas_criticos,
    (SELECT AVG(alert_count) 
     FROM (
         SELECT COUNT(*) AS alert_count 
         FROM alerta a2 
         INNER JOIN local_armazenamento loc2 ON a2.id_local = loc2.id_local
         WHERE a2.nivel_risco = 'Crítico'
         GROUP BY loc2.id_empresa
     ) AS avg_calc
    ) AS media_alertas_criticos,
    COUNT(a.id_alerta) - (SELECT AVG(alert_count) 
     FROM (
         SELECT COUNT(*) AS alert_count 
         FROM alerta a2 
         INNER JOIN local_armazenamento loc2 ON a2.id_local = loc2.id_local
         WHERE a2.nivel_risco = 'Crítico'
         GROUP BY loc2.id_empresa
     ) AS avg_calc
    ) AS diferenca_da_media
FROM empresa e
INNER JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
INNER JOIN alerta a ON loc.id_local = a.id_local
WHERE a.nivel_risco = 'Crítico'
GROUP BY e.id_empresa, e.nome
ORDER BY alertas_criticos DESC;

-- 1️5 SENSORES QUE MAIS GERARAM ALERTAS
-- Objetivo: Identificar sensores problemáticos que geram muitos alertas
SELECT  -- FUNCIONANDO, mas não retorna nada, não temos no momento sensores problematicos (ruth)
    s.id_sensor,
    s.tipo_sensor,
    loc.nome_local,
    e.nome AS empresa,
    COUNT(a.id_alerta) AS total_alertas_gerados
FROM sensor s
INNER JOIN local_armazenamento loc ON s.id_local = loc.id_local
INNER JOIN empresa e ON loc.id_empresa = e.id_empresa
INNER JOIN alerta a ON s.id_sensor = a.id_sensor
WHERE s.id_sensor IN (
    SELECT id_sensor 
    FROM alerta 
    GROUP BY id_sensor 
    HAVING COUNT(*) >= 2
)
GROUP BY s.id_sensor, s.tipo_sensor, loc.nome_local, e.nome
ORDER BY total_alertas_gerados DESC;

-- 1️6 COMPRADORES COM MAIOR VOLUME DE COMPRAS
-- Objetivo: Ranking dos maiores compradores por quantidade e valor
SELECT -- FUNCIONANDO (ruth)
    c.nome AS comprador,
    c.documento,
    COUNT(l.id_lote) AS total_lotes_comprados,
    SUM(l.quantidade) AS total_kg_comprados,
    GROUP_CONCAT(DISTINCT l.tipo_semente ORDER BY l.tipo_semente SEPARATOR ', ') AS tipos_sementes
FROM comprador c
INNER JOIN lote l ON c.id_comprador = l.id_comprador
WHERE c.id_comprador IN (
    SELECT id_comprador 
    FROM lote 
    GROUP BY id_comprador 
    HAVING SUM(quantidade) > 3000
)
GROUP BY c.id_comprador, c.nome, c.documento
ORDER BY total_kg_comprados DESC;

-- ============================================
-- CONSULTAS ANALÍTICAS AVANÇADAS
-- ============================================

-- 1️8 ANÁLISE DE CONDIÇÕES AMBIENTAIS POR TIPO DE SEMENTE
-- Objetivo: Ver as médias de temperatura e umidade para cada tipo de semente
SELECT -- FUNCIONANDO, (ruth)
    l.tipo_semente,
    COUNT(DISTINCT l.id_lote) AS total_lotes,
    COUNT(lei.id_leitura) AS total_leituras,
    ROUND(AVG(lei.valor_temperatura), 2) AS temp_media,
    ROUND(MIN(lei.valor_temperatura), 2) AS temp_minima,
    ROUND(MAX(lei.valor_temperatura), 2) AS temp_maxima,
    ROUND(AVG(lei.valor_umidade), 2) AS umidade_media,
    ROUND(MIN(lei.valor_umidade), 2) AS umidade_minima,
    ROUND(MAX(lei.valor_umidade), 2) AS umidade_maxima
FROM lote l
INNER JOIN leitura lei ON l.id_lote = lei.id_lote
GROUP BY l.tipo_semente
ORDER BY l.tipo_semente;

-- 1️8 USUÁRIOS MAIS ATIVOS NO MONITORAMENTO
-- Objetivo: Ver quais usuários mais visualizaram alertas
SELECT -- FUNCIONANDO (ruth)
    u.nome AS usuario,
    u.cargo,
    e.nome AS empresa,
    COUNT(DISTINCT a.id_alerta) AS alertas_visualizados,
    COUNT(DISTINCT a.id_lote) AS lotes_monitorados,
    GROUP_CONCAT(DISTINCT a.nivel_risco ORDER BY a.nivel_risco SEPARATOR ', ') AS niveis_risco_tratados
FROM usuario u
INNER JOIN empresa e ON u.id_empresa = e.id_empresa
INNER JOIN alerta a ON u.id_usuario = a.id_usuario_visualizou
GROUP BY u.id_usuario, u.nome, u.cargo, e.nome
ORDER BY alertas_visualizados DESC;

-- 1️9 COMPARATIVO DE DESEMPENHO ENTRE EMPRESAS
-- Objetivo: Comparar indicadores-chave entre as empresas
SELECT -- FUNCIONANADO, (ruth)
    e.nome AS empresa,
    e.tipo AS tipo_empresa,
    COUNT(DISTINCT l.id_lote) AS total_lotes,
    SUM(l.quantidade) AS total_kg,
    COUNT(DISTINCT loc.id_local) AS total_locais,
    COUNT(DISTINCT s.id_sensor) AS total_sensores,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    COUNT(DISTINCT t.id_transporte) AS total_transportes,
    ROUND(COUNT(DISTINCT a.id_alerta) * 1.0 / NULLIF(COUNT(DISTINCT l.id_lote), 0), 2) AS alertas_por_lote
FROM empresa e
LEFT JOIN lote l ON e.id_empresa = l.id_empresa_dona
LEFT JOIN local_armazenamento loc ON e.id_empresa = loc.id_empresa
LEFT JOIN sensor s ON loc.id_local = s.id_local
LEFT JOIN alerta a ON loc.id_local = a.id_local
LEFT JOIN transporte t ON l.id_lote = t.id_lote
GROUP BY e.id_empresa, e.nome, e.tipo
ORDER BY total_kg DESC;

-- 20 EFICIÊNCIA DE TRANSPORTE POR ROTA
-- Objetivo: Analisar tempos médios e volumes por rota de transporte
SELECT -- FUNCIONANDO (ruth)
    CONCAT(t.origem, ' → ', t.destino) AS rota,
    COUNT(t.id_transporte) AS viagens_realizadas,
    SUM(l.quantidade) AS total_kg_transportados,
    AVG(l.quantidade) AS media_kg_por_viagem,
    AVG(TIMESTAMPDIFF(HOUR, t.data_inicio, t.data_fim)) AS media_horas_viagem,
    GROUP_CONCAT(DISTINCT l.tipo_semente ORDER BY l.tipo_semente SEPARATOR ', ') AS tipos_sementes
FROM transporte t
INNER JOIN lote l ON t.id_lote = l.id_lote
WHERE t.data_fim IS NOT NULL
GROUP BY t.origem, t.destino
HAVING viagens_realizadas >= 1
ORDER BY viagens_realizadas DESC, total_kg_transportados DESC;

-- 2️1 LOTES SEM LEITURAS RECENTES (POSSÍVEL PROBLEMA)
-- Objetivo: Identificar lotes sem monitoramento nos últimos 30 dias
SELECT -- FUNCIONANDO (ruth)
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    e.nome AS empresa,
    c.nome AS comprador,
    MAX(lei.data_hora) AS ultima_leitura,
    DATEDIFF(NOW(), MAX(lei.data_hora)) AS dias_sem_leitura
FROM lote l
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN leitura lei ON l.id_lote = lei.id_lote
WHERE l.data_saida IS NULL
GROUP BY l.id_lote, l.tipo_semente, l.quantidade, e.nome, c.nome
HAVING MAX(lei.data_hora) < DATE_SUB(NOW(), INTERVAL 30 DAY) 
    OR MAX(lei.data_hora) IS NULL
ORDER BY dias_sem_leitura DESC;

-- 2️2 ANÁLISE DE LUMINOSIDADE POR TIPO DE LOCAL
-- Objetivo: Ver se os níveis de luminosidade estão adequados por tipo de local
SELECT -- FUNCIONANADO (ruth)
    loc.tipo_local,
    COUNT(DISTINCT loc.id_local) AS total_locais,
    COUNT(lei.id_leitura) AS total_leituras,
    ROUND(AVG(lei.valor_luminosidade), 2) AS luminosidade_media,
    ROUND(MIN(lei.valor_luminosidade), 2) AS luminosidade_minima,
    ROUND(MAX(lei.valor_luminosidade), 2) AS luminosidade_maxima,
    SUM(CASE WHEN lei.valor_luminosidade > 500 THEN 1 ELSE 0 END) AS leituras_alta_luminosidade
FROM local_armazenamento loc
INNER JOIN leitura lei ON loc.id_local = lei.id_local
WHERE lei.valor_luminosidade IS NOT NULL
GROUP BY loc.tipo_local
ORDER BY luminosidade_media DESC;

-- 23 RELATÓRIO DE AUDITORIA COMPLETO POR LOTE
-- Objetivo: Gerar relatório completo para auditoria de qualquer lote
SELECT -- FUNCIONANDO (ruth)
    l.id_lote,
    l.tipo_semente,
    l.quantidade,
    l.data_entrada,
    l.data_saida,
    e.nome AS empresa_dona,
    c.nome AS comprador,
    c.documento,
    COUNT(DISTINCT lei.id_leitura) AS total_leituras,
    COUNT(DISTINCT a.id_alerta) AS total_alertas,
    COUNT(DISTINCT t.id_transporte) AS total_transportes,
    GROUP_CONCAT(DISTINCT a.tipo_alerta ORDER BY a.tipo_alerta SEPARATOR ', ') AS tipos_alertas_gerados,
    GROUP_CONCAT(DISTINCT CONCAT(t.origem, ' → ', t.destino) SEPARATOR ' | ') AS historico_transportes
FROM lote l
INNER JOIN empresa e ON l.id_empresa_dona = e.id_empresa
INNER JOIN comprador c ON l.id_comprador = c.id_comprador
LEFT JOIN leitura lei ON l.id_lote = lei.id_lote
LEFT JOIN alerta a ON l.id_lote = a.id_lote
LEFT JOIN transporte t ON l.id_lote = t.id_lote
GROUP BY l.id_lote, l.tipo_semente, l.quantidade, l.data_entrada, l.data_saida, 
         e.nome, c.nome, c.documento
ORDER BY l.id_lote;

-- ============================================
-- FIM DAS CONSULTAS 
-- ============================================