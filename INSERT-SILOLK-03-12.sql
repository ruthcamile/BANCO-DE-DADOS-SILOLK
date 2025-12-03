-- POPULANDO A TABELA 

-- 1) EMPRESA (5 registros)
INSERT INTO empresa (nome, tipo) VALUES
('AgroTech Brasil', 'Produtora'),
('Sementes VerdeVida', 'Armazenadora'),
('Campo Forte LTDA', 'Distribuidora'),
('Silo Master Solutions', 'Armazenadora'),
('AgroNorte Export', 'Exportadora');


-- 2) COMPRADOR (30 registros)
INSERT INTO comprador (nome, documento, contato) VALUES
('João Ferreira', 'CPF 123.456.789-01', '81 98888-1111'),
('Maria Clara Santos', 'CPF 987.654.321-00', '81 99999-2222'),
('Cooperativa AgroSul', 'CNPJ 12.345.678/0001-90', '81 93333-4444'),
('Exportadora TerraBoa', 'CNPJ 98.765.432/0001-55', '81 97777-5555'),
('Lucas Ribeiro', 'CPF 654.321.987-22', '81 94444-6666'),
('Fazenda Primavera', 'CNPJ 22.333.444/0001-20', '81 92222-7777'),
('Indústria BioGrão', 'CNPJ 01.234.567/0001-10', '81 96666-8888'),
('Ana Luiza Campos', 'CPF 321.789.654-99', '81 95555-9999'),
('Cooperativa Vale Verde', 'CNPJ 33.444.555/0001-88', '81 91111-0000'),
('Fazenda Boa Esperança', 'CPF 111.222.333-44', '81 90000-1111'),
('Sementes do Norte', 'CNPJ 44.555.666/0001-77', '81 92222-2222'),
('AgroMercado LTDA', 'CNPJ 55.666.777/0001-66', '81 93333-3333'),
('Grãos & Cia', 'CNPJ 66.777.888/0001-55', '81 94444-4444'),
('Fazenda Três Irmãos', 'CPF 222.333.444-55', '81 95555-5555'),
('Distribuidora CampoVivo', 'CNPJ 77.888.999/0001-44', '81 96666-6666'),
('Cooperativa do Litoral', 'CNPJ 88.999.000/0001-33', '81 97777-7777'),
('Produtora TerraFértil', 'CPF 333.444.555-66', '81 98888-8888'),
('Fazenda São José', 'CPF 444.555.666-77', '81 99999-9999'),
('Sementeira Regional', 'CNPJ 99.000.111/0001-22', '81 91111-2222'),
('AgroEmpório', 'CNPJ 10.111.121/0001-11', '81 92222-3333'),
('Pequenos Produtores Unidos', 'CNPJ 11.222.233/0001-00', '81 93333-4445'),
('Mercado Rural LTDA', 'CNPJ 12.222.244/0001-01', '81 94444-5555'),
('Fazenda Santa Clara', 'CPF 555.666.777-88', '81 95555-6666'),
('Casa de Sementes ALFA', 'CNPJ 13.333.355/0001-02', '81 96666-7777'),
('Armazém Central', 'CNPJ 14.444.466/0001-03', '81 97777-8888'),
('Fazenda Nova Vida', 'CPF 666.777.888-99', '81 98888-9990'),
('Cooperativa Serrana', 'CNPJ 15.555.477/0001-04', '81 99999-0001'),
('Empório Verde', 'CPF 777.888.999-00', '81 91111-3333'),
('AgroDistribui', 'CNPJ 16.666.488/0001-05', '81 92222-4444'),
('Fazenda Vale do Sol', 'CPF 888.999.000-11', '81 93333-5555');


-- 3) LOCAL_ARMAZENAMENTO (30 registros)
-- distribuir entre as 5 empresas (ids 1..5)
INSERT INTO local_armazenamento (nome_local, tipo_local, id_empresa) VALUES
('Silo Central 01', 'Silo', 1),
('Silo Secundário 02', 'Silo', 2),
('Silo Norte 03', 'Silo', 3),
('Silo Especial 04', 'Silo', 4),
('Silo Premium 05', 'Silo', 5),
('Galpão A - Armazenagem', 'Galpão', 1),
('Galpão B - Armazenagem', 'Galpão', 2),
('Armazém Regional 1', 'Armazém', 3),
('Armazém Regional 2', 'Armazém', 4),
('Depósito Frio 1', 'Depósito', 5),
('Caminhão Graneleiro 01', 'Veículo', 1),
('Caminhão Graneleiro 02', 'Veículo', 1),
('Carreta Baú 03', 'Veículo', 2),
('Carreta Tanque 04', 'Veículo', 2),
('Truck Refrigerado 05', 'Veículo', 3),
('Terminal Silo Leste', 'Silo', 3),
('Terminal Silo Oeste', 'Silo', 4),
('Depósito Seco 2', 'Depósito', 2),
('Pátio de Estocagem 1', 'Pátio', 5),
('Pátio de Estocagem 2', 'Pátio', 4),
('Veículo Baú 06', 'Veículo', 5),
('Veículo Graneleiro 07', 'Veículo', 5),
('Doca de Carregamento 01', 'Doca', 1),
('Doca de Carregamento 02', 'Doca', 2),
('Silo Comunitário 01', 'Silo', 3),
('Silo Comunitário 02', 'Silo', 4),
('Armazém Satélite 01', 'Armazém', 5),
('Armazém Satélite 02', 'Armazém', 1),
('Container 01', 'Container', 2),
('Local 30', 'Desconhecido', 1);


-- 4) USUARIO (30 registros)
-- nivel_acesso: criar 10 níveis diferentes, cada um repetido no máximo 3 vezes (10 * 3 = 30)
INSERT INTO usuario (nome, cargo, email, senha, nivel_acesso, id_empresa) VALUES
('Carlos Mendes', 'Gerente de Produção', 'carlos.m@agrotech.com', 'senha123', 'Admin', 1),
('Fernanda Rocha', 'Agrônoma', 'fernanda.r@agrotech.com', 'senha123', 'Operador', 1),
('Paulo Silva', 'Responsável pelo Silo', 'paulo.s@verdevida.com', 'senha123', 'Técnico', 2),

('Mariana Alves', 'Admin da UBS', 'mariana.a@verdevida.com', 'senha123', 'Supervisor', 2),
('Ricardo Gomes', 'Gerente de Produção', 'ricardo.g@campoforte.com', 'senha123', 'Gerente', 3),
('Juliana Castro', 'Agrônoma', 'juliana.c@campoforte.com', 'senha123', 'Auditor', 3),
('Thiago Lima', 'Responsável pelo Silo', 'thiago.l@silomaster.com', 'senha123', 'Motorista', 4),
('Amanda Dias', 'Admin da UBS', 'amanda.d@silomaster.com', 'senha123', 'Cliente', 4),
('Pedro Albuquerque', 'Gerente de Produção', 'pedro.a@agronorte.com', 'senha123', 'Admin', 5),
('Lívia Souza', 'Agrônoma', 'livia.s@agronorte.com', 'senha123', 'Operador', 5),

('Gabriel Torres', 'Auxiliar Técnico', 'gabriel.t@verdevida.com', 'senha123', 'Técnico', 2),
('Bianca Pereira', 'Técnica Operacional', 'bianca.p@agrotech.com', 'senha123', 'Supervisor', 1),
('Marcos Vinicius', 'Analista de Qualidade', 'marcos.v@campoforte.com', 'senha123', 'Gerente', 3),
('Rita Fernandes', 'Coordenadora Logística', 'rita.f@silomaster.com', 'senha123', 'Auditor', 4),
('Diego Carvalho', 'Motorista', 'diego.c@agronorte.com', 'senha123', 'Motorista', 5),
('Vanessa Lima', 'Recepção', 'vanessa.l@agrotech.com', 'senha123', 'Cliente', 1),

('Elias Moreira', 'Técnico de Campo', 'elias.m@verdevida.com', 'senha123', 'Admin', 2),
('Sofia Pereira', 'Engenheira Agrícola', 'sofia.p@campoForte.com', 'senha123', 'Operador', 3),
('Renato Souza', 'Supervisor de Armazém', 'renato.s@silomaster.com', 'senha123', 'Técnico', 4),
('Carla Mota', 'Controladora de Estoque', 'carla.m@agronorte.com', 'senha123', 'Supervisor', 5),

('Bruno Oliveira', 'Motorista', 'bruno.o@agrotech.com', 'senha123', 'Gerente', 1),
('Patrícia Nunes', 'Analista Financeiro', 'patricia.n@verdevida.com', 'senha123', 'Auditor', 2),
('Gustavo Henrique', 'Técnico de Manutenção', 'gustavo.h@campoforte.com', 'senha123', 'Motorista', 3),
('Letícia Ramos', 'Assistente Administrativo', 'leticia.r@silomaster.com', 'senha123', 'Cliente', 4),

('Roberto Pinto', 'Coordenador de Transporte', 'roberto.p@agronorte.com', 'senha123', 'Admin', 5),
('Aline Costa', 'Operadora de Máquinas', 'aline.c@agroNorte.com', 'senha123', 'Operador', 5),
('Fábio Santos', 'Técnico em IoT', 'fabio.s@agrotech.com', 'senha123', 'Técnico', 1),
('Helena Dias', 'Engenheira de Processos', 'helena.d@campoForte.com', 'senha123', 'Supervisor', 3),
('Vitor Almeida', 'Analista de Sistemas', 'vitor.a@silomaster.com', 'senha123', 'Auditor', 4);


-- 5) LOTE (50 registros)
-- tipos de sementes: 13 tipos, cada um no máximo 4 vezes -> 13*4=52 > 50
-- anos de entrada/saída entre 2023 e 2025
-- id_empresa_dona: ciclo 1..5 ; id_comprador: valores entre 1..30 (alguns NULL para diversidade)
INSERT INTO lote (tipo_semente, quantidade, data_entrada, data_saida, id_empresa_dona, id_comprador) VALUES
('Milho', 5000.00, '2023-01-10 08:00:00', '2023-02-05 10:00:00', 1, 1),
('Milho', 4200.00, '2023-03-12 09:15:00', '2023-04-01 16:30:00', 2, 2),
('Milho', 6000.00, '2023-05-20 07:00:00', '2023-06-15 14:00:00', 3, 3),
('Milho', 3500.00, '2023-09-01 10:30:00', NULL, 4, 4),

('Soja', 3200.00, '2023-02-20 09:00:00', '2023-03-10 15:00:00', 5, 5),
('Soja', 2800.00, '2023-04-05 11:25:00', '2023-05-03 09:00:00', 1, 6),
('Soja', 4000.00, '2023-06-10 08:45:00', NULL, 2, 7),
('Soja', 3600.00, '2023-10-12 12:00:00', '2023-11-05 18:30:00', 3, 8),

('Trigo', 7800.00, '2023-01-15 07:50:00', '2023-02-20 10:00:00', 4, 9),
('Trigo', 7100.00, '2023-03-25 09:30:00', NULL, 5, 10),
('Trigo', 5000.00, '2023-07-10 14:00:00', '2023-08-05 16:30:00', 1, 11),
('Trigo', 6200.00, '2023-11-01 08:10:00', '2023-12-20 12:00:00', 2, 12),

('Algodão', 9800.00, '2024-01-05 06:30:00', '2024-02-25 09:10:00', 3, 13),
('Algodão', 5400.00, '2024-03-18 07:45:00', NULL, 4, 14),
('Algodão', 7600.00, '2024-05-22 10:00:00', '2024-06-15 11:30:00', 5, 15),
('Algodão', 4100.00, '2024-09-30 09:20:00', NULL, 1, 16),

('Girassol', 1500.00, '2024-02-14 08:40:00', '2024-03-10 13:00:00', 2, 17),
('Girassol', 1800.00, '2024-04-22 10:10:00', '2024-05-05 09:00:00', 3, 18),
('Girassol', 2000.00, '2024-06-02 12:30:00', NULL, 4, 19),
('Girassol', 1400.00, '2024-10-11 14:00:00', '2024-11-03 15:50:00', 5, 20),

('Cevada', 3000.00, '2024-01-20 09:00:00', '2024-02-12 16:30:00', 1, 21),
('Cevada', 3100.00, '2024-03-30 11:15:00', NULL, 2, 22),
('Cevada', 2900.00, '2024-07-08 08:50:00', '2024-08-01 18:00:00', 3, 23),
('Cevada', 3300.00, '2024-11-20 10:20:00', NULL, 4, 24),

('Feijão', 2200.00, '2025-01-10 07:30:00', '2025-02-05 10:40:00', 5, 25),
('Feijão', 2400.00, '2025-03-15 09:40:00', '2025-04-02 12:00:00', 1, 26),
('Feijão', 2000.00, '2025-05-20 10:10:00', NULL, 2, 27),
('Feijão', 1800.00, '2025-07-01 08:00:00', '2025-07-20 16:00:00', 3, 28),

('Aveia', 1200.00, '2023-02-01 09:00:00', '2023-02-28 11:00:00', 4, 29),
('Aveia', 1400.00, '2023-05-10 10:30:00', NULL, 5, 30),
('Aveia', 1000.00, '2023-09-18 08:20:00', '2023-10-05 14:20:00', 1, 1),
('Aveia', 1800.00, '2023-12-01 07:45:00', NULL, 2, 2),

('Sorgo', 2600.00, '2024-02-25 08:10:00', '2024-03-20 15:00:00', 3, 3),
('Sorgo', 2400.00, '2024-04-28 09:35:00', NULL, 4, 4),
('Sorgo', 2800.00, '2024-08-12 11:40:00', '2024-09-01 17:00:00', 5, 5),
('Sorgo', 2300.00, '2024-11-05 13:00:00', NULL, 1, 6),

('Ervilha', 900.00, '2025-02-14 08:00:00', '2025-03-05 12:30:00', 2, 7),
('Ervilha', 1100.00, '2025-04-20 09:50:00', NULL, 3, 8),
('Ervilha', 950.00, '2025-06-22 07:30:00', '2025-07-10 15:20:00', 4, 9),
('Ervilha', 1000.00, '2025-09-01 10:00:00', NULL, 5, 10),

('Milheto', 1500.00, '2023-03-05 09:10:00', '2023-03-28 14:00:00', 1, 11),
('Milheto', 1600.00, '2023-06-18 08:45:00', NULL, 2, 12),
('Milheto', 1300.00, '2023-10-21 07:30:00', '2023-11-15 16:10:00', 3, 13),
('Milheto', 1700.00, '2023-12-28 09:55:00', NULL, 4, 14),

('Grão-de-bico', 800.00, '2024-03-10 08:20:00', '2024-04-05 10:40:00', 5, 15),
('Grão-de-bico', 900.00, '2024-06-05 09:25:00', NULL, 1, 16),
('Grão-de-bico', 750.00, '2024-09-12 10:10:00', '2024-10-07 14:30:00', 2, 17),
('Grão-de-bico', 820.00, '2024-12-01 11:00:00', NULL, 3, 18),

('Canola', 2000.00, '2025-01-15 07:20:00', '2025-02-10 13:00:00', 4, 19),
('Canola', 2100.00, '2025-04-02 09:00:00', NULL, 5, 20);


-- 6) SENSOR (30 registros)
-- id_local: usar locais 1..30
INSERT INTO sensor (tipo_sensor, status, id_local) VALUES
('Temperatura', 'Ativo', 1),
('Umidade', 'Ativo', 1),
('Luminosidade', 'Ativo', 2),
('Temperatura', 'Ativo', 2),
('Umidade', 'Ativo', 3),
('Temperatura', 'Ativo', 3),
('Luminosidade', 'Inativo', 4),
('Umidade', 'Ativo', 4),
('Temperatura', 'Ativo', 5),
('Umidade', 'Inativo', 5),

('Temperatura', 'Ativo', 6),
('Umidade', 'Ativo', 7),
('Luminosidade', 'Ativo', 8),
('Temperatura', 'Ativo', 9),
('Umidade', 'Ativo', 10),
('Temperatura', 'Ativo', 11),
('Luminosidade', 'Ativo', 12),
('Umidade', 'Ativo', 13),
('Temperatura', 'Ativo', 14),
('Umidade', 'Ativo', 15),

('Luminosidade', 'Ativo', 16),
('Temperatura', 'Ativo', 17),
('Umidade', 'Ativo', 18),
('Temperatura', 'Ativo', 19),
('Luminosidade', 'Ativo', 20),
('Umidade', 'Ativo', 21),
('Temperatura', 'Ativo', 22),
('Luminosidade', 'Inativo', 23),
('Umidade', 'Ativo', 24),
('Temperatura', 'Ativo', 25);


-- 7) LEITURA (50 registros)
-- Cada leitura referencia id_sensor (1..30), id_local (1..30), id_lote (1..50)
-- As datas são escolhidas para cair dentro do período entre data_entrada e data_saida do lote quando possível.
INSERT INTO leitura (valor_temperatura, valor_umidade, valor_luminosidade, data_hora, id_sensor, id_local, id_lote) VALUES
(26.1, 58.7, 118.0, '2023-01-10 09:15:00', 1, 1, 1),
(25.4, 59.2, 120.0, '2023-01-20 10:30:00', 2, 1, 1),
(27.0, 50.0, 130.0, '2023-03-13 11:00:00', 4, 2, 2),
(28.5, 48.2, 140.0, '2023-05-21 08:30:00', 6, 3, 3),
(24.8, 62.1, 119.3, '2023-09-10 09:45:00', 6, 3, 4),

(22.5, 55.0, 90.1, '2023-02-21 10:05:00', 4, 2, 5),
(23.2, 57.5, 88.0, '2023-04-06 12:20:00', 4, 2, 6),
(21.8, 61.3, 85.0, '2023-06-11 09:10:00', 3, 2, 7),
(30.0, 38.0, 300.0, '2023-01-20 14:00:00', 7, 4, 9),
(26.2, 42.0, 210.0, '2023-01-21 10:00:00', 8, 4, 9),

(27.3, 41.2, 205.0, '2023-01-22 08:30:00', 8, 4, 9),
(31.5, 37.5, 310.0, '2024-01-05 09:00:00', 9, 5, 13),
(29.8, 39.2, 290.0, '2024-03-20 15:00:00', 10, 5, 13),
(24.2, 60.1, 110.0, '2024-03-19 10:00:00', 11, 6, 16),
(23.5, 62.0, 112.0, '2024-04-01 16:00:00', 11, 6, 16),

(22.8, 64.5, 115.0, '2024-05-23 08:30:00', 12, 7, 16),
(25.1, 55.7, 130.0, '2024-06-30 10:45:00', 13, 8, 18),
(26.3, 57.1, 135.0, '2024-06-01 11:00:00', 13, 8, 18),
(27.8, 58.0, 138.0, '2024-07-09 09:30:00', 14, 9, 18),
(28.5, 40.0, 90.0, '2024-01-22 06:50:00', 15, 10, 21),

(29.0, 42.0, 95.0, '2024-03-31 14:00:00', 15, 10, 21),
(30.2, 43.5, 100.0, '2024-07-01 10:20:00', 14, 9, 24),
(23.0, 65.0, 80.0, '2025-01-15 09:00:00', 1, 1, 25),
(22.4, 66.5, 82.0, '2025-03-16 10:30:00', 2, 1, 26),
(24.0, 64.0, 85.0, '2025-05-21 11:45:00', 2, 1, 27),

(26.0, 58.0, 140.0, '2025-07-02 12:00:00', 3, 2, 28),
(27.1, 59.4, 145.0, '2025-09-05 13:30:00', 4, 2, 29),
(28.3, 60.0, 150.0, '2024-11-15 08:50:00', 5, 3, 30),
(25.0, 48.0, 110.0, '2023-02-10 09:30:00', 6, 3, 31),
(24.7, 49.2, 108.0, '2023-03-06 10:50:00', 7, 4, 32),

(21.4, 55.0, 95.0, '2023-05-23 08:20:00', 8, 4, 33),
(22.9, 57.8, 100.0, '2023-06-07 09:35:00', 9, 5, 34),
(26.5, 56.0, 120.0, '2024-02-26 11:10:00', 10, 5, 35),
(27.3, 54.5, 125.0, '2024-04-30 12:45:00', 11, 6, 36),
(28.0, 53.2, 130.0, '2024-08-15 14:00:00', 12, 7, 37),

(19.8, 68.0, 70.0, '2025-02-20 07:40:00', 13, 8, 38),
(20.5, 67.2, 72.0, '2025-04-24 09:15:00', 14, 9, 39),
(21.0, 66.0, 75.0, '2025-06-25 10:00:00', 15, 10, 40),
(22.2, 63.5, 85.0, '2023-10-05 11:30:00', 16, 11, 41),
(23.7, 60.8, 95.0, '2023-12-12 13:20:00', 17, 12, 42),

(24.9, 58.0, 105.0, '2024-09-18 08:10:00', 18, 13, 43),
(25.6, 57.1, 110.0, '2024-10-25 09:50:00', 19, 14, 44),
(26.7, 55.0, 115.0, '2024-11-30 10:20:00', 20, 15, 45),
(27.5, 54.0, 120.0, '2025-07-05 12:45:00', 21, 16, 46),
(28.6, 52.3, 125.0, '2025-08-10 14:30:00', 22, 17, 47),

(29.2, 51.7, 130.0, '2025-09-20 15:10:00', 23, 18, 48),
(30.1, 50.5, 135.0, '2025-10-30 16:25:00', 24, 19, 49),
(31.0, 49.0, 140.0, '2025-11-15 17:45:00', 25, 20, 50);

-- 8) ALERTA (30 registros)
-- referenciar sensores 1..30, lotes 1..50, locais 1..30, usuarios 1..30
INSERT INTO alerta 
(tipo_alerta, valor_lido, descricao, nivel_risco, data_hora, id_sensor, id_lote, id_local, id_usuario_visualizou) VALUES
('Temperatura Alta', 32.5, 'Temperatura acima do limite recomendado.', 'Alto', '2024-03-10 14:22:00', 1, 1, 1, 2),
('Umidade Baixa', 18.2, 'Umidade abaixo do ideal para armazenamento.', 'Médio', '2024-03-11 09:15:00', 2, 2, 2, 3),
('Luminosidade Alta', 890.0, 'Nível de luminosidade excessivo detectado.', 'Alto', '2024-03-12 16:45:00', 3, 3, 3, 4),
('Temperatura Baixa', 8.1, 'Temperatura menor que o limite aceitável.', 'Baixo', '2024-03-13 11:00:00', 4, 4, 4, 5),
('Umidade Alta', 92.3, 'Umidade acima do limite seguro.', 'Alto', '2024-03-14 10:10:00', 5, 5, 5, 6),
('Luminosidade Baixa', 50.0, 'Luminosidade muito baixa para monitoramento.', 'Baixo', '2024-03-15 08:00:00', 6, 6, 6, 7),

('Temperatura Alta', 35.8, 'Aumento brusco de temperatura detectado.', 'Crítico', '2024-03-16 17:40:00', 7, 7, 7, 8),
('Umidade Baixa', 16.0, 'Umidade abaixo do ideal.', 'Médio', '2024-03-17 12:25:00', 8, 8, 8, 9),
('Luminosidade Alta', 920.0, 'Luz excessiva no armazenamento.', 'Alto', '2024-03-18 15:15:00', 9, 9, 9, 10),
('Temperatura Baixa', 9.2, 'Temperatura muito baixa detectada.', 'Baixo', '2024-03-19 07:55:00', 10, 10, 10, 11),

('Umidade Alta', 88.1, 'Umidade acima do limite.', 'Médio', '2024-03-20 18:33:00', 11, 11, 11, 12),
('Temperatura Alta', 34.7, 'Temperatura acima do limite.', 'Alto', '2024-03-21 14:30:00', 12, 12, 12, 13),
('Umidade Baixa', 19.0, 'Umidade inferior ao previsto.', 'Baixo', '2024-03-22 09:45:00', 13, 13, 13, 14),
('Luminosidade Alta', 850.3, 'Luminosidade excessiva.', 'Médio', '2024-03-23 10:50:00', 14, 14, 14, 15),
('Temperatura Alta', 36.4, 'Risco de superaquecimento.', 'Crítico', '2024-03-24 13:20:00', 15, 15, 15, 16),

('Umidade Alta', 90.2, 'Umidade fora dos padrões.', 'Alto', '2024-03-25 11:40:00', 16, 16, 16, 17),
('Temperatura Baixa', 7.8, 'Temperatura baixa demais.', 'Baixo', '2024-03-26 06:30:00', 17, 17, 17, 18),
('Umidade Baixa', 17.4, 'Umidade baixa detectada.', 'Médio', '2024-03-27 14:05:00', 18, 18, 18, 19),
('Luminosidade Baixa', 40.0, 'Pouca luminosidade registrada.', 'Baixo', '2024-03-28 08:25:00', 19, 19, 19, 20),
('Temperatura Alta', 33.0, 'Temperatura elevada no silo.', 'Alto', '2024-03-29 16:18:00', 20, 20, 20, 21),

('Umidade Alta', 89.5, 'Umidade comprometendo qualidade.', 'Crítico', '2024-03-30 15:30:00', 21, 21, 21, 22),
('Temperatura Baixa', 6.9, 'Temperatura em nível crítico.', 'Crítico', '2024-03-31 04:50:00', 22, 22, 22, 23),
('Luminosidade Alta', 910.2, 'Exposição à luz muito alta.', 'Alto', '2024-04-01 13:44:00', 23, 23, 23, 24),
('Umidade Baixa', 15.5, 'Umidade prejudicial ao armazenamento.', 'Alto', '2024-04-02 17:10:00', 24, 24, 24, 25),
('Temperatura Alta', 37.0, 'Temperatura extrema.', 'Crítico', '2024-04-03 12:33:00', 25, 25, 25, 26),

('Luminosidade Baixa', 45.7, 'Luminosidade insuficiente.', 'Baixo', '2024-04-04 09:22:00', 26, 26, 26, 27),
('Umidade Alta', 91.1, 'Umidade perigosa para as sementes.', 'Crítico', '2024-04-05 11:08:00', 27, 27, 27, 28),
('Temperatura Baixa', 8.5, 'Temperatura abaixo do ideal.', 'Baixo', '2024-04-06 07:47:00', 28, 28, 28, 29),
('Luminosidade Alta', 930.0, 'Luminosidade acima do limite.', 'Alto', '2024-04-07 18:55:00', 29, 29, 29, 28),
('Umidade Baixa', 14.8, 'Umidade extremamente baixa.', 'Crítico', '2024-04-08 05:33:00', 30, 30, 30, 27);


-- 9) TRANSPORTE (25 registros)
-- id_local_veiculo references locais que are of type 'Veículo' (we used various ids; here assume vehicle locals include ids 11,12,13,14,15,21,22,...)
INSERT INTO transporte (data_inicio, data_fim, origem, destino, id_lote, id_local_veiculo) VALUES
('2023-02-01 06:00:00', '2023-02-01 14:00:00', 'Fazenda 01', 'Silo Central 01', 1, 11),
('2023-04-01 07:00:00', '2023-04-01 13:30:00', 'Silo Secundário 02', 'Cooperativa AgroSul', 2, 12),
('2023-06-10 08:15:00', '2023-06-10 16:00:00', 'Silo Norte 03', 'Exportadora TerraBoa', 3, 13),
('2023-09-05 05:50:00', '2023-09-05 14:20:00', 'Silo Especial 04', 'Fazenda Primavera', 4, 14),
('2023-11-20 06:30:00', '2023-11-20 15:00:00', 'Silo Premium 05', 'Indústria BioGrão', 5, 15),

('2024-01-25 07:10:00', '2024-01-25 12:40:00', 'Galpão A - Armazenagem', 'Silo Central 01', 6, 11),
('2024-03-05 09:00:00', '2024-03-05 17:00:00', 'Armazém Regional 1', 'Cooperativa do Litoral', 7, 12),
('2024-05-20 05:45:00', '2024-05-20 13:30:00', 'Depósito Frio 1', 'Fazenda Boa Esperança', 8, 13),
('2024-07-15 08:00:00', '2024-07-15 16:30:00', 'Terminal Silo Leste', 'Armazém Satélite 01', 9, 14),
('2024-09-10 06:20:00', '2024-09-10 14:45:00', 'Terminal Silo Oeste', 'Pátio de Estocagem 1', 10, 15),

('2024-11-22 07:30:00', '2024-11-22 16:10:00', 'Doca de Carregamento 01', 'Doca de Carregamento 02', 11, 11),
('2025-01-18 09:00:00', '2025-01-18 18:05:00', 'Silo Comunitário 01', 'Silo Comunitário 02', 12, 12),
('2025-03-25 05:40:00', '2025-03-25 13:20:00', 'Armazém Satélite 02', 'Container 01', 13, 13),
('2025-05-10 06:15:00', '2025-05-10 15:00:00', 'Pátio de Estocagem 2', 'Depósito Seco 2', 14, 14),
('2025-06-30 07:20:00', '2025-06-30 16:40:00', 'Veículo Baú 06', 'Veículo Graneleiro 07', 15, 15),

('2025-07-05 08:00:00', '2025-07-05 12:00:00', 'Silo Central 01', 'Fazenda Nova Vida', 16, 11),
('2025-08-14 06:50:00', '2025-08-14 18:10:00', 'Armazém Satélite 01', 'Armazém Satélite 02', 17, 12),
('2025-09-19 09:30:00', '2025-09-19 17:45:00', 'Depósito Frio 1', 'Mercado Rural LTDA', 18, 13),
('2025-10-28 05:55:00', '2025-10-28 14:20:00', 'Doca de Carregamento 02', 'Silo Premium 05', 19, 14),
('2025-11-12 07:10:00', '2025-11-12 16:30:00', 'Armazém Regional 2', 'Terminal Silo Leste', 20, 15),

('2024-06-16 06:30:00', '2024-06-16 12:00:00', 'Silo Norte 03', 'VerdeVida', 21, 12),
('2024-07-01 08:00:00', '2024-07-01 16:00:00', 'Silo Especial 04', 'Fazenda Primavera', 24, 13),
('2024-05-25 08:00:00', '2024-05-25 13:00:00', 'Silo Norte 03', 'Campo Forte LTDA', 35, 14),
('2024-12-05 09:00:00', '2024-12-05 17:20:00', 'Armazém Regional 2', 'AgroTech Brasil', 40, 11),
('2025-02-14 10:10:00', '2025-02-14 18:30:00', 'Doca de Carregamento 01', 'Cooperativa Serrana', 45, 12);
