CREATE PROCEDURE PromoverPrioridade
@IDU CHAR(10),
@motivo VARCHAR(100)
AS
BEGIN
    DECLARE @prioridade_atual VARCHAR(50);
    DECLARE @classe_prioridade VARCHAR(50);

    -- Obter a prioridade atual e a classe de prioridade do utilizador
    SELECT @prioridade_atual = prioridade_corrente, @classe_prioridade = classe_prioridade
    FROM Utilizador
    WHERE IDU = @IDU;

    -- Determinar a nova prioridade (subir um n�vel, mas n�o ultrapassar a classe)
    SET @prioridade_atual = CASE 
        WHEN @prioridade_atual = 'M�nima' THEN 'Abaixo da M�dia'
        WHEN @prioridade_atual = 'Abaixo da M�dia' THEN 'M�dia'
        WHEN @prioridade_atual = 'M�dia' THEN 'Acima da M�dia'
        WHEN @prioridade_atual = 'Acima da M�dia' THEN 'M�xima'
        ELSE @prioridade_atual
    END;

    -- Garantir que n�o ultrapassa a classe de prioridade
    IF @prioridade_atual > @classe_prioridade
        SET @prioridade_atual = @classe_prioridade;

    -- Atualizar a prioridade do utilizador
    UPDATE Utilizador
    SET prioridade_corrente = @prioridade_atual
    WHERE IDU = @IDU;

    -- Registrar no hist�rico
    INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
    VALUES (@prioridade_atual, @prioridade_atual, @motivo, GETDATE(), @IDU);
END;
GO
