CREATE TABLE Utilizador (
  IDU CHAR(10) NOT NULL, -- Formato XX_Nome, onde XX é o prefixo do tipo de utilizador, gerado automaticamente (trigger)
  tipo_utilizador CHAR(2) NOT NULL,
  nome VARCHAR(50) NOT NULL, -- Nome completo do utilizador  
  telefone INT NOT NULL,
  email VARCHAR(50) NOT NULL,
  prioridade_corrente VARCHAR(50) NOT NULL, -- Inicialmente igual a classe_prioridade, depois altera
  classe_prioridade VARCHAR(50) NOT NULL, -- Prioridade fixa por tipo de utilizador
  PRIMARY KEY (IDU),
  CHECK (tipo_utilizador IN ('PD', 'PR', 'RS', 'BS', 'MS', 'DS', 'SF', 'XT')), -- Tipos válidos
  CHECK (prioridade_corrente IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima')),
  CHECK (classe_prioridade IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima'))
);
--Notas: se for PD, é sempre máxima e nunca muda

-- Criar tabela Reserva
CREATE TABLE Reserva (
  IDR CHAR(8) NOT NULL, -- Formato yyyySSSS, onde yyyy é o ano e SSSS é sequencial
  timestamp DATETIME NOT NULL, -- Data e hora da criacao da reserva
  inicio_uso DATETIME NOT NULL, -- Data onde utilizador quer os recursos         UTILIZADOR INDICA
  fim_uso DATETIME NOT NULL, -- Até quando quer os recursos                      UTILIZADOR INDICA
  estado_reserva VARCHAR(50) NOT NULL, -- Active, Waiting, etc.
  IDU CHAR(10) NOT NULL, -- Referência ao utilizador responsavel pela reserva
  IDRQ INT NOT NULL, -- Referência à requisição
  PRIMARY KEY (IDR),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU),
  CHECK (estado_reserva IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')), -- Estados válidos
);

-- Criar tabela Historico_Prioridade
CREATE TABLE Historico_Prioridade (
  IDHP INT IDENTITY(1,1) NOT NULL, -- Número único para cada entrada no histórico
  prioridade_anterior VARCHAR(50) NOT NULL, -- automatico a partir do idu
  prioridade_nova VARCHAR(50) NOT NULL,
  motivo VARCHAR(50) NOT NULL, -- Motivo da alteração de prioridade
  punicao INT NOT NULL, -- 0 se é recompensa, 1 se é punição
  data DATE NOT NULL,  --data da entrada
  IDU CHAR(10) NOT NULL, -- Referência ao utilizador
  PRIMARY KEY (IDHP),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU), -- Ligação ao utilizador
  CHECK (prioridade_anterior IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima')),
  CHECK (punicao IN (0, 1),
  CHECK (prioridade_atual IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima'))
);

CREATE TABLE Requisicao ( -- criada quando uma reserva passa para o estado 'Satisfied'    , mesmo equipamentos levantados sem reserva geram requisicao!!
  IDRQ INT IDENTITY(1,1) NOT NULL, -- Número único para cada requisição, gerado automaticamente
  estado_req VARCHAR(50) NOT NULL, -- Active ou Closed (CLOSED até data_devolução deixar de ser NULL)
  data_devolucao DATE, -- NULL até serem devolvidos os equipamentos              SE É DEPOIS DO DEFINIDO NA RESERVA-> PUNIÇÃO
  data_levantamento DATE NOT NULL,
  IDR INT NOT NULL, --Referencia a reserva
  PRIMARY KEY (IDRQ),
   FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  CHECK (estado_req IN ('Active', 'Closed')), -- Estados válidos
  CHECK (data_levantamento <= data_devolucao) -- Data de levantamento não pode ser depois da devolução
);


-- Criar tabela Historico_Estado
CREATE TABLE Historico_Estado (
  IDHE INT IDENTITY(1,1) NOT NULL, -- Número único sequencial para cada registo de histórico
  estado_anterior VARCHAR(50) NOT NULL, -- Retirado automaticamente
  motivo VARCHAR(50) NOT NULL, -- Motivo da alteração de estado
  estado_novo VARCHAR(50) NOT NULL, -- Se estado_anterior = active -> satisfied ou canceled ou forgotten ou waiting; se = waiting-> outros todos; se = um dos outros, não pode mexer mais
  data_alteracao DATE NOT NULL,
  IDR CHAR(8) NOT NULL, -- Referência à reserva
  PRIMARY KEY (IDHE),
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  CHECK (estado_anterior IN ('Active', 'Waiting')),
  CHECK (estado_novo IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten'))
);

-- Criar tabela Equipamento
CREATE TABLE Equipamento (
  IDE INT IDENTITY(1,1) NOT NULL, -- Número único para cada equipamento
  essencial INT, --1 se é essencial, 0 se não é, NULL se este equipamento está disponível
  estado_eq VARCHAR(50) NOT NULL, -- Disponível, Em Uso, etc.
  IDR CHAR(8) NOT NULL, -- Referência à reserva
  IDU CHAR(10) NOT NULL, --Referencia ao utilizador
  IDRQ INT NOT NULL, -- Referência à requisição
  PRIMARY KEY (IDE), 
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  FOREIGN KEY (IDRQ) REFERENCES Requisicao(IDRQ),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU), 
  CHECK (estado_eq IN ('Disponível', 'Em Uso', 'Reservado')), -- Estados válidos
  CHECK (essencial IN (0, 1, NULL)) -- Estados válidos
);
