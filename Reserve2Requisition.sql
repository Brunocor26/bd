CREATE PROCEDURE Reserve2Requisition
@ReservaID CHAR(8)
AS
BEGIN
    -- Verificar se a reserva existe e está no estado 'Satisfied'
    IF EXISTS (SELECT 1 FROM Reserva WHERE IDR = @ReservaID AND estado_reserva = 'Satisfied')
    BEGIN
        BEGIN TRY
            -- Inserir a requisição baseada na reserva
            INSERT INTO Requisicao (estado_req, data_devolucao, data_levantamento)
            VALUES ('Active', GETDATE(), GETDATE());

            PRINT 'Requisição criada com sucesso.';
        END TRY
        BEGIN CATCH
            PRINT 'Erro ao criar a requisição: ' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'Reserva não encontrada ou não está no estado "Satisfied".';
    END
END;
GO
