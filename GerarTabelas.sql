CREATE TABLE Utilizador (
  IDU CHAR(10) NOT NULL, -- Formato XX_Nome, onde XX � o prefixo do tipo de utilizador
  tipo_utilizador CHAR(2) NOT NULL, -- PR, RS, BS, etc.
  telefone INT NOT NULL,
  email VARCHAR(50) NOT NULL,
  prioridade_corrente VARCHAR(50) NOT NULL, -- M�xima, Acima da M�dia, etc.
  classe_prioridade VARCHAR(50) NOT NULL, -- Prioridade fixa por tipo de utilizador
  nome VARCHAR(50) NOT NULL, -- Nome completo do utilizador
  PRIMARY KEY (IDU),
  CHECK (tipo_utilizador IN ('PR', 'RS', 'BS', 'MS', 'DS', 'SF', 'XT')), -- Tipos v�lidos
  CHECK (prioridade_corrente IN ('M�xima', 'Acima da M�dia', 'M�dia', 'Abaixo da M�dia', 'M�nima')),
  CHECK (classe_prioridade IN ('M�xima', 'Acima da M�dia', 'M�dia', 'Abaixo da M�dia', 'M�nima'))
);

CREATE TABLE Requisicao (
  IDRQ INT IDENTITY(1,1) NOT NULL, -- N�mero �nico para cada requisi��o
  estado_req VARCHAR(50) NOT NULL, -- Active ou Closed
  data_devolucao DATE NOT NULL,
  data_levantamento DATE NOT NULL,
  PRIMARY KEY (IDRQ),
  CHECK (estado_req IN ('Active', 'Closed')), -- Estados v�lidos
  CHECK (data_levantamento <= data_devolucao) -- Data de levantamento n�o pode ser depois da devolu��o
);

-- Criar tabela Historico_Prioridade
CREATE TABLE Historico_Prioridade (
  IDHP INT IDENTITY(1,1) NOT NULL, -- N�mero �nico para cada hist�rico
  prioridade_anterior VARCHAR(50) NOT NULL,
  prioridade_atual VARCHAR(50) NOT NULL,
  motivo VARCHAR(50) NOT NULL, -- Motivo da altera��o de prioridade
  data DATE NOT NULL,
  IDU CHAR(10) NOT NULL, -- Refer�ncia ao utilizador
  PRIMARY KEY (IDHP),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU), -- Liga��o ao utilizador
  CHECK (prioridade_anterior IN ('M�xima', 'Acima da M�dia', 'M�dia', 'Abaixo da M�dia', 'M�nima')),
  CHECK (prioridade_atual IN ('M�xima', 'Acima da M�dia', 'M�dia', 'Abaixo da M�dia', 'M�nima'))
);

-- Criar tabela Reserva
CREATE TABLE Reserva (
  IDR CHAR(8) NOT NULL, -- Formato yyyySSSS, onde yyyy � o ano e SSSS � sequencial
  timestamp DATETIME NOT NULL, -- Data e hora da cria��o da reserva
  inicio_uso DATE NOT NULL,
  duracao VARCHAR(50) NOT NULL, -- Ex.: '2 horas'
  estado_reserva VARCHAR(50) NOT NULL, -- Active, Waiting, etc.
  IDU CHAR(10) NOT NULL, -- Refer�ncia ao utilizador
  IDRQ INT NOT NULL, -- Refer�ncia � requisi��o
  PRIMARY KEY (IDR),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU),
  FOREIGN KEY (IDRQ) REFERENCES Requisicao(IDRQ),
  CHECK (estado_reserva IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')), -- Estados v�lidos
);

-- Criar tabela Historico_Estado
CREATE TABLE Historico_Estado (
  IDHE INT IDENTITY(1,1) NOT NULL, -- N�mero �nico para cada registro de hist�rico
  estado_anterior VARCHAR(50) NOT NULL,
  motivo VARCHAR(50) NOT NULL, -- Motivo da altera��o de estado
  estado_atual VARCHAR(50) NOT NULL,
  data_alteracao DATE NOT NULL,
  IDR CHAR(8) NOT NULL, -- Refer�ncia � reserva
  PRIMARY KEY (IDHE),
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  CHECK (estado_anterior IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')),
  CHECK (estado_atual IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten'))
);

-- Criar tabela Equipamento
CREATE TABLE Equipamento (
  IDE INT IDENTITY(1,1) NOT NULL, -- N�mero �nico para cada equipamento
  descricao VARCHAR(50) NOT NULL, -- Descri��o do equipamento
  estado_eq VARCHAR(50) NOT NULL, -- Dispon�vel, Em Uso, etc.
  IDR CHAR(8) NOT NULL, -- Refer�ncia � reserva
  IDRQ INT NOT NULL, -- Refer�ncia � requisi��o
  PRIMARY KEY (IDE),
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  FOREIGN KEY (IDRQ) REFERENCES Requisicao(IDRQ),
  CHECK (estado_eq IN ('Dispon�vel', 'Em Uso', 'Reservado')) -- Estados v�lidos
);
