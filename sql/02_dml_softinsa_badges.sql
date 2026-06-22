/* =========================================================
   02_dml_softinsa_badges.sql
   Dados de teste realistas (mínimo 5 por tabela)
   Pré-requisito: executar 01_ddl_softinsa_badges.sql
   ========================================================= */

INSERT INTO sc25_134.Niveis (NomeNivel)
VALUES
(N'Júnior'),
(N'Intermédio'),
(N'Sénior'),
(N'Especialista'),
(N'Líder');

INSERT INTO sc25_134.ServiceLines (NomeServiceLine)
VALUES
(N'Hybrid Cloud'),
(N'Data & AI'),
(N'Cybersecurity'),
(N'Digital Workplace'),
(N'Enterprise Applications');

INSERT INTO sc25_134.Areas (NomeArea, IdServiceLine)
VALUES
(N'LowCode Outsystems', 5),
(N'Azure Platform', 1),
(N'Data Engineering', 2),
(N'SOC Operations', 3),
(N'M365 Collaboration', 4);

INSERT INTO sc25_134.LearningPaths (NomePath, IdArea)
VALUES
(N'Jornada Técnica Outsystems', 1),
(N'Cloud Engineer Journey', 2),
(N'Data Platform Journey', 3),
(N'SOC Analyst Journey', 4),
(N'Productivity Specialist Journey', 5);

INSERT INTO sc25_134.Badges (NomeBadge, Descricao, PontosPremio, IdPath, IdNivel, Estado)
VALUES
(N'Outsystems Foundations', N'Base de desenvolvimento low-code e boas práticas.', 120, 1, 1, N'Ativo'),
(N'Azure Landing Zones', N'Desenho de landing zones e governance.', 220, 2, 3, N'Ativo'),
(N'Data Pipeline Builder', N'Construção de pipelines robustos em ambiente empresarial.', 180, 3, 2, N'Ativo'),
(N'SIEM Incident Triage', N'Triagem e tratamento de incidentes em SIEM.', 200, 4, 3, N'Ativo'),
(N'M365 Adoption Leader', N'Condução de iniciativas de adoção e colaboração.', 150, 5, 4, N'Inativo');

INSERT INTO sc25_134.Utilizadores (Nome, Email, Perfil, IdArea)
VALUES
(N'Ana Silva', N'ana.silva@softinsa.pt', N'Consultor', 1),
(N'Bruno Costa', N'bruno.costa@softinsa.pt', N'Consultor', 2),
(N'Carla Martins', N'carla.martins@softinsa.pt', N'TalentManager', 3),
(N'Diogo Sousa', N'diogo.sousa@softinsa.pt', N'Leader', 2),
(N'Elsa Ribeiro', N'elsa.ribeiro@softinsa.pt', N'Administrador', 5);

INSERT INTO sc25_134.Candidaturas (IdUtilizador, IdBadge, DataSubmissao, EvidenciaUrl, Estado)
VALUES
(1, 1, DATEADD(DAY, -20, SYSDATETIME()), N'https://evidencias.softinsa.pt/ana/outsystems-foundations', N'Submitted'),
(2, 2, DATEADD(DAY, -10, SYSDATETIME()), N'https://evidencias.softinsa.pt/bruno/azure-landing-zones', N'Em Validacao'),
(1, 3, DATEADD(DAY, -30, SYSDATETIME()), N'https://evidencias.softinsa.pt/ana/data-pipeline-builder', N'Aprovado'),
(2, 4, DATEADD(DAY, -5, SYSDATETIME()), N'https://evidencias.softinsa.pt/bruno/siem-triage', N'Open'),
(1, 5, DATEADD(DAY, -40, SYSDATETIME()), N'https://evidencias.softinsa.pt/ana/m365-adoption', N'Rejeitado');

INSERT INTO sc25_134.HistoricoEstados (IdCandidatura, EstadoAnterior, EstadoNovo, DataAlteracao, IdValidador)
VALUES
(1, N'Open', N'Submitted', DATEADD(DAY, -20, SYSDATETIME()), 3),
(2, N'Submitted', N'Em Validacao', DATEADD(DAY, -9, SYSDATETIME()), 3),
(3, N'Em Validacao', N'Aprovado', DATEADD(DAY, -28, SYSDATETIME()), 4),
(4, NULL, N'Open', DATEADD(DAY, -5, SYSDATETIME()), NULL),
(5, N'Em Validacao', N'Rejeitado', DATEADD(DAY, -39, SYSDATETIME()), 4);
