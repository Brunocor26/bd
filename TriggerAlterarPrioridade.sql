CREATE TRIGGER trg_AlterarPrioridade
ON Reserva
AFTER UPDATE
AS
BEGIN
    DECLARE @estado_reserva VARCHAR(50);
    DECLARE @IDU CHAR(10);

    -- Obter o estado da reserva e o ID do utilizador
    SELECT @estado_reserva = estado_reserva, @IDU = IDU FROM inserted;

    -- Se a reserva for 'Active' ou 'Waiting' e o utilizador não levantou o equipamento até o final do período
    IF (@estado_reserva IN ('Active', 'Waiting'))
    BEGIN
        -- Atualizar a prioridade do utilizador (descer um nível se não levantou o equipamento)
        UPDATE Utilizador
        SET prioridade_corrente = 
            CASE 
                WHEN prioridade_corrente = 'Média' THEN 'Abaixo da Média'
                WHEN prioridade_corrente = 'Abaixo da Média' THEN 'Mínima'
                ELSE prioridade_corrente
            END
        WHERE IDU = @IDU;
        
        -- Registrar no histórico
        INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
        VALUES ('Média', 'Abaixo da Média', 'Não levantamento no tempo adequado', GETDATE(), @IDU);
    END;
END;
