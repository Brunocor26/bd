CREATE TABLE Utilizador (
  IDU CHAR(10) NOT NULL, -- Formato XX_Nome, onde XX é o prefixo do tipo de utilizador
  tipo_utilizador CHAR(2) NOT NULL, -- PR, RS, BS, etc.
  telefone INT NOT NULL,
  email VARCHAR(50) NOT NULL,
  prioridade_corrente VARCHAR(50) NOT NULL, -- Máxima, Acima da Média, etc.
  classe_prioridade VARCHAR(50) NOT NULL, -- Prioridade fixa por tipo de utilizador
  nome VARCHAR(50) NOT NULL, -- Nome completo do utilizador
  PRIMARY KEY (IDU),
  CHECK (tipo_utilizador IN ('PR', 'RS', 'BS', 'MS', 'DS', 'SF', 'XT')), -- Tipos válidos
  CHECK (prioridade_corrente IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima')),
  CHECK (classe_prioridade IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima'))
);

CREATE TABLE Requisicao (
  IDRQ INT IDENTITY(1,1) NOT NULL, -- Número único para cada requisição
  estado_req VARCHAR(50) NOT NULL, -- Active ou Closed
  data_devolucao DATE NOT NULL,
  data_levantamento DATE NOT NULL,
  PRIMARY KEY (IDRQ),
  CHECK (estado_req IN ('Active', 'Closed')), -- Estados válidos
  CHECK (data_levantamento <= data_devolucao) -- Data de levantamento não pode ser depois da devolução
);

-- Criar tabela Historico_Prioridade
CREATE TABLE Historico_Prioridade (
  IDHP INT IDENTITY(1,1) NOT NULL, -- Número único para cada histórico
  prioridade_anterior VARCHAR(50) NOT NULL,
  prioridade_atual VARCHAR(50) NOT NULL,
  motivo VARCHAR(50) NOT NULL, -- Motivo da alteração de prioridade
  data DATE NOT NULL,
  IDU CHAR(10) NOT NULL, -- Referência ao utilizador
  PRIMARY KEY (IDHP),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU), -- Ligação ao utilizador
  CHECK (prioridade_anterior IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima')),
  CHECK (prioridade_atual IN ('Máxima', 'Acima da Média', 'Média', 'Abaixo da Média', 'Mínima'))
);

-- Criar tabela Reserva
CREATE TABLE Reserva (
  IDR CHAR(8) NOT NULL, -- Formato yyyySSSS, onde yyyy é o ano e SSSS é sequencial
  timestamp DATETIME NOT NULL, -- Data e hora da criação da reserva
  inicio_uso DATE NOT NULL,
  duracao VARCHAR(50) NOT NULL, -- Ex.: '2 horas'
  estado_reserva VARCHAR(50) NOT NULL, -- Active, Waiting, etc.
  IDU CHAR(10) NOT NULL, -- Referência ao utilizador
  IDRQ INT NOT NULL, -- Referência à requisição
  PRIMARY KEY (IDR),
  FOREIGN KEY (IDU) REFERENCES Utilizador(IDU),
  FOREIGN KEY (IDRQ) REFERENCES Requisicao(IDRQ),
  CHECK (estado_reserva IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')), -- Estados válidos
);

-- Criar tabela Historico_Estado
CREATE TABLE Historico_Estado (
  IDHE INT IDENTITY(1,1) NOT NULL, -- Número único para cada registro de histórico
  estado_anterior VARCHAR(50) NOT NULL,
  motivo VARCHAR(50) NOT NULL, -- Motivo da alteração de estado
  estado_atual VARCHAR(50) NOT NULL,
  data_alteracao DATE NOT NULL,
  IDR CHAR(8) NOT NULL, -- Referência à reserva
  PRIMARY KEY (IDHE),
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  CHECK (estado_anterior IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')),
  CHECK (estado_atual IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten'))
);

-- Criar tabela Equipamento
CREATE TABLE Equipamento (
  IDE INT IDENTITY(1,1) NOT NULL, -- Número único para cada equipamento
  descricao VARCHAR(50) NOT NULL, -- Descrição do equipamento
  estado_eq VARCHAR(50) NOT NULL, -- Disponível, Em Uso, etc.
  IDR CHAR(8) NOT NULL, -- Referência à reserva
  IDRQ INT NOT NULL, -- Referência à requisição
  PRIMARY KEY (IDE),
  FOREIGN KEY (IDR) REFERENCES Reserva(IDR),
  FOREIGN KEY (IDRQ) REFERENCES Requisicao(IDRQ),
  CHECK (estado_eq IN ('Disponível', 'Em Uso', 'Reservado')) -- Estados válidos
);
