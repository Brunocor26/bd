CREATE TRIGGER PenalizarPorAtraso
ON Reserva
AFTER UPDATE
AS
BEGIN
    -- Penalizar utilizadores quando a reserva passa para "Forgotten"
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE estado_reserva = 'Forgotten'
    )
    BEGIN
        DECLARE @IDU CHAR(10);
        SELECT @IDU = IDU
        FROM inserted
        WHERE estado_reserva = 'Forgotten';

        -- Chamar o procedimento para penalizar a prioridade
        EXEC PenalizarPrioridade @IDU, 'Reserva esquecida';
    END;
END;
GO
