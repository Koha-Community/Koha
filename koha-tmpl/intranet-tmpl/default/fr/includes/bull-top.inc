<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Gestion des périodiques</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<style type="text/css">
.bull {
	background-color: #803010;
	color:#FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	background-image:none;
	}
a.bull:hover {
	background-color: #803010;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>
</head>
<body>

<!-- MENUS -->
<div id="menubar">
	<span class="koha"><a class="home" href="/cgi-bin/koha/mainpage.pl">Koha</a></span>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>  <a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a>  <a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>  <a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>  <a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a>  <a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>  <a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>  <a class="about" href="/cgi-bin/koha/about.pl">About</a>  <a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Help</a>
</div>
<div id="submenu">
	<span class="koha">options >></span>
	<a href="/cgi-bin/koha/bull-home.pl" class="submenu">Recherche abonnement</a>
</div>

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Connecté en tant que : <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Connectez-vous</a> à Koha</p>
<!-- /TMPL_IF -->
