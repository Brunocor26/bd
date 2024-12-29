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
            PRINT 'Erro: Utilizador n�o encontrado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- L�gica para aumentar a prioridade (utilizando CASE para maior clareza)
        SET @PrioridadeCorrente = CASE
            WHEN @PrioridadeCorrente = 'M�nima' THEN 'Abaixo da M�dia'
            WHEN @PrioridadeCorrente = 'Abaixo da M�dia' THEN 'M�dia'
            WHEN @PrioridadeCorrente = 'M�dia' THEN 'Acima da M�dia'
            WHEN @PrioridadeCorrente = 'Acima da M�dia' THEN 'M�xima'
            ELSE @PrioridadeCorrente
        END;

        -- Garantir que n�o ultrapassa a classe de prioridade
        IF @PrioridadeCorrente > @ClassePrioridade
            SET @PrioridadeCorrente = @ClassePrioridade;

        -- Atualizar a prioridade corrente
        UPDATE Utilizador
        SET prioridade_corrente = @PrioridadeCorrente
        WHERE IDU = @IDU;

        -- Inserir no hist�rico
        INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
        VALUES (@PrioridadeCorrente, @ClassePrioridade, 'Atualiza��o Autom�tica', GETDATE(), @IDU);

        PRINT 'Prioridade atualizada com sucesso.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        PRINT 'Erro durante a atualiza��o da prioridade: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
