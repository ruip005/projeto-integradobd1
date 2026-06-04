using System;
using SoftinsaBadgesWeb.App_Code;

namespace SoftinsaBadgesWeb
{
    public partial class Badges : System.Web.UI.Page
    {
        private readonly GestorDados _gestorDados = new GestorDados();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CarregarCombos();
                CarregarGrid();
            }
        }

        protected void btnPesquisa_Click(object sender, EventArgs e)
        {
            CarregarGrid(txtPesquisa.Text);
        }

        protected void btnLimparPesquisa_Click(object sender, EventArgs e)
        {
            txtPesquisa.Text = string.Empty;
            CarregarGrid();
        }

        protected void btnInserir_Click(object sender, EventArgs e)
        {
            if (!ValidarFormulario(incluirId: false, out var pontos, out _))
            {
                return;
            }

            try
            {
                var sucesso = _gestorDados.InserirBadge(
                    txtNome.Text,
                    txtDescricao.Text,
                    pontos,
                    Convert.ToInt32(ddlPath.SelectedValue),
                    Convert.ToInt32(ddlNivel.SelectedValue),
                    ddlEstado.SelectedValue);

                lblMensagem.Text = sucesso ? "Badge inserido com sucesso." : "Não foi possível inserir o badge.";
                if (sucesso)
                {
                    LimparFormulario();
                    CarregarGrid(txtPesquisa.Text);
                }
            }
            catch (Exception ex)
            {
                lblMensagem.Text = "Erro ao inserir: " + ex.Message;
            }
        }

        protected void btnAtualizar_Click(object sender, EventArgs e)
        {
            if (!ValidarFormulario(incluirId: true, out var pontos, out var idBadge))
            {
                return;
            }

            try
            {
                var sucesso = _gestorDados.AtualizarBadge(
                    idBadge,
                    txtNome.Text,
                    txtDescricao.Text,
                    pontos,
                    Convert.ToInt32(ddlPath.SelectedValue),
                    Convert.ToInt32(ddlNivel.SelectedValue),
                    ddlEstado.SelectedValue);

                lblMensagem.Text = sucesso ? "Badge atualizado com sucesso." : "Não foi possível atualizar o badge.";
                if (sucesso)
                {
                    LimparFormulario();
                    CarregarGrid(txtPesquisa.Text);
                }
            }
            catch (Exception ex)
            {
                lblMensagem.Text = "Erro ao atualizar: " + ex.Message;
            }
        }

        protected void btnLimparFormulario_Click(object sender, EventArgs e)
        {
            LimparFormulario();
            lblMensagem.Text = string.Empty;
        }

        protected void gvBadges_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvBadges.SelectedRow == null)
            {
                return;
            }

            var row = gvBadges.SelectedRow;
            txtIdBadge.Text = gvBadges.SelectedDataKey.Values["IdBadge"].ToString();
            txtNome.Text = Server.HtmlDecode(row.Cells[3].Text);
            txtDescricao.Text = row.Cells[4].Text == "&nbsp;" ? string.Empty : Server.HtmlDecode(row.Cells[4].Text);
            txtPontos.Text = Server.HtmlDecode(row.Cells[5].Text);
            ddlPath.SelectedValue = gvBadges.SelectedDataKey.Values["IdPath"].ToString();
            ddlNivel.SelectedValue = gvBadges.SelectedDataKey.Values["IdNivel"].ToString();
            ddlEstado.SelectedValue = Server.HtmlDecode(row.Cells[8].Text);
            lblMensagem.Text = "Registo carregado para edição.";
        }

        protected void gvBadges_RowDeleting(object sender, System.Web.UI.WebControls.GridViewDeleteEventArgs e)
        {
            var idBadge = Convert.ToInt32(gvBadges.DataKeys[e.RowIndex].Values["IdBadge"]);

            try
            {
                var sucesso = _gestorDados.EliminarBadge(idBadge);
                lblMensagem.Text = sucesso ? "Badge eliminado com sucesso." : "Não foi possível eliminar o badge.";
                if (sucesso)
                {
                    LimparFormulario();
                    CarregarGrid(txtPesquisa.Text);
                }
            }
            catch (Exception ex)
            {
                lblMensagem.Text = "Erro ao eliminar: " + ex.Message;
            }
        }

        private void CarregarGrid(string filtro = "")
        {
            gvBadges.DataSource = _gestorDados.ObterBadges(filtro);
            gvBadges.DataBind();
        }

        private void CarregarCombos()
        {
            var paths = _gestorDados.ObterLearningPaths();
            ddlPath.DataSource = paths;
            ddlPath.DataTextField = "NomePath";
            ddlPath.DataValueField = "IdPath";
            ddlPath.DataBind();

            var niveis = _gestorDados.ObterNiveis();
            ddlNivel.DataSource = niveis;
            ddlNivel.DataTextField = "NomeNivel";
            ddlNivel.DataValueField = "IdNivel";
            ddlNivel.DataBind();
        }

        private bool ValidarFormulario(bool incluirId, out int pontos, out int idBadge)
        {
            pontos = 0;
            idBadge = 0;

            if (string.IsNullOrWhiteSpace(txtNome.Text))
            {
                lblMensagem.Text = "O nome do badge é obrigatório.";
                return false;
            }

            if (!int.TryParse(txtPontos.Text, out pontos) || pontos < 0 || pontos > 1000)
            {
                lblMensagem.Text = "Os pontos devem ser um número inteiro entre 0 e 1000.";
                return false;
            }

            if (incluirId && !int.TryParse(txtIdBadge.Text, out idBadge))
            {
                lblMensagem.Text = "Selecione um registo da grelha antes de atualizar.";
                return false;
            }

            if (ddlPath.Items.Count == 0 || ddlNivel.Items.Count == 0)
            {
                lblMensagem.Text = "Não existem dados de suporte (Learning Paths/Níveis) para associar ao badge.";
                return false;
            }

            return true;
        }

        private void LimparFormulario()
        {
            txtIdBadge.Text = string.Empty;
            txtNome.Text = string.Empty;
            txtDescricao.Text = string.Empty;
            txtPontos.Text = string.Empty;

            if (ddlPath.Items.Count > 0)
            {
                ddlPath.SelectedIndex = 0;
            }

            if (ddlNivel.Items.Count > 0)
            {
                ddlNivel.SelectedIndex = 0;
            }

            ddlEstado.SelectedValue = "Ativo";
        }
    }
}
