CREATE PROCEDURE UpdateReservationState
@ReservaID CHAR(8), 
@NovoEstado VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Variáveis para validação
        DECLARE @EstadoAtual VARCHAR(20);

        -- Verificar se a reserva existe
        IF NOT EXISTS (SELECT 1 FROM Reserva WHERE IDR = @ReservaID)
        BEGIN
            PRINT 'Erro: Reserva não encontrada.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Obter o estado atual
        SELECT @EstadoAtual = estado_reserva FROM Reserva WHERE IDR = @ReservaID;

        -- Verificar se o novo estado é válido
        IF @NovoEstado NOT IN ('Active', 'Satisfied', 'Canceled', 'Waiting', 'Forgotten')
        BEGIN
            PRINT 'Erro: Estado inválido.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Prevenir atualizações desnecessárias
        IF @EstadoAtual = @NovoEstado
        BEGIN
            PRINT 'Aviso: O estado já é igual ao novo estado.';
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
        PRINT 'Erro durante a atualização do estado: ' + ERROR_MESSAGE();
        ROLLBACK TRANSACTION;
    END CATCH
END;
GO
