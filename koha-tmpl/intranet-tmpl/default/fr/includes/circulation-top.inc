<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Circulation</title>

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
// end hiding -->
</script>

<link rel="stylesheet" type="text/css" href="<TMPL_VAR name="themelang">/includes/common-style.css">
<style>
a.circulation {
	font-weight: normal;
	text-decoration: none;
	background-color: #be6170;
	cursor: hand;
	color:#FFFFFF;
	padding:4px;
	font-weight: bold;
	}
a.circulation:hover {
	background-color: #be6170;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>
</head>
<body text="black" bgcolor="white" link="#0000ff" vlink="#0000ff" "3366cc" Alink="#cc3300"
marginheight=0 marginwidth=0 leftmargin=0 topmargin=0>

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
						<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisition</a>
					</td>
					<td>
						<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
					</td>
					<td>
						<a class="reports" href="/cgi-bin/koha/reports-home.pl">Etats</a>
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
						<a href="/cgi-bin/koha/circ/circulation.pl" class="submenu">Prêts</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/circ/returns.pl" class="submenu2">Retours</a>
					</td>
					<td>
						<a href="/cgi-bin/koha/circ/branchtransfers.pl" class="submenu">Transferts</a>
					</td>
				</tr>
			</table>
			</div>
		</td></tr></table>
	</TD>
</tr>
</table>
<BLOCKQUOTE>
<TMPL_IF NAME="loggedinusername">
    <p align=left>Connecté en tant que : <TMPL_VAR NAME="loggedinusername"> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Déconnecter</a>]</p>
<TMPL_ELSE>
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Se connecter</a> à Koha</p>
</TMPL_IF>
