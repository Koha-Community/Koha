<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Lecteurs</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

<style>
a.members {
	font-weight: normal;
	text-decoration: none;
	background-color: #86c268;
	cursor: hand;
	color:#FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.members:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: none;
	font-weight: bold;
	}
</style>

<!------------------------MENUS-------------------------------->
<table cellpadding=0 cellspacing=0 width="100%" border=0>
<tr height="65">
	<td valign="bottom" align="left">
		<table width="100%" cellpadding=0 cellspacing=0>
		<tr>
			<td>
			<div id="menubar">
			<table cellpadding=0 cellspacing=0  border=0 height=29 width=70%>
				<tr>
					<td class="koha"><b>KOHA</b></td>
					<td>
						<a class="home" href="/cgi-bin/koha/mainpage.pl">Accueil</a>
					</td>
					<td>
						<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Catalogue</a>
					</td>
					<td>
						<a class="members" href="/cgi-bin/koha/members-home.pl">Lecteurs</a>
					</td>
					<td>
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">Rapports</a>
					</td>
					<td>
						<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Paramètres</a>
					</td>
					<td>
						<a class="about" href="/cgi-bin/koha/about.pl">A propos</a>
					</td>
				</TR>
			</TABLE>
			</div>
			<table cellpadding=0 cellspacing=0  border=0 height=29>
				<tr>
					<td width="100"></td>
					<td><b>options &gt;&gt;&nbsp;&nbsp;</b></td>
					<td>
						<a href="/cgi-bin/koha/members-home.pl" class="submenu">Adresse Lecteur</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/simpleredirect.pl?type=Add&chooseform=adult" class="submenu2">Ajouter un lecteur</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/simpleredirect.pl?type=Add&chooseform=organisation" class="submenu">Ajouter une organisation</a>
					</td>
				</tr>
			</table>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Connecté comme: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>S'identifier</a> à Koha</p>
<!-- /TMPL_IF -->
