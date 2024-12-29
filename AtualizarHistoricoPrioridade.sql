CREATE TRIGGER AtualizarHistoricoPrioridade
ON Utilizador
AFTER UPDATE
AS
BEGIN
    -- Inserir um registro no histórico para cada mudança de prioridade
    INSERT INTO Historico_Prioridade (prioridade_anterior, prioridade_atual, motivo, data, IDU)
    SELECT 
        deleted.prioridade_corrente AS prioridade_anterior,
        inserted.prioridade_corrente AS prioridade_atual,
        'Atualização automática de prioridade' AS motivo,
        GETDATE() AS data,
        inserted.IDU
    FROM 
        inserted
    INNER JOIN 
        deleted ON inserted.IDU = deleted.IDU
    WHERE 
        inserted.prioridade_corrente != deleted.prioridade_corrente; -- Somente se a prioridade mudou
END;
GO
