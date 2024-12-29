CREATE TRIGGER GerarID_Reserva
ON Reserva
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @IDR VARCHAR(8);
    DECLARE @data DATE;
    DECLARE @numero INT;

    -- Obter a data da inser��o da reserva
    SELECT @data = inicio_uso FROM inserted;

    -- Obter o pr�ximo n�mero sequencial para o ID da reserva
    SELECT @numero = ISNULL(MAX(CAST(SUBSTRING(IDR, 5, 4) AS INT)), 0) + 1
    FROM Reserva
    WHERE YEAR(inicio_uso) = YEAR(@data);

    -- Gerar o IDR com a fun��o MakeID
    SET @IDR = dbo.MakeID(@data, @numero);

    -- Inserir a nova reserva com o ID gerado
    INSERT INTO Reserva (IDR, timestamp, inicio_uso, duracao, estado_reserva, IDU, IDRQ)
    SELECT @IDR, timestamp, inicio_uso, duracao, estado_reserva, IDU, IDRQ
    FROM inserted;
END;
GO
