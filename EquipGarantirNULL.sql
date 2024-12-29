CREATE TRIGGER TR_Equipamento_Disponivel
ON Equipamento
AFTER INSERT, UPDATE
AS
BEGIN
    -- Atualiza os registos com estado "Dispon�vel" para garantir que IDRQ e IDR sejam NULL
    UPDATE Equipamento
    SET IDRQ = NULL, IDR = NULL
    WHERE estado_eq = 'Dispon�vel' AND (IDRQ IS NOT NULL OR IDR IS NOT NULL);
END;
GO

--se o equipamento est� disponivel, este trigger garante que as suas FK s�o NULL