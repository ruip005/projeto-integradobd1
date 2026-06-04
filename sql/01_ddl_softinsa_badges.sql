/* =========================================================
   01_ddl_softinsa_badges.sql
   Modelo físico completo (SQL Server) - Softinsa Badges
   ========================================================= */

-- DROP (ordem inversa de dependências)
IF OBJECT_ID('dbo.HistoricoEstados', 'U') IS NOT NULL DROP TABLE dbo.HistoricoEstados;
IF OBJECT_ID('dbo.Candidaturas', 'U') IS NOT NULL DROP TABLE dbo.Candidaturas;
IF OBJECT_ID('dbo.Utilizadores', 'U') IS NOT NULL DROP TABLE dbo.Utilizadores;
IF OBJECT_ID('dbo.Badges', 'U') IS NOT NULL DROP TABLE dbo.Badges;
IF OBJECT_ID('dbo.LearningPaths', 'U') IS NOT NULL DROP TABLE dbo.LearningPaths;
IF OBJECT_ID('dbo.Areas', 'U') IS NOT NULL DROP TABLE dbo.Areas;
IF OBJECT_ID('dbo.ServiceLines', 'U') IS NOT NULL DROP TABLE dbo.ServiceLines;
IF OBJECT_ID('dbo.Niveis', 'U') IS NOT NULL DROP TABLE dbo.Niveis;

-- Tabela de níveis de progressão
CREATE TABLE dbo.Niveis (
    IdNivel         INT IDENTITY(1,1) PRIMARY KEY,
    NomeNivel       NVARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT CK_Niveis_NomeNivel CHECK (NomeNivel IN (N'Júnior', N'Intermédio', N'Sénior', N'Especialista', N'Líder'))
);

-- Tabela de Service Lines
CREATE TABLE dbo.ServiceLines (
    IdServiceLine   INT IDENTITY(1,1) PRIMARY KEY,
    NomeServiceLine NVARCHAR(120) NOT NULL UNIQUE
);

-- Tabela de Áreas
CREATE TABLE dbo.Areas (
    IdArea          INT IDENTITY(1,1) PRIMARY KEY,
    NomeArea        NVARCHAR(120) NOT NULL,
    IdServiceLine   INT NOT NULL,
    CONSTRAINT UQ_Areas UNIQUE (NomeArea, IdServiceLine),
    CONSTRAINT FK_Areas_ServiceLines FOREIGN KEY (IdServiceLine)
        REFERENCES dbo.ServiceLines (IdServiceLine)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Learning Paths
CREATE TABLE dbo.LearningPaths (
    IdPath          INT IDENTITY(1,1) PRIMARY KEY,
    NomePath        NVARCHAR(150) NOT NULL,
    IdArea          INT NOT NULL,
    CONSTRAINT UQ_LearningPaths UNIQUE (NomePath, IdArea),
    CONSTRAINT FK_LearningPaths_Areas FOREIGN KEY (IdArea)
        REFERENCES dbo.Areas (IdArea)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Badges
CREATE TABLE dbo.Badges (
    IdBadge         INT IDENTITY(1,1) PRIMARY KEY,
    NomeBadge       NVARCHAR(120) NOT NULL,
    Descricao       NVARCHAR(500) NULL,
    PontosPremio    INT NOT NULL,
    IdPath          INT NOT NULL,
    IdNivel         INT NOT NULL,
    Estado          NVARCHAR(20) NOT NULL,
    DataCriacao     DATETIME2(0) NOT NULL CONSTRAINT DF_Badges_DataCriacao DEFAULT (SYSDATETIME()),
    CONSTRAINT UQ_Badges UNIQUE (NomeBadge, IdPath, IdNivel),
    CONSTRAINT CK_Badges_PontosPremio CHECK (PontosPremio >= 0 AND PontosPremio <= 1000),
    CONSTRAINT CK_Badges_Estado CHECK (Estado IN (N'Ativo', N'Inativo')),
    CONSTRAINT FK_Badges_LearningPaths FOREIGN KEY (IdPath)
        REFERENCES dbo.LearningPaths (IdPath)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Badges_Niveis FOREIGN KEY (IdNivel)
        REFERENCES dbo.Niveis (IdNivel)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Utilizadores
CREATE TABLE dbo.Utilizadores (
    IdUtilizador    INT IDENTITY(1,1) PRIMARY KEY,
    Nome            NVARCHAR(120) NOT NULL,
    Email           NVARCHAR(180) NOT NULL UNIQUE,
    Perfil          NVARCHAR(30) NOT NULL,
    IdArea          INT NULL,
    Ativo           BIT NOT NULL CONSTRAINT DF_Utilizadores_Ativo DEFAULT (1),
    DataCriacao     DATETIME2(0) NOT NULL CONSTRAINT DF_Utilizadores_DataCriacao DEFAULT (SYSDATETIME()),
    CONSTRAINT CK_Utilizadores_Perfil CHECK (Perfil IN (N'Administrador', N'Consultor', N'TalentManager', N'Leader')),
    CONSTRAINT CK_Utilizadores_Email CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT FK_Utilizadores_Areas FOREIGN KEY (IdArea)
        REFERENCES dbo.Areas (IdArea)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Candidaturas
CREATE TABLE dbo.Candidaturas (
    IdCandidatura   INT IDENTITY(1,1) PRIMARY KEY,
    IdUtilizador    INT NOT NULL,
    IdBadge         INT NOT NULL,
    DataSubmissao   DATETIME2(0) NOT NULL CONSTRAINT DF_Candidaturas_DataSubmissao DEFAULT (SYSDATETIME()),
    EvidenciaUrl    NVARCHAR(400) NULL,
    Estado          NVARCHAR(20) NOT NULL,
    DataUltimaAtualizacao DATETIME2(0) NOT NULL CONSTRAINT DF_Candidaturas_DataUltimaAtualizacao DEFAULT (SYSDATETIME()),
    CONSTRAINT CK_Candidaturas_Estado CHECK (Estado IN (N'Open', N'Submitted', N'Em Validacao', N'Aprovado', N'Rejeitado')),
    CONSTRAINT UQ_Candidaturas_UtilizadorBadgeData UNIQUE (IdUtilizador, IdBadge, DataSubmissao),
    CONSTRAINT FK_Candidaturas_Utilizadores FOREIGN KEY (IdUtilizador)
        REFERENCES dbo.Utilizadores (IdUtilizador)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Candidaturas_Badges FOREIGN KEY (IdBadge)
        REFERENCES dbo.Badges (IdBadge)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de histórico de estados
CREATE TABLE dbo.HistoricoEstados (
    IdLog           INT IDENTITY(1,1) PRIMARY KEY,
    IdCandidatura   INT NOT NULL,
    EstadoAnterior  NVARCHAR(20) NULL,
    EstadoNovo      NVARCHAR(20) NOT NULL,
    DataAlteracao   DATETIME2(0) NOT NULL CONSTRAINT DF_HistoricoEstados_DataAlteracao DEFAULT (SYSDATETIME()),
    IdValidador     INT NULL,
    CONSTRAINT CK_HistoricoEstados_EstadoAnterior CHECK (EstadoAnterior IS NULL OR EstadoAnterior IN (N'Open', N'Submitted', N'Em Validacao', N'Aprovado', N'Rejeitado')),
    CONSTRAINT CK_HistoricoEstados_EstadoNovo CHECK (EstadoNovo IN (N'Open', N'Submitted', N'Em Validacao', N'Aprovado', N'Rejeitado')),
    CONSTRAINT FK_HistoricoEstados_Candidaturas FOREIGN KEY (IdCandidatura)
        REFERENCES dbo.Candidaturas (IdCandidatura)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_HistoricoEstados_Utilizadores FOREIGN KEY (IdValidador)
        REFERENCES dbo.Utilizadores (IdUtilizador)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Índices úteis para pesquisa e junções
CREATE INDEX IX_Areas_IdServiceLine ON dbo.Areas (IdServiceLine);
CREATE INDEX IX_LearningPaths_IdArea ON dbo.LearningPaths (IdArea);
CREATE INDEX IX_Badges_IdPath_IdNivel ON dbo.Badges (IdPath, IdNivel);
CREATE INDEX IX_Candidaturas_IdUtilizador_Estado ON dbo.Candidaturas (IdUtilizador, Estado);
CREATE INDEX IX_Candidaturas_IdBadge_Estado ON dbo.Candidaturas (IdBadge, Estado);
CREATE INDEX IX_HistoricoEstados_IdCandidatura ON dbo.HistoricoEstados (IdCandidatura);
