CREATE PROCEDURE Reserve2Requisition
@ReservaID CHAR(8)
AS
BEGIN
    -- Verificar se a reserva existe e est� no estado 'Satisfied'
    IF EXISTS (SELECT 1 FROM Reserva WHERE IDR = @ReservaID AND estado_reserva = 'Satisfied')
    BEGIN
        BEGIN TRY
            -- Inserir a requisi��o baseada na reserva
            INSERT INTO Requisicao (estado_req, data_devolucao, data_levantamento)
            VALUES ('Active', GETDATE(), GETDATE());

            PRINT 'Requisi��o criada com sucesso.';
        END TRY
        BEGIN CATCH
            PRINT 'Erro ao criar a requisi��o: ' + ERROR_MESSAGE();
        END CATCH
    END
    ELSE
    BEGIN
        PRINT 'Reserva n�o encontrada ou n�o est� no estado "Satisfied".';
    END
END;
GO
