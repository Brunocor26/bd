CREATE PROCEDURE Reserve2Requisition
@ReservaID CHAR(8)
AS
BEGIN
    -- Verificar se a reserva existe e está no estado 'Satisfied'
    IF EXISTS (SELECT 1 FROM Reserva WHERE IDR = @ReservaID AND estado_reserva = 'Satisfied')
    BEGIN
        BEGIN TRY
			-- armazenar o valor de inicio_uso
            DECLARE @InicioUso DATETIME;

            -- obter o valor de inicio_uso da reserva
            SELECT @InicioUso = inicio_uso 
            FROM Reserva
            WHERE IDR = @ReservaID;

            -- inserir a requisição baseada na reserva
            INSERT INTO Requisicao (estado_req, data_devolucao, data_levantamento, IDR)
            VALUES ('Active', NULL, @InicioUso, @ReservaID);

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
