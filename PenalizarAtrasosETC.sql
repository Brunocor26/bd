CREATE PROCEDURE PenalizarPrioridade
@IDU CHAR(10),
@motivo VARCHAR(100)
AS
BEGIN
    DECLARE @prioridade_atual VARCHAR(50);

    -- Obter a prioridade atual do utilizador
    SELECT @prioridade_atual = prioridade_corrente
    FROM Utilizador
    WHERE IDU = @IDU;

    -- Determinar a nova prioridade (descer um n�vel, se poss�vel)
    SET @prioridade_atual = CASE 
        WHEN @prioridade_atual = 'M�xima' THEN 'Acima da M�dia'
        WHEN @prioridade_atual = 'Acima da M�dia' THEN 'M�dia'
        WHEN @prioridade_atual = 'M�dia' THEN 'Abaixo da M�dia'
        WHEN @prioridade_atual = 'Abaixo da M�dia' THEN 'M�nima'
        ELSE @prioridade_atual
    END;

    -- Atualizar a prioridade do utilizador
    UPDATE Utilizador
    SET prioridade_corrente = @prioridade_atual
    WHERE IDU = @IDU;

    -- Registrar no hist�rico
    INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
    VALUES ((SELECT prioridade_corrente FROM Utilizador WHERE IDU = @IDU), @prioridade_atual, @motivo, GETDATE(), @IDU);
END;
GO
