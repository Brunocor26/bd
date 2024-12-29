CREATE TRIGGER GerarIDU_e_DefinirPrioridade
ON Utilizador
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @tipo_utilizador CHAR(2);
    DECLARE @numero INT;
    DECLARE @IDU VARCHAR(10);  -- Tamanho 10 para IDU (2 para tipo_utilizador + 1 para _ + 7 para o número sequencial)
    DECLARE @classe_prioridade VARCHAR(50);
    DECLARE @prioridade_corrente VARCHAR(50);
    
    -- Obter o tipo de utilizador da inserção
    SELECT @tipo_utilizador = tipo_utilizador FROM inserted;
    
    -- Gerar o IDU no formato XX_0000000
    -- Obter o próximo número sequencial para o tipo de utilizador
    SELECT @numero = ISNULL(MAX(CAST(SUBSTRING(IDU, 4, 7) AS INT)), 0) + 1
    FROM Utilizador
    WHERE tipo_utilizador = @tipo_utilizador;

    -- Gerar o IDU no formato XX_0000000 (7 dígitos para o número sequencial)
    SET @IDU = CONCAT(@tipo_utilizador, '_', FORMAT(@numero, '0000000'));  -- 7 dígitos para o número sequencial

    -- Definir a classe de prioridade com base no tipo de utilizador
    IF @tipo_utilizador = 'PR'  -- Professores
    BEGIN
        SET @classe_prioridade = 'Acima da Média';
    END
    ELSE IF @tipo_utilizador = 'PD'  -- Presidente do Departamento
    BEGIN
        SET @classe_prioridade = 'Máxima';
    END
    ELSE  -- Todos os outros tipos de utilizadores
    BEGIN
        SET @classe_prioridade = 'Média';
    END
    
    -- A prioridade corrente é inicialmente igual à classe de prioridade
    SET @prioridade_corrente = @classe_prioridade;
    
    -- Inserir o novo utilizador com o IDU gerado, classe de prioridade e prioridade corrente definidas
    INSERT INTO Utilizador (IDU, tipo_utilizador, telefone, email, prioridade_corrente, classe_prioridade, nome)
    SELECT @IDU, tipo_utilizador, telefone, email, @prioridade_corrente, @classe_prioridade, nome
    FROM inserted;
END;
GO
