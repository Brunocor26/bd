CREATE TRIGGER trg_UpdateReservaToSatisfied
ON Reserva
AFTER UPDATE
AS
BEGIN
    DECLARE @estado_reserva VARCHAR(50);
    DECLARE @IDR CHAR(8);

    -- Obter o novo estado e o ID da reserva
    SELECT @estado_reserva = estado_reserva, @IDR = IDR FROM inserted;

    -- Se a reserva foi para 'Satisfied', chamamos o procedimento Reserve2Requisition
    IF @estado_reserva = 'Satisfied'
    BEGIN
        EXEC Reserve2Requisition @IDR;
    END;
END;
