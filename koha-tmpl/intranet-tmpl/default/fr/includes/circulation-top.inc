<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET:Prêt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
function focusOnFirst (){
document.forms[0].elements[0].focus();
}
// end hiding -->
</script>

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>


<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<style type="text/css">
.circulation {
	background-color: #be6170;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
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

<body onload="javascript:focusOnFirst()">

<!-- MENUS -->
<div id="menubar">
	<span class="koha"><a class="home" href="/cgi-bin/koha/mainpage.pl">Koha</a></span>
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a> <a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Catalogue</a> <a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Prêt</a> <a class="members" href="/cgi-bin/koha/members/members-home.pl">Lecteurs</a> <a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Autorités</a> <a class="reports" href="/cgi-bin/koha/reports-home.pl">Bilans</a> <a class="parameters" href="/cgi-bin/koha/admin-home.pl">Paramètres</a> <a class="about" href="/cgi-bin/koha/about.pl">A propos</a> <a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Aide</a>
</div>
<div id="submenu">
	<span class="koha">options >></span>
	<a href="/cgi-bin/koha/circ/circulation.pl" class="submenu">Sorties</a> <a href="/cgi-bin/koha/circ/returns.pl" class="submenu2">Retours</a> <a href="/cgi-bin/koha/circ/branchtransfers.pl" class="submenu">Transferts</a>
</div>

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Connecté en tant que : <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Connectez-vous</a> à Koha</p>
<!-- /TMPL_IF -->
