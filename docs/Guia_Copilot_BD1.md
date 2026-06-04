# GUIA DE CONTEXTO E PROMPTS PARA GITHUB COPILOT
## Disciplina: Base de Dados I (ESTGV) - Projeto Softinsa Badges (Regime Especial)

Este arquivo serve como contexto mestre para alimentares o GitHub Copilot. Copia e cola as secções relevantes ou este ficheiro inteiro na chatbox do Copilot (ou usa como `@workspace` / `#file` no VS Code/Visual Studio) para garantir que ele gera código 100% alinhado com as exigências dos professores.

---

## 1. CONTEXTO DO PROJETO E REGRAS DE OURO
* **Tema Global:** Plataforma de Badges da Softinsa (Gestão de competências, Learning Paths, Candidaturas e Gamificação).
* **Regime do Grupo:** O grupo tem equivalência a *Projeto Integrado*. Portanto, a modelação da Base de Dados (SQL) engloba todo o enunciado da Softinsa, mas a interface no **Visual Studio (ASP.NET Web Forms / ADO.NET)** deve manipular **APENAS UMA TABELA** (Tabela escolhida: `Badges`).
* **Tecnologias Obrigatórias:**
  * **Base de Dados:** Microsoft SQL Server (Transact-SQL).
  * **Interface Cliente-Servidor:** Visual Studio 2022, utilizando C# com **ASP.NET Web Forms (.aspx)** e arquitetura **ADO.NET Puro** (Classes `SqlConnection`, `SqlCommand`, `SqlDataReader`, `SqlDataAdapter`). *PROIBIDO usar Entity Framework ou outros ORMs.*
  * **Arquitetura de Código (Tarefa T_ASP_4):** É obrigatório criar uma classe dedicada para manipulação de dados remotos (Ex: `GestorDados.cs`).

---

## 2. PROMPT MESTRE PARA O SCRIPT SQL (DDL e DML)
*Copia o prompt abaixo para gerar a estrutura de tabelas e dados de teste:*

> **PROMPT PARA O COPILOT:**
> "Atua como um DBA especialista em Microsoft SQL Server (T-SQL). Preciso do script SQL completo (DDL de criação e eliminação ordenada, e DML com dados de teste) para o projeto 'Plataforma de Badges da Softinsa'. 
> O modelo deve respeitar as seguintes entidades e restrições de integridade (PKs, FKs, Cheques, Not Null):
> 1. `Niveis` (IdNivel, NomeNivel [Júnior, Intermédio, Sénior, Especialista, Líder])
> 2. `ServiceLines` (IdServiceLine, NomeServiceLine)
> 3. `Areas` (IdArea, NomeArea, IdServiceLine FK)
> 4. `LearningPaths` (IdPath, NomePath, IdArea FK)
> 5. `Badges` (IdBadge, NomeBadge, Descricao, PontosPremio, IdPath FK, IdNivel FK, Estado [Ativo, Inativo])
> 6. `Utilizadores` (IdUtilizador, Nome, Email, Perfil [Administrador, Consultor, TalentManager, Leader], IdArea FK)
> 7. `Candidaturas` (IdCandidatura, IdUtilizador FK, IdBadge FK, DataSubmissao, EvidenciaUrl, Estado [Open, Submitted, Em Validacao, Aprovado, Rejeitado])
> 8. `HistoricoEstados` (IdLog, IdCandidatura FK, EstadoAnterior, EstadoNovo, DataAlteracao, IdValidador FK)
> 
> Garante que o script DDL apaga as tabelas na ordem inversa (usando `IF OBJECT_ID... DROP TABLE`) para evitar erros de FK. O script DML deve conter pelo menos 5 registos realistas por tabela."

---

## 3. PROMPT MESTRE PARA OBJETOS LÓGICOS SQL (Triggers, PAs, Funções, Cursor)
*Copia este prompt para gerar a lógica avançada exigida na avaliação:*

> **PROMPT PARA O COPILOT:**
> "Com base no esquema de tabelas anterior da Softinsa Badges, gera um script T-SQL contendo os seguintes objetos lógicos sem erros. Cada objeto deve ser precedido por um comentário explicativo (`--`) e, MUITO IMPORTANTE, deves incluir no fim do script os comandos exatos de teste (`EXEC`, `INSERT`, `UPDATE` ou `SELECT`) para demonstrar o funcionamento de cada um na defesa:
> 
> 1. **Consultas Complexas:**
>    - 1 Query com `INNER JOIN` e 1 com `LEFT OUTER JOIN` (ex: listar consultores e as suas candidaturas, mesmo os que não têm nenhuma).
>    - 1 Query com agrupamento (`GROUP BY`), funções de agregação (`COUNT`, `SUM`) e filtro `HAVING` (ex: listar caminhos de aprendizagem com mais de 3 badges ativos).
>    - 2 Subconsultas: uma na cláusula `WHERE` (ex: utilizadores que submeteram candidaturas acima da média de pontos) e outra noutra cláusula (ex: `SELECT` ou `FROM`).
> 
> 2. **Procedimento Armazenado (PA) de Processamento:** >    - Um PA chamado `sp_ProcessarFechoCandidatura` que recebe `IdCandidatura` e `NovoEstado`. Se for 'Aprovado', deve atualizar o estado e registar o histórico. (Lógica de negócio pura, não CRUD simples).
> 
> 3. **Função (UDF):**
>    - Uma função escalar `fn_CalcularPontosUtilizador` que recebe o `IdUtilizador` e devolve o somatório total de `PontosPremio` de todos os badges cujas candidaturas foram aprovadas.
> 
> 4. **Triggers (Gatilhos) - Mínimo 2:**
>    - `tr_AuditoriaCandidatura`: AFTER UPDATE na tabela `Candidaturas`. Sempre que o estado mudar, insere automaticamente uma linha na tabela `HistoricoEstados`.
>    - `tr_ValidarPontosBadge`: BEFORE/INSTEAD OF ou AFTER INSERT/UPDATE que impeça que um Badge seja criado com pontos negativos ou superiores a 1000.
> 
> 5. **Cursor SQL:**
>    - Um cursor para percorrer todas as candidaturas no estado 'Submitted' há mais de 15 dias e imprimir uma mensagem de aviso no console do SQL Server simulando um alerta de SLA falhado."

---

## 4. PROMPT MESTRE PARA VISUAL STUDIO (Classe T_ASP_4 e Interface Web Forms)
*Usa este bloco para construir a aplicação C# focada na tabela única (`Badges`).*

> **PROMPT PARA O COPILOT:**
> "Preciso de desenvolver o projeto Cliente-Servidor em Visual Studio usando C# e ASP.NET Web Forms (.NET Framework) focado exclusivamente na manipulação da tabela `Badges`. Cria a estrutura com base nas seguintes diretivas:
> 
> 1. **Classe de Dados Remotos (Diretiva T_ASP_4):** Desenha a classe `GestorDados.cs` com ADO.NET puro. Deve conter:
>    - String de conexão obtida do `Web.config`.
>    - Método `DataTable ObterBadges(string filtroPesquisa)` usando `SqlDataAdapter`.
>    - Métodos `bool InserirBadge(string nome, string desc, int pontos, int idPath, int idNivel, string estado)`.
>    - Métodos `bool AtualizarBadge(int id, string nome, string desc, int pontos, string estado)`.
>    - Método `bool EliminarBadge(int id)`.
> 
> 2. **Interface Web Forms (Badges.aspx):** >    - Cria o código HTML/ASPX com um campo de texto (`txtPesquisa`) e um botão (`btnPesquisa`).
>    - Uma `GridView` para listar os badges com colunas explícitas e botões de 'Selecionar' ou 'Eliminar'.
>    - Um formulário abaixo com inputs (`TextBox`, `DropDownList` para chaves estrangeiras) para permitir a criação e edição de registos.
> 
> 3. **Code-Behind (Badges.aspx.cs):**
>    - Implementa o evento `Page_Load` para carregar a GridView chamando a classe `GestorDados`.
>    - Implementa o clique do botão de pesquisa passando o filtro à classe de dados.
>    - Implementa os eventos dos botões Inserir, Atualizar e Eliminar, garantindo que a GridView é atualizada após cada operação com sucesso."

---

## 5. DICAS OPERACIONAIS PARA TRABALHAR COM O COPILOT
1. **Geração por etapas:** Não peças tudo de uma vez. Executa primeiro o script das tabelas, valida-o no SSMS e depois passa para os objetos lógicos.
2. **Correção de Erros:** Se o SQL Server der erro num Trigger ou Cursor, copia o erro exato e envia para o Copilot com o comando: *"O SQL Server retornou este erro: [COLAR ERRO]. Corrige o script acima mantendo a estrutura original."*
3. **Imagens para o Relatório:** Lembra-te que o Copilot não gera os teus prints de ecrã. Executa a página no teu browser local e tira screenshots nítidos do CRUD a funcionar (Inserir, Filtrar na GridView, Alterar e Apagar) para o relatório técnico em PDF.
