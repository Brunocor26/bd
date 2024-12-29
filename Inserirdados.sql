-- Inserir dados na tabela Utilizador (IDU gerado automaticamente)
INSERT INTO Utilizador (tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome)
VALUES
('PR', 912345678, 'pr.user@dominio.com', 'Máxima', 'Máxima', 'Pedro Ribeiro'),
('RS', 923456789, 'rs.user@dominio.com', 'Acima da Média', 'Média', 'Rita Santos'),
('BS', 934567890, 'bs.user@dominio.com', 'Média', 'Acima da Média', 'Bruno Silva'),
('MS', 945678901, 'ms.user@dominio.com', 'Mínima', 'Mínima', 'Marta Souza');

-- Inserir dados na tabela Requisicao (IDRQ gerado automaticamente)
INSERT INTO Requisicao (estado_req, data_devolucao, data_levantamento)
VALUES
('Active', '2024-12-30', '2024-12-23'),
('Closed', '2024-12-25', '2024-12-20'),
('Active', '2024-12-28', '2024-12-22'),
('Closed', '2024-12-26', '2024-12-21');

-- Inserir dados na tabela Historico_Prioridade (IDHP gerado automaticamente)
INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
VALUES
('Máxima', 'Acima da Média', 'Reavaliação de prioridades', '2024-12-20', 'PR_USER20240001'),
('Acima da Média', 'Média', 'Mudança de situação', '2024-12-21', 'RS_USER20240002'),
('Média', 'Máxima', 'Urgência aumentada', '2024-12-22', 'BS_USER20240003'),
('Mínima', 'Acima da Média', 'Mudança de prioridades', '2024-12-23', 'MS_USER20240004');

-- Inserir dados na tabela Reserva (IDR gerado automaticamente)
INSERT INTO Reserva (timestamp, inicio_uso, duracao, estado_reserva, IDU, IDRQ)
VALUES
('2024-12-23 10:00:00', '2024-12-25', '2 horas', 'Active', 'PR_USER20240001', 1),
('2024-12-23 11:00:00', '2024-12-26', '1 hora', 'Waiting', 'RS_USER20240002', 2),
('2024-12-23 12:00:00', '2024-12-27', '3 horas', 'Satisfied', 'BS_USER20240003', 3),
('2024-12-23 13:00:00', '2024-12-28', '4 horas', 'Canceled', 'MS_USER20240004', 4);

-- Inserir dados na tabela Historico_Estado (IDHE gerado automaticamente)
INSERT INTO Historico_Estado (estado_anterior, motivo, estado_atual, data_alteracao, IDR)
VALUES
('Active', 'Reserva confirmada', 'Satisfied', '2024-12-24', '2024123456'),
('Waiting', 'Aguardando confirmação', 'Active', '2024-12-24', '2024123457'),
('Satisfied', 'Reserva completada', 'Canceled', '2024-12-24', '2024123458'),
('Canceled', 'Usuário cancelou', 'Forgotten', '2024-12-24', '2024123459');

-- Inserir dados na tabela Equipamento (IDE gerado automaticamente)
INSERT INTO Equipamento (descricao, estado_eq, IDR, IDRQ)
VALUES
('Projetor', 'Disponível', '2024123456', 1),
('Laptop', 'Em Uso', '2024123457', 2),
('Câmera', 'Reservado', '2024123458', 3),
('Microfone', 'Disponível', '2024123459', 4);
