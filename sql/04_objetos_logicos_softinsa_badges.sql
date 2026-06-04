/* =========================================================
   04_objetos_logicos_softinsa_badges.sql
   PA + UDF + 2 Triggers + Cursor + comandos de teste
   ========================================================= */

/*
Trigger 1: tr_AuditoriaCandidatura
Objetivo:
- Registar automaticamente no histórico cada alteração de estado em Candidaturas.
- Ignorar atualizações sem mudança de estado.
- Permitir bypass controlado por SESSION_CONTEXT (usado pelo PA para evitar registos duplicados).
*/
IF OBJECT_ID('dbo.tr_AuditoriaCandidatura', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_AuditoriaCandidatura;
GO
CREATE TRIGGER dbo.tr_AuditoriaCandidatura
ON dbo.Candidaturas
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF CAST(SESSION_CONTEXT(N'SkipCandidaturaAudit') AS BIT) = 1
        RETURN;

    INSERT INTO dbo.HistoricoEstados (IdCandidatura, EstadoAnterior, EstadoNovo, DataAlteracao, IdValidador)
    SELECT
        i.IdCandidatura,
        d.Estado,
        i.Estado,
        SYSDATETIME(),
        NULL
    FROM inserted i
    INNER JOIN deleted d ON d.IdCandidatura = i.IdCandidatura
    WHERE ISNULL(d.Estado, N'') <> ISNULL(i.Estado, N'');
END;
GO

/*
Trigger 2: tr_ValidarPontosBadge
Objetivo:
- Garantir integridade adicional em INSERT/UPDATE de Badges.
- Impedir pontos negativos ou acima de 1000 com rollback explícito.
*/
IF OBJECT_ID('dbo.tr_ValidarPontosBadge', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_ValidarPontosBadge;
GO
CREATE TRIGGER dbo.tr_ValidarPontosBadge
ON dbo.Badges
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE PontosPremio < 0 OR PontosPremio > 1000
    )
    BEGIN
        THROW 50001, 'PontosPremio inválido: o valor deve estar entre 0 e 1000.', 1;
    END
END;
GO

/*
Função Escalar: fn_CalcularPontosUtilizador
Objetivo:
- Devolver o total de pontos de badges aprovados para um utilizador.
*/
IF OBJECT_ID('dbo.fn_CalcularPontosUtilizador', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalcularPontosUtilizador;
GO
CREATE FUNCTION dbo.fn_CalcularPontosUtilizador (@IdUtilizador INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = ISNULL(SUM(b.PontosPremio), 0)
    FROM dbo.Candidaturas c
    INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
    WHERE c.IdUtilizador = @IdUtilizador
      AND c.Estado = N'Aprovado';

    RETURN ISNULL(@Total, 0);
END;
GO

/*
Procedimento Armazenado: sp_ProcessarFechoCandidatura
Objetivo:
- Processar alteração de estado de candidatura para fecho do workflow.
- Registar histórico com utilizador validador e timestamp.
- Evitar duplicação de histórico ao coordenar com trigger via SESSION_CONTEXT.
*/
IF OBJECT_ID('dbo.sp_ProcessarFechoCandidatura', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ProcessarFechoCandidatura;
GO
CREATE PROCEDURE dbo.sp_ProcessarFechoCandidatura
    @IdCandidatura INT,
    @NovoEstado NVARCHAR(20),
    @IdValidador INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @NovoEstado NOT IN (N'Aprovado', N'Rejeitado')
    BEGIN
        THROW 50002, 'NovoEstado inválido. Utilize apenas Aprovado ou Rejeitado.', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Candidaturas WHERE IdCandidatura = @IdCandidatura)
    BEGIN
        THROW 50003, 'Candidatura não encontrada.', 1;
    END;

    DECLARE @EstadoAnterior NVARCHAR(20);

    SELECT @EstadoAnterior = Estado
    FROM dbo.Candidaturas
    WHERE IdCandidatura = @IdCandidatura;

    IF @EstadoAnterior = @NovoEstado
        RETURN;

    EXEC sys.sp_set_session_context @key = N'SkipCandidaturaAudit', @value = 1;

    UPDATE dbo.Candidaturas
    SET Estado = @NovoEstado,
        DataUltimaAtualizacao = SYSDATETIME()
    WHERE IdCandidatura = @IdCandidatura;

    INSERT INTO dbo.HistoricoEstados (IdCandidatura, EstadoAnterior, EstadoNovo, DataAlteracao, IdValidador)
    VALUES (@IdCandidatura, @EstadoAnterior, @NovoEstado, SYSDATETIME(), @IdValidador);

    EXEC sys.sp_set_session_context @key = N'SkipCandidaturaAudit', @value = NULL;
END;
GO

/*
Cursor SQL: varrer candidaturas Submitted há mais de 15 dias
Objetivo:
- Simular alerta de SLA falhado via PRINT para cada candidatura em atraso.
*/
DECLARE @IdCand INT,
        @NomeUtilizador NVARCHAR(120),
        @NomeBadge NVARCHAR(120),
        @DataSub DATETIME2(0);

DECLARE cur_SLA_Candidaturas CURSOR FAST_FORWARD FOR
SELECT
    c.IdCandidatura,
    u.Nome,
    b.NomeBadge,
    c.DataSubmissao
FROM dbo.Candidaturas c
INNER JOIN dbo.Utilizadores u ON u.IdUtilizador = c.IdUtilizador
INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
WHERE c.Estado = N'Submitted'
  AND c.DataSubmissao < DATEADD(DAY, -15, SYSDATETIME());

OPEN cur_SLA_Candidaturas;
FETCH NEXT FROM cur_SLA_Candidaturas INTO @IdCand, @NomeUtilizador, @NomeBadge, @DataSub;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT(
        'ALERTA SLA: Candidatura #', @IdCand,
        ' (', @NomeUtilizador, ' / ', @NomeBadge,
        ') em Submitted desde ', CONVERT(NVARCHAR(19), @DataSub, 120),
        ' ultrapassou 15 dias.'
    );

    FETCH NEXT FROM cur_SLA_Candidaturas INTO @IdCand, @NomeUtilizador, @NomeBadge, @DataSub;
END;

CLOSE cur_SLA_Candidaturas;
DEALLOCATE cur_SLA_Candidaturas;
GO

/* =========================
   COMANDOS DE TESTE (DEFESA)
   ========================= */

-- Teste Trigger de Auditoria: muda estado para disparar log automático
UPDATE dbo.Candidaturas
SET Estado = N'Em Validacao',
    DataUltimaAtualizacao = SYSDATETIME()
WHERE IdCandidatura = 1;

SELECT TOP (10) *
FROM dbo.HistoricoEstados
WHERE IdCandidatura = 1
ORDER BY IdLog DESC;
GO

-- Teste Trigger de Validação de Pontos: deve falhar
BEGIN TRY
    INSERT INTO dbo.Badges (NomeBadge, Descricao, PontosPremio, IdPath, IdNivel, Estado)
    VALUES (N'Badge Inválido', N'Teste de trigger', 5000, 1, 1, N'Ativo');
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Teste UDF
SELECT dbo.fn_CalcularPontosUtilizador(1) AS PontosUtilizador1;
GO

-- Teste PA
EXEC dbo.sp_ProcessarFechoCandidatura
    @IdCandidatura = 2,
    @NovoEstado = N'Aprovado',
    @IdValidador = 4;

SELECT TOP (10) *
FROM dbo.HistoricoEstados
WHERE IdCandidatura = 2
ORDER BY IdLog DESC;
GO

-- Teste cursor: reexecutar bloco do cursor para imprimir alertas atuais
DECLARE @IdCandTeste INT,
        @NomeUtilizadorTeste NVARCHAR(120),
        @NomeBadgeTeste NVARCHAR(120),
        @DataSubTeste DATETIME2(0);

DECLARE cur_SLA_Candidaturas_Teste CURSOR FAST_FORWARD FOR
SELECT c.IdCandidatura, u.Nome, b.NomeBadge, c.DataSubmissao
FROM dbo.Candidaturas c
INNER JOIN dbo.Utilizadores u ON u.IdUtilizador = c.IdUtilizador
INNER JOIN dbo.Badges b ON b.IdBadge = c.IdBadge
WHERE c.Estado = N'Submitted'
  AND c.DataSubmissao < DATEADD(DAY, -15, SYSDATETIME());

OPEN cur_SLA_Candidaturas_Teste;
FETCH NEXT FROM cur_SLA_Candidaturas_Teste INTO @IdCandTeste, @NomeUtilizadorTeste, @NomeBadgeTeste, @DataSubTeste;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CONCAT('ALERTA SLA(TESTE): #', @IdCandTeste, ' - ', @NomeUtilizadorTeste, ' - ', @NomeBadgeTeste);
    FETCH NEXT FROM cur_SLA_Candidaturas_Teste INTO @IdCandTeste, @NomeUtilizadorTeste, @NomeBadgeTeste, @DataSubTeste;
END;

CLOSE cur_SLA_Candidaturas_Teste;
DEALLOCATE cur_SLA_Candidaturas_Teste;
GO
