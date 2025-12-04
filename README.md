🌱 TEXTO EXPLICATIVO DO PROJETO – MINIMUNDO COMPLETO PI

**Justificativa**
O armazenamento e transporte de sementes exigem condições ambientais controladas, como temperatura, umidade e luminosidade, para garantir sua qualidade e viabilidade. Pequenas variações podem comprometer o desempenho geral do lote, causando prejuízos às empresas produtoras, cooperativas, UBS (Unidades de Beneficiamento de Sementes) e compradores.
Com o avanço da tecnologia, sensores IoT permitem monitorar em tempo real essas condições, oferecendo histórico completo e maior confiabilidade no processo. No entanto, muitas empresas ainda carecem de um sistema integrado que una rastreabilidade, monitoramento ambiental, alertas automáticos e transparência para o cliente final.
Diante disso, o sistema proposto tem como objetivo garantir maior controle sobre o ciclo de vida das sementes — desde a entrada no silo até a entrega — fornecendo dados confiáveis, automação e segurança para toda a cadeia produtiva.

**Objetivos do Sistema**

Objetivo Geral
Desenvolver um sistema de monitoramento e rastreabilidade de sementes utilizando sensores IoT, permitindo o acompanhamento completo dos lotes, condições ambientais, deslocamentos e alertas, garantindo qualidade e transparência aos envolvidos.
Objetivos Específicos
Registrar lotes de sementes e suas informações básicas.


Monitorar em tempo real temperatura, umidade e luminosidade através de sensores IoT.

Armazenar todo o histórico de leituras dos sensores.

Emitir alertas automáticos quando os valores saírem dos limites seguros.

Registrar transportes e movimentações de lotes.

Manter rastreabilidade completa: entrada → armazenamento → transporte → entrega.

Permitir que compradores acompanhem o lote adquirido.

Gerenciar diferentes níveis de acesso por tipo de usuário.

Gerar relatórios e análises históricas para auditoria e apoio à gestão.



**Narrativa do Minimundo
**
A empresa responsável pelo sistema trabalha com diversos tipos de sementes, como milho, soja, feijão e outras variedades. Cada lote de sementes é registrado no sistema no momento em que chega à UBS, cooperativa ou fazenda. São cadastrados dados como tipo da semente, quantidade, empresa proprietária e a situação atual do lote.
Os lotes podem estar armazenados em silos, galpões, armazéns ou veículos durante o transporte. Para monitorar as condições ambientais desses locais, sensores IoT são instalados e configurados com um ID único, tipo de leitura (temperatura, umidade, luminosidade) e local de instalação. Esses sensores enviam leituras automáticas contendo data, hora e valores medidos.
Todas as leituras recebidas são vinculadas ao lote que se encontra naquele local no momento, criando um histórico completo de condições ambientais por onde o lote passou.
Caso uma leitura esteja fora dos limites recomendados, o sistema gera um alerta automático, armazenando o tipo de alerta, valores capturados, local, lote afetado e o horário da ocorrência. Esse histórico é mantido para auditoria e análises futuras.
Quando um lote é transportado, um registro de transporte é criado contendo informações como veículo, motorista, origem, destino e sensores ativos no trajeto. As leituras durante o transporte continuam sendo registradas normalmente.
O sistema possui diferentes níveis de acesso, incluindo Gerente de Produção, Agrônomo, Responsável pelo Silo, Admin da UBS e o Cliente que comprou determinado lote. O comprador tem acesso exclusivo para acompanhar o andamento do lote adquirido, incluindo localização atual, condições ambientais e histórico de transporte.
Por fim, o sistema permite gerar relatórios completos sobre o lote, incluindo histórico ambiental, alertas emitidos, movimentações e dados de transporte — garantindo rastreabilidade total do início ao fim do processo.

**Regras de Negócio**

Todo lote deve estar sempre associado a um local (silo, armazém ou veículo de transporte).

Cada sensor só pode estar vinculado a um único local por vez, porém pode ser movido quando necessário.

Toda leitura registrada por um sensor deve ser associada ao sensor, ao local e ao lote atual daquele local.

O sistema deve manter histórico completo de leituras, sem sobrescrever valores anteriores.

Alertas devem ser gerados automaticamente quando os valores de temperatura, umidade ou luminosidade estiverem fora dos limites seguros.

Todo alerta gerado deve ser armazenado para fins de rastreabilidade.

Cada lote pode possuir vários registros de transporte, mas cada transporte pertence a um único lote.

O comprador só pode visualizar os dados dos lotes que adquiriu.

Somente usuários cadastrados podem cadastrar, editar ou consultar informações sensíveis.

O lote tem rastreabilidade total, desde a entrada até a entrega ao cliente final.

As leituras realizadas durante o transporte fazem parte do histórico do lote.

Um sensor só pode registrar leituras se estiver ativo.
