CREATE FUNCTION MakeID (@data DATE, @numero INT)
RETURNS CHAR(8)
AS
BEGIN
    DECLARE @ano VARCHAR(4);
    DECLARE @id_ano INT;
    DECLARE @id_reserva VARCHAR(8);

    -- Extrair o ano da data fornecida
    SET @ano = YEAR(@data);
    
    -- Gerar o ID sequencial (número fornecido)
    SET @id_reserva = CONCAT(@ano, RIGHT('0000' + CAST(@numero AS VARCHAR(4)), 4));

    RETURN @id_reserva;
END;
