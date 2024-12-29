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

    -- Determinar a nova prioridade (subir um nível, mas não ultrapassar a classe)
    SET @prioridade_atual = CASE 
        WHEN @prioridade_atual = 'Mínima' THEN 'Abaixo da Média'
        WHEN @prioridade_atual = 'Abaixo da Média' THEN 'Média'
        WHEN @prioridade_atual = 'Média' THEN 'Acima da Média'
        WHEN @prioridade_atual = 'Acima da Média' THEN 'Máxima'
        ELSE @prioridade_atual
    END;

    -- Garantir que não ultrapassa a classe de prioridade
    IF @prioridade_atual > @classe_prioridade
        SET @prioridade_atual = @classe_prioridade;

    -- Atualizar a prioridade do utilizador
    UPDATE Utilizador
    SET prioridade_corrente = @prioridade_atual
    WHERE IDU = @IDU;

    -- Registrar no histórico
    INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
    VALUES (@prioridade_atual, @prioridade_atual, @motivo, GETDATE(), @IDU);
END;
GO
