CREATE TRIGGER GerarIDU_auto
ON Utilizador
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @tipo_utilizador CHAR(2);
    DECLARE @numero INT;
    DECLARE @IDU VARCHAR(10);  -- Tamanho 10 para IDU (2 para tipo_utilizador + 1 para _ + 7 para o número sequencial)
    
    -- Obter o tipo de utilizador da inserção
    SELECT @tipo_utilizador = tipo_utilizador FROM inserted;

    -- Obter o próximo número sequencial para o tipo de utilizador
    SELECT @numero = ISNULL(MAX(CAST(SUBSTRING(IDU, 4, 7) AS INT)), 0) + 1
    FROM Utilizador
    WHERE tipo_utilizador = @tipo_utilizador;

    -- Gerar o IDU no formato XX_0000000 (com 7 dígitos no número sequencial)
    SET @IDU = CONCAT(@tipo_utilizador, '_', FORMAT(@numero, '0000000'));  -- 7 dígitos para o número sequencial

    -- Verificar se o IDU gerado já existe na tabela
    IF EXISTS (SELECT 1 FROM Utilizador WHERE IDU = @IDU)
    BEGIN
        -- Se o IDU já existe, gerar um novo número sequencial
        SET @numero = @numero + 1;
        SET @IDU = CONCAT(@tipo_utilizador, '_', FORMAT(@numero, '0000000'));
    END

    -- Inserir o novo registro com o valor gerado para IDU
    INSERT INTO Utilizador (IDU, tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome)
    SELECT @IDU, tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome
    FROM inserted;
END;
GO
