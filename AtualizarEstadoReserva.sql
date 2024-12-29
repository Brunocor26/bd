CREATE PROCEDURE UpdateReservationState
@ReservaID CHAR(8), 
@NovoEstado VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Vari�veis para valida��o
        DECLARE @EstadoAtual VARCHAR(20);

        -- Verificar se a reserva existe
        IF NOT EXISTS (SELECT 1 FROM Reserva WHERE IDR = @ReservaID)
        BEGIN
            PRINT 'Erro: Reserva n�o encontrada.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obter o estado atual
        SELECT @EstadoAtual = estado_reserva FROM Reserva WHERE IDR = @ReservaID;

        -- Verificar se o novo estado � v�lido
        IF @NovoEstado NOT IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')
        BEGIN
            PRINT 'Erro: Estado inv�lido.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Prevenir atualiza��es desnecess�rias
        IF @EstadoAtual = @NovoEstado
        BEGIN
            PRINT 'Aviso: O estado j� � igual ao novo estado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Atualizar o estado da reserva
        UPDATE Reserva
        SET estado_reserva = @NovoEstado, timestamp = GETDATE()
        WHERE IDR = @ReservaID;

        PRINT 'Estado da reserva atualizado com sucesso.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        PRINT 'Erro durante a atualiza��o do estado: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
