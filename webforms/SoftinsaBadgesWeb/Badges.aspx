<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Badges.aspx.cs" Inherits="SoftinsaBadgesWeb.Badges" ResponseEncoding="utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Softinsa Badges - CRUD</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; color: #222; }
        .row { margin-bottom: 10px; }
        .label { display: inline-block; width: 130px; font-weight: 600; }
        .input { box-sizing: border-box; max-width: 100%; width: 320px; }
        .actions { margin-top: 12px; }
        .msg { display: block; margin-top: 10px; font-weight: 600; }
        .grid { border-collapse: collapse; margin-top: 14px; margin-bottom: 24px; width: 100%; }
        .grid th, .grid td { border: 1px solid #d0d7de; padding: 8px; text-align: left; vertical-align: top; }
        .grid th { background: #f6f8fa; }
        @media (max-width: 720px) {
            body { margin: 12px; }
            .label { display: block; margin-bottom: 4px; width: auto; }
            .grid { display: block; overflow-x: auto; white-space: nowrap; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h1>Gestão de Badges</h1>

        <div class="row">
            <asp:Label ID="lblPesquisa" runat="server" CssClass="label" AssociatedControlID="txtPesquisa" Text="Pesquisar:" />
            <asp:TextBox ID="txtPesquisa" runat="server" CssClass="input" MaxLength="120" />
            <asp:Button ID="btnPesquisa" runat="server" Text="Filtrar" OnClick="btnPesquisa_Click" />
            <asp:Button ID="btnLimparPesquisa" runat="server" Text="Limpar" OnClick="btnLimparPesquisa_Click" />
        </div>

        <asp:GridView ID="gvBadges"
                      runat="server"
                      CssClass="grid"
                      AutoGenerateColumns="False"
                      DataKeyNames="IdBadge,IdPath,IdNivel"
                      OnSelectedIndexChanged="gvBadges_SelectedIndexChanged"
                      OnRowDeleting="gvBadges_RowDeleting"
                      EmptyDataText="Sem registos de badges.">
            <Columns>
                <asp:CommandField ShowSelectButton="True" SelectText="Selecionar" />
                <asp:CommandField ShowDeleteButton="True" DeleteText="Eliminar" />
                <asp:BoundField DataField="IdBadge" HeaderText="ID" ReadOnly="True" />
                <asp:BoundField DataField="NomeBadge" HeaderText="Nome" />
                <asp:BoundField DataField="Descricao" HeaderText="Descrição" />
                <asp:BoundField DataField="PontosPremio" HeaderText="Pontos" />
                <asp:BoundField DataField="NomePath" HeaderText="Learning Path" />
                <asp:BoundField DataField="NomeNivel" HeaderText="Nível" />
                <asp:BoundField DataField="Estado" HeaderText="Estado" />
            </Columns>
        </asp:GridView>

        <h2>Formulário de Inserção / Atualização</h2>

        <div class="row">
            <asp:Label ID="lblIdBadgeLabel" runat="server" CssClass="label" Text="ID Badge:" />
            <asp:TextBox ID="txtIdBadge" runat="server" CssClass="input" ReadOnly="true" />
        </div>

        <div class="row">
            <asp:Label ID="lblNome" runat="server" CssClass="label" AssociatedControlID="txtNome" Text="Nome Badge:" />
            <asp:TextBox ID="txtNome" runat="server" CssClass="input" MaxLength="120" />
        </div>

        <div class="row">
            <asp:Label ID="lblDescricao" runat="server" CssClass="label" AssociatedControlID="txtDescricao" Text="Descrição:" />
            <asp:TextBox ID="txtDescricao" runat="server" CssClass="input" TextMode="MultiLine" Rows="3" MaxLength="500" />
        </div>

        <div class="row">
            <asp:Label ID="lblPontos" runat="server" CssClass="label" AssociatedControlID="txtPontos" Text="Pontos:" />
            <asp:TextBox ID="txtPontos" runat="server" CssClass="input" MaxLength="4" />
        </div>

        <div class="row">
            <asp:Label ID="lblPath" runat="server" CssClass="label" AssociatedControlID="ddlPath" Text="Learning Path:" />
            <asp:DropDownList ID="ddlPath" runat="server" CssClass="input" />
        </div>

        <div class="row">
            <asp:Label ID="lblNivel" runat="server" CssClass="label" AssociatedControlID="ddlNivel" Text="Nível:" />
            <asp:DropDownList ID="ddlNivel" runat="server" CssClass="input" />
        </div>

        <div class="row">
            <asp:Label ID="lblEstado" runat="server" CssClass="label" AssociatedControlID="ddlEstado" Text="Estado:" />
            <asp:DropDownList ID="ddlEstado" runat="server" CssClass="input">
                <asp:ListItem Text="Ativo" Value="Ativo" />
                <asp:ListItem Text="Inativo" Value="Inativo" />
            </asp:DropDownList>
        </div>

        <div class="actions">
            <asp:Button ID="btnInserir" runat="server" Text="Inserir" OnClick="btnInserir_Click" />
            <asp:Button ID="btnAtualizar" runat="server" Text="Atualizar" OnClick="btnAtualizar_Click" />
            <asp:Button ID="btnLimparFormulario" runat="server" Text="Limpar Formulário" OnClick="btnLimparFormulario_Click" />
        </div>

        <asp:Label ID="lblMensagem" runat="server" CssClass="msg" />
    </form>
</body>
</html>
