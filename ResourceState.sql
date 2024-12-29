CREATE VIEW ResourceState AS
SELECT 
    R.IDR AS ResID,
    E.descricao AS ResDesc,
    E.estado_eq AS State,
    U.IDU AS ID,
    U.nome AS Userr
FROM Equipamento E
INNER JOIN Reserva R ON E.IDR = R.IDR
INNER JOIN Utilizador U ON R.IDU = U.IDU;
