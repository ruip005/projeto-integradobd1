/* =========================================================
   03_consultas_softinsa_badges.sql
   Consultas obrigatórias: JOINs, agregações, HAVING e subconsultas
   ========================================================= */

-- 1) INNER JOIN: candidaturas com utilizador, badge e learning path
SELECT
    c.IdCandidatura,
    u.Nome AS Utilizador,
    b.NomeBadge,
    lp.NomePath,
    c.Estado,
    c.DataSubmissao
FROM dbo.Candidaturas c
INNER JOIN dbo.Utilizadores u ON u.IdUtilizador = c.IdUtilizador
INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
INNER JOIN dbo.LearningPaths lp ON lp.IdPath = b.IdPath
ORDER BY c.DataSubmissao DESC;

-- 2) LEFT JOIN: consultores e as suas candidaturas (inclui quem não tem)
SELECT
    u.IdUtilizador,
    u.Nome,
    u.Email,
    c.IdCandidatura,
    c.Estado,
    c.DataSubmissao
FROM dbo.Utilizadores u
LEFT JOIN dbo.Candidaturas c ON c.IdUtilizador = u.IdUtilizador
WHERE u.Perfil = N'Consultor'
ORDER BY u.Nome, c.DataSubmissao;

-- 3) Agregação geral: total candidaturas e pontos por estado
SELECT
    c.Estado,
    COUNT(*) AS TotalCandidaturas,
    SUM(b.PontosPremio) AS SomaPontos,
    AVG(CAST(b.PontosPremio AS DECIMAL(10,2))) AS MediaPontos
FROM dbo.Candidaturas c
INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
GROUP BY c.Estado
ORDER BY TotalCandidaturas DESC;

-- 4) GROUP BY + HAVING: learning paths com mais de 1 badge ativo
SELECT
    lp.IdPath,
    lp.NomePath,
    COUNT(*) AS TotalBadgesAtivos
FROM dbo.LearningPaths lp
INNER JOIN dbo.Badges b ON b.IdPath = lp.IdPath
WHERE b.Estado = N'Ativo'
GROUP BY lp.IdPath, lp.NomePath
HAVING COUNT(*) > 1
ORDER BY TotalBadgesAtivos DESC;

-- 5) Subconsulta no WHERE: utilizadores com pontos aprovados acima da média global
SELECT
    u.IdUtilizador,
    u.Nome,
    SUM(b.PontosPremio) AS PontosAprovados
FROM dbo.Utilizadores u
INNER JOIN dbo.Candidaturas c ON c.IdUtilizador = u.IdUtilizador
INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
WHERE c.Estado = N'Aprovado'
GROUP BY u.IdUtilizador, u.Nome
HAVING SUM(b.PontosPremio) > (
    SELECT AVG(TotalPorUtilizador)
    FROM (
        SELECT SUM(b2.PontosPremio) AS TotalPorUtilizador
        FROM dbo.Candidaturas c2
        INNER JOIN dbo.Badges b2 ON b2.IdBadge = c2.IdBadge
        WHERE c2.Estado = N'Aprovado'
        GROUP BY c2.IdUtilizador
    ) AS X
);

-- 6) Subconsulta no FROM: ranking de utilizadores por candidaturas aprovadas
SELECT
    R.IdUtilizador,
    R.Nome,
    R.TotalAprovadas,
    R.TotalPontos
FROM (
    SELECT
        u.IdUtilizador,
        u.Nome,
        COUNT(*) AS TotalAprovadas,
        SUM(b.PontosPremio) AS TotalPontos
    FROM dbo.Utilizadores u
    INNER JOIN dbo.Candidaturas c ON c.IdUtilizador = u.IdUtilizador
    INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
    WHERE c.Estado = N'Aprovado'
    GROUP BY u.IdUtilizador, u.Nome
) AS R
ORDER BY R.TotalPontos DESC, R.TotalAprovadas DESC;
