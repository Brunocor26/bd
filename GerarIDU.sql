CREATE TRIGGER GerarIDU_auto
ON Utilizador
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @tipo_utilizador CHAR(2);
    DECLARE @numero INT;
    DECLARE @IDU VARCHAR(10);  -- Tamanho 10 para IDU (2 para tipo_utilizador + 1 para _ + 7 para o n�mero sequencial)
    
    -- Obter o tipo de utilizador da inser��o
    SELECT @tipo_utilizador = tipo_utilizador FROM inserted;

    -- Obter o pr�ximo n�mero sequencial para o tipo de utilizador
    SELECT @numero = ISNULL(MAX(CAST(SUBSTRING(IDU, 4, 7) AS INT)), 0) + 1
    FROM Utilizador
    WHERE tipo_utilizador = @tipo_utilizador;

    -- Gerar o IDU no formato XX_0000000 (com 7 d�gitos no n�mero sequencial)
    SET @IDU = CONCAT(@tipo_utilizador, '_', FORMAT(@numero, '0000000'));  -- 7 d�gitos para o n�mero sequencial

    -- Verificar se o IDU gerado j� existe na tabela
    IF EXISTS (SELECT 1 FROM Utilizador WHERE IDU = @IDU)
    BEGIN
        -- Se o IDU j� existe, gerar um novo n�mero sequencial
        SET @numero = @numero + 1;
        SET @IDU = CONCAT(@tipo_utilizador, '_', FORMAT(@numero, '0000000'));
    END

    -- Inserir o novo registro com o valor gerado para IDU
    INSERT INTO Utilizador (IDU, tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome)
    SELECT @IDU, tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome
    FROM inserted;
END;
GO
