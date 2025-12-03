-- create database SiloLK;
-- drop database SiloLK;
use SiloLk;

CREATE TABLE empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    tipo VARCHAR(100)
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    cargo VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    senha VARCHAR(255),
    nivel_acesso VARCHAR(50),
    id_empresa INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE comprador (
    id_comprador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    documento VARCHAR(50),
    contato VARCHAR(100)
);

CREATE TABLE local_armazenamento (
    id_local INT AUTO_INCREMENT PRIMARY KEY,
    nome_local VARCHAR(255),
    tipo_local VARCHAR(100),
    id_empresa INT,
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa)
);

CREATE TABLE lote (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    tipo_semente VARCHAR(100),
    quantidade DECIMAL(10,2),
    data_entrada DATETIME,
    data_saida DATETIME,
    id_empresa_dona INT,
    id_comprador INT,
    FOREIGN KEY (id_empresa_dona) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_comprador) REFERENCES comprador(id_comprador)
);

CREATE TABLE sensor (
    id_sensor INT AUTO_INCREMENT PRIMARY KEY,
    tipo_sensor VARCHAR(100),
    status VARCHAR(50),
    id_local INT,
    FOREIGN KEY (id_local) REFERENCES local_armazenamento(id_local)
);

CREATE TABLE leitura (
    id_leitura INT AUTO_INCREMENT PRIMARY KEY,
    valor_temperatura DECIMAL(10,2),
    valor_umidade DECIMAL(10,2),
    valor_luminosidade DECIMAL(10,2),
    data_hora DATETIME,
    id_sensor INT,
    id_local INT,
    id_lote INT,
    FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor),
    FOREIGN KEY (id_local) REFERENCES local_armazenamento(id_local),
    FOREIGN KEY (id_lote) REFERENCES lote(id_lote)
);

CREATE TABLE alerta (
    id_alerta INT AUTO_INCREMENT PRIMARY KEY,
    tipo_alerta VARCHAR(255),
    valor_lido DECIMAL(10,2),
    descricao TEXT,
    nivel_risco VARCHAR(50),
    data_hora DATETIME,
    id_sensor INT,
    id_lote INT,
    id_local INT,
    id_usuario_visualizou INT,
    FOREIGN KEY (id_sensor) REFERENCES sensor(id_sensor),
    FOREIGN KEY (id_lote) REFERENCES lote(id_lote),
    FOREIGN KEY (id_local) REFERENCES local_armazenamento(id_local),
    FOREIGN KEY (id_usuario_visualizou) REFERENCES usuario(id_usuario)
);

CREATE TABLE transporte (
    id_transporte INT AUTO_INCREMENT PRIMARY KEY,
    data_inicio DATETIME,
    data_fim DATETIME,
    origem VARCHAR(255),
    destino VARCHAR(255),
    id_lote INT,
    id_local_veiculo INT,
    FOREIGN KEY (id_lote) REFERENCES lote(id_lote),
    FOREIGN KEY (id_local_veiculo) REFERENCES local_armazenamento(id_local)
);


