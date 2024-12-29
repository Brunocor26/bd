CREATE TRIGGER trg_AlterarPrioridade
ON Reserva
AFTER UPDATE
AS
BEGIN
    DECLARE @estado_reserva VARCHAR(50);
    DECLARE @IDU CHAR(10);

    -- Obter o estado da reserva e o ID do utilizador
    SELECT @estado_reserva = estado_reserva, @IDU = IDU FROM inserted;

    -- Se a reserva for 'Active' ou 'Waiting' e o utilizador n�o levantou o equipamento at� o final do per�odo
    IF (@estado_reserva IN ('Active', 'Waiting'))
    BEGIN
        -- Atualizar a prioridade do utilizador (descer um n�vel se n�o levantou o equipamento)
        UPDATE Utilizador
        SET prioridade_corrente = 
            CASE 
                WHEN prioridade_corrente = 'M�dia' THEN 'Abaixo da M�dia'
                WHEN prioridade_corrente = 'Abaixo da M�dia' THEN 'M�nima'
                ELSE prioridade_corrente
            END
        WHERE IDU = @IDU;
        
        -- Registrar no hist�rico
        INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
        VALUES ('M�dia', 'Abaixo da M�dia', 'N�o levantamento no tempo adequado', GETDATE(), @IDU);
    END;
END;
