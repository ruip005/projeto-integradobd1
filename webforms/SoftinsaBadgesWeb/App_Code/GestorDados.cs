using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace SoftinsaBadgesWeb.App_Code
{
    public class GestorDados
    {
        private readonly string _connectionString;

        public GestorDados()
        {
            ConnectionStringSettings cs = ConfigurationManager.ConnectionStrings["MinhaBD"];

            if (cs == null)
            {
                throw new InvalidOperationException(
                    "Connection string 'SoftinsaBadgesDb' não encontrada em Web.config.");
            }

            _connectionString = cs.ConnectionString;
        }

        public DataTable ObterBadges(string filtroPesquisa)
        {
            var tabela = new DataTable();

            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT
                    b.IdBadge,
                    b.NomeBadge,
                    b.Descricao,
                    b.PontosPremio,
                    b.IdPath,
                    lp.NomePath,
                    b.IdNivel,
                    n.NomeNivel,
                    b.Estado
                FROM sc25_134.Badges b
                INNER JOIN sc25_134.LearningPaths lp ON lp.IdPath = b.IdPath
                INNER JOIN sc25_134.Niveis n ON n.IdNivel = b.IdNivel
                WHERE (@Filtro = '' OR b.NomeBadge LIKE '%' + @Filtro + '%' OR b.Descricao LIKE '%' + @Filtro + '%')
                ORDER BY b.IdBadge DESC;", connection))
            using (var adapter = new SqlDataAdapter(command))
            {
                command.Parameters.Add("@Filtro", SqlDbType.NVarChar, 120).Value = (filtroPesquisa ?? string.Empty).Trim();
                adapter.Fill(tabela);
            }

            return tabela;
        }

        public DataTable ObterLearningPaths()
        {
            var tabela = new DataTable();

            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT IdPath, NomePath
                FROM sc25_134.LearningPaths
                ORDER BY NomePath;", connection))
            using (var adapter = new SqlDataAdapter(command))
            {
                adapter.Fill(tabela);
            }

            return tabela;
        }

        public DataTable ObterNiveis()
        {
            var tabela = new DataTable();

            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                SELECT IdNivel, NomeNivel
                FROM sc25_134.Niveis
                ORDER BY IdNivel;", connection))
            using (var adapter = new SqlDataAdapter(command))
            {
                adapter.Fill(tabela);
            }

            return tabela;
        }

        public bool InserirBadge(string nome, string desc, int pontos, int idPath, int idNivel, string estado)
        {
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                INSERT INTO sc25_134.Badges (NomeBadge, Descricao, PontosPremio, IdPath, IdNivel, Estado)
                VALUES (@Nome, @Descricao, @Pontos, @IdPath, @IdNivel, @Estado);", connection))
            {
                command.Parameters.Add("@Nome", SqlDbType.NVarChar, 120).Value = nome.Trim();
                command.Parameters.Add("@Descricao", SqlDbType.NVarChar, 500).Value = (object)((desc == null ? string.Empty : desc.Trim()));
                command.Parameters.Add("@Pontos", SqlDbType.Int).Value = pontos;
                command.Parameters.Add("@IdPath", SqlDbType.Int).Value = idPath;
                command.Parameters.Add("@IdNivel", SqlDbType.Int).Value = idNivel;
                command.Parameters.Add("@Estado", SqlDbType.NVarChar, 20).Value = estado.Trim();

                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        public bool AtualizarBadge(int id, string nome, string desc, int pontos, string estado)
        {
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                UPDATE sc25_134.Badges
                SET NomeBadge = @Nome,
                    Descricao = @Descricao,
                    PontosPremio = @Pontos,
                    Estado = @Estado
                WHERE IdBadge = @Id;", connection))
            {
                command.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                command.Parameters.Add("@Nome", SqlDbType.NVarChar, 120).Value = nome.Trim();
                command.Parameters.Add("@Descricao", SqlDbType.NVarChar, 500).Value = (object)((desc == null ? string.Empty : desc.Trim()));
                command.Parameters.Add("@Pontos", SqlDbType.Int).Value = pontos;
                command.Parameters.Add("@Estado", SqlDbType.NVarChar, 20).Value = estado.Trim();

                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        public bool AtualizarBadge(int id, string nome, string desc, int pontos, int idPath, int idNivel, string estado)
        {
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand(@"
                UPDATE sc25_134.Badges
                SET NomeBadge = @Nome,
                    Descricao = @Descricao,
                    PontosPremio = @Pontos,
                    IdPath = @IdPath,
                    IdNivel = @IdNivel,
                    Estado = @Estado
                WHERE IdBadge = @Id;", connection))
            {
                command.Parameters.Add("@Id", SqlDbType.Int).Value = id;
                command.Parameters.Add("@Nome", SqlDbType.NVarChar, 120).Value = nome.Trim();
                command.Parameters.Add("@Descricao", SqlDbType.NVarChar, 500).Value = (object)((desc == null ? string.Empty : desc.Trim()));
                command.Parameters.Add("@Pontos", SqlDbType.Int).Value = pontos;
                command.Parameters.Add("@IdPath", SqlDbType.Int).Value = idPath;
                command.Parameters.Add("@IdNivel", SqlDbType.Int).Value = idNivel;
                command.Parameters.Add("@Estado", SqlDbType.NVarChar, 20).Value = estado.Trim();

                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }

        public bool EliminarBadge(int id)
        {
            using (var connection = new SqlConnection(_connectionString))
            using (var command = new SqlCommand("DELETE FROM sc25_134.Badges WHERE IdBadge = @Id;", connection))
            {
                command.Parameters.Add("@Id", SqlDbType.Int).Value = id;

                connection.Open();
                return command.ExecuteNonQuery() == 1;
            }
        }
    }
}
