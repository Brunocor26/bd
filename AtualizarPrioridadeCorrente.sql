CREATE PROCEDURE AtualizarPrioridadeCorrente
@IDU VARCHAR(10)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PrioridadeCorrente VARCHAR(50);
        DECLARE @ClassePrioridade VARCHAR(50);

        -- Obter prioridade atual e classe
        SELECT @PrioridadeCorrente = prioridade_corrente, @ClassePrioridade = classe_prioridade
        FROM Utilizador
        WHERE IDU = @IDU;

        -- Verificar se o utilizador existe
        IF @PrioridadeCorrente IS NULL OR @ClassePrioridade IS NULL
        BEGIN
            PRINT 'Erro: Utilizador não encontrado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Lógica para aumentar a prioridade (utilizando CASE para maior clareza)
        SET @PrioridadeCorrente = CASE
            WHEN @PrioridadeCorrente = 'Mínima' THEN 'Abaixo da Média'
            WHEN @PrioridadeCorrente = 'Abaixo da Média' THEN 'Média'
            WHEN @PrioridadeCorrente = 'Média' THEN 'Acima da Média'
            WHEN @PrioridadeCorrente = 'Acima da Média' THEN 'Máxima'
            ELSE @PrioridadeCorrente
        END;

        -- Garantir que não ultrapassa a classe de prioridade
        IF @PrioridadeCorrente > @ClassePrioridade
            SET @PrioridadeCorrente = @ClassePrioridade;

        -- Atualizar a prioridade corrente
        UPDATE Utilizador
        SET prioridade_corrente = @PrioridadeCorrente
        WHERE IDU = @IDU;

        -- Inserir no histórico
        INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
        VALUES (@PrioridadeCorrente, @ClassePrioridade, 'Atualização Automática', GETDATE(), @IDU);

        PRINT 'Prioridade atualizada com sucesso.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        PRINT 'Erro durante a atualização da prioridade: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
