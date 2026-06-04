# Guia rápido (Visual Studio + Docker)

## 1) Pré-requisitos
- Visual Studio 2022 com workload **ASP.NET and web development**.
- SQL Server (Developer/Express) e SSMS (ou Azure Data Studio).
- .NET Framework 4.8 targeting pack (normalmente já vem com VS 2022).
- Docker Desktop (opcional, apenas para modo Docker).

## 2) Preparar a base de dados
No SQL Server, execute os scripts nesta ordem:
1. `/tmp/workspace/ruip005/projeto-integradobd1/sql/01_ddl_softinsa_badges.sql`
2. `/tmp/workspace/ruip005/projeto-integradobd1/sql/02_dml_softinsa_badges.sql`
3. `/tmp/workspace/ruip005/projeto-integradobd1/sql/04_objetos_logicos_softinsa_badges.sql` (opcional para lógica adicional)
4. `/tmp/workspace/ruip005/projeto-integradobd1/sql/03_consultas_softinsa_badges.sql` (apenas consultas de validação)

## 3) Configurar ligação da BD (URL/servidor)
Edite:
- `/tmp/workspace/ruip005/projeto-integradobd1/webforms/SoftinsaBadgesWeb/Web.config`

Chave usada pela app:
- `SoftinsaBadgesDb` em `<connectionStrings>`.

Exemplo (Windows Authentication):
- `Data Source=SERVIDOR_SQL;Initial Catalog=SoftinsaBadges;Integrated Security=True;TrustServerCertificate=True`

Exemplo (SQL Authentication):
- `Data Source=SERVIDOR_SQL;Initial Catalog=SoftinsaBadges;User ID=utilizador;[definir password SQL];TrustServerCertificate=True`

## 4) Iniciar o site em debug (Visual Studio)
1. Abrir solução:
   - `/tmp/workspace/ruip005/projeto-integradobd1/webforms/SoftinsaBadgesWeb/SoftinsaBadgesWeb.sln`
2. Definir projeto `SoftinsaBadgesWeb` como Startup Project.
3. Confirmar perfil **IIS Express** no topo do Visual Studio.
4. Pressionar **F5** (Debug) ou **Ctrl+F5** (sem debug).
5. A página principal é `Badges.aspx`.

## 5) Checklist rápido de erros comuns (compilação/debug)
- Erro de ligação SQL:
  - confirmar `Data Source`, base `SoftinsaBadges`, credenciais e firewall.
- Erro de tabelas inexistentes:
  - reexecutar scripts SQL pela ordem indicada.
- Erro de compilação no Visual Studio:
  - confirmar workload ASP.NET instalado.
  - confirmar .NET Framework 4.8 instalado.

## 6) Docker (opcional, se necessário)
> Esta app é ASP.NET Web Forms (.NET Framework 4.8), por isso o container é **Windows** (não Linux).

Ficheiros:
- `/tmp/workspace/ruip005/projeto-integradobd1/webforms/SoftinsaBadgesWeb/Dockerfile.windows`
- `/tmp/workspace/ruip005/projeto-integradobd1/webforms/SoftinsaBadgesWeb/docker-entrypoint.ps1`

Comandos (PowerShell, com Docker Desktop em modo Windows containers):
1. `cd /tmp/workspace/ruip005/projeto-integradobd1/webforms/SoftinsaBadgesWeb`
2. `docker build -f Dockerfile.windows -t softinsa-badges-webforms:latest .`
3. `docker run --rm -p 8080:80 -e SOFTINSA_BADGES_CONNSTR="Data Source=host.docker.internal;Initial Catalog=SoftinsaBadges;User ID=utilizador;[definir password SQL];TrustServerCertificate=True" softinsa-badges-webforms:latest`
4. Abrir `http://localhost:8080/Badges.aspx`

Notas Docker:
- `host.docker.internal` costuma resolver para o host no Docker Desktop.
- Se usar SQL Server com autenticação Windows, normalmente é mais simples usar SQL Authentication no container.

## 7) Validação executada neste ambiente de task
- Foi tentada compilação com:
  - `dotnet msbuild SoftinsaBadgesWeb.sln /t:Build /p:Configuration=Debug`
- Resultado:
  - falha por ausência dos targets de Web Application do Visual Studio neste ambiente Linux (`MSB4057: The target "Build" does not exist in the project`).
- Conclusão:
  - a validação real de compilação/debug desta solução deve ser feita no Visual Studio em Windows.
