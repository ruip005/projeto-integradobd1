/* =========================================================
   01_ddl_softinsa_badges.sql
   Modelo físico completo (SQL Server) - Softinsa Badges
   ========================================================= */

-- DROP (ordem inversa de dependências)
IF OBJECT_ID('sc25_134.HistoricoEstados', 'U') IS NOT NULL DROP TABLE sc25_134.HistoricoEstados;
IF OBJECT_ID('sc25_134.Candidaturas', 'U') IS NOT NULL DROP TABLE sc25_134.Candidaturas;
IF OBJECT_ID('sc25_134.Utilizadores', 'U') IS NOT NULL DROP TABLE sc25_134.Utilizadores;
IF OBJECT_ID('sc25_134.Badges', 'U') IS NOT NULL DROP TABLE sc25_134.Badges;
IF OBJECT_ID('sc25_134.LearningPaths', 'U') IS NOT NULL DROP TABLE sc25_134.LearningPaths;
IF OBJECT_ID('sc25_134.Areas', 'U') IS NOT NULL DROP TABLE sc25_134.Areas;
IF OBJECT_ID('sc25_134.ServiceLines', 'U') IS NOT NULL DROP TABLE sc25_134.ServiceLines;
IF OBJECT_ID('sc25_134.Niveis', 'U') IS NOT NULL DROP TABLE sc25_134.Niveis;

-- Tabela de níveis de progressão
CREATE TABLE sc25_134.Niveis (
    IdNivel         INT IDENTITY(1,1) PRIMARY KEY,
    NomeNivel       NVARCHAR(30) NOT NULL UNIQUE,
    CONSTRAINT CK_Niveis_NomeNivel CHECK (NomeNivel IN (N'Júnior', N'Intermédio', N'Sénior', N'Especialista', N'Líder'))
);

-- Tabela de Service Lines
CREATE TABLE sc25_134.ServiceLines (
    IdServiceLine   INT IDENTITY(1,1) PRIMARY KEY,
    NomeServiceLine NVARCHAR(120) NOT NULL UNIQUE
);

-- Tabela de Áreas
CREATE TABLE sc25_134.Areas (
    IdArea          INT IDENTITY(1,1) PRIMARY KEY,
    NomeArea        NVARCHAR(120) NOT NULL,
    IdServiceLine   INT NOT NULL,
    CONSTRAINT UQ_Areas UNIQUE (NomeArea, IdServiceLine),
    CONSTRAINT FK_Areas_ServiceLines FOREIGN KEY (IdServiceLine)
        REFERENCES sc25_134.ServiceLines (IdServiceLine)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Learning Paths
CREATE TABLE sc25_134.LearningPaths (
    IdPath          INT IDENTITY(1,1) PRIMARY KEY,
    NomePath        NVARCHAR(150) NOT NULL,
    IdArea          INT NOT NULL,
    CONSTRAINT UQ_LearningPaths UNIQUE (NomePath, IdArea),
    CONSTRAINT FK_LearningPaths_Areas FOREIGN KEY (IdArea)
        REFERENCES sc25_134.Areas (IdArea)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Badges
CREATE TABLE sc25_134.Badges (
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
        REFERENCES sc25_134.LearningPaths (IdPath)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Badges_Niveis FOREIGN KEY (IdNivel)
        REFERENCES sc25_134.Niveis (IdNivel)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Utilizadores
CREATE TABLE sc25_134.Utilizadores (
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
        REFERENCES sc25_134.Areas (IdArea)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de Candidaturas
CREATE TABLE sc25_134.Candidaturas (
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
        REFERENCES sc25_134.Utilizadores (IdUtilizador)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_Candidaturas_Badges FOREIGN KEY (IdBadge)
        REFERENCES sc25_134.Badges (IdBadge)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Tabela de histórico de estados
CREATE TABLE sc25_134.HistoricoEstados (
    IdLog           INT IDENTITY(1,1) PRIMARY KEY,
    IdCandidatura   INT NOT NULL,
    EstadoAnterior  NVARCHAR(20) NULL,
    EstadoNovo      NVARCHAR(20) NOT NULL,
    DataAlteracao   DATETIME2(0) NOT NULL CONSTRAINT DF_HistoricoEstados_DataAlteracao DEFAULT (SYSDATETIME()),
    IdValidador     INT NULL,
    CONSTRAINT CK_HistoricoEstados_EstadoAnterior CHECK (EstadoAnterior IS NULL OR EstadoAnterior IN (N'Open', N'Submitted', N'Em Validacao', N'Aprovado', N'Rejeitado')),
    CONSTRAINT CK_HistoricoEstados_EstadoNovo CHECK (EstadoNovo IN (N'Open', N'Submitted', N'Em Validacao', N'Aprovado', N'Rejeitado')),
    CONSTRAINT FK_HistoricoEstados_Candidaturas FOREIGN KEY (IdCandidatura)
        REFERENCES sc25_134.Candidaturas (IdCandidatura)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT FK_HistoricoEstados_Utilizadores FOREIGN KEY (IdValidador)
        REFERENCES sc25_134.Utilizadores (IdUtilizador)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

-- Índices úteis para pesquisa e junções
CREATE INDEX IX_Areas_IdServiceLine ON sc25_134.Areas (IdServiceLine);
CREATE INDEX IX_LearningPaths_IdArea ON sc25_134.LearningPaths (IdArea);
CREATE INDEX IX_Badges_IdPath_IdNivel ON sc25_134.Badges (IdPath, IdNivel);
CREATE INDEX IX_Candidaturas_IdUtilizador_Estado ON sc25_134.Candidaturas (IdUtilizador, Estado);
CREATE INDEX IX_Candidaturas_IdBadge_Estado ON sc25_134.Candidaturas (IdBadge, Estado);
CREATE INDEX IX_HistoricoEstados_IdCandidatura ON sc25_134.HistoricoEstados (IdCandidatura);
