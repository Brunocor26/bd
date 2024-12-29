CREATE TRIGGER AtualizarHistoricoEstado
ON Reserva
AFTER UPDATE
AS
BEGIN
    -- Inserir um registro no hist�rico para cada mudan�a de estado
    INSERT INTO Historico_Estado (estado_anterior, motivo, estado_atual, data_alteracao, IDR)
    SELECT 
        deleted.estado_reserva AS estado_anterior,
        'Mudan�a de estado autom�tica' AS motivo,
        inserted.estado_reserva AS estado_atual,
        GETDATE() AS data_alteracao,
        inserted.IDR
    FROM 
        inserted
    INNER JOIN 
        deleted ON inserted.IDR = deleted.IDR
    WHERE 
        inserted.estado_reserva != deleted.estado_reserva; -- Somente se o estado mudou
END;
GO
