<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Catalogue</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<script language="JavaScript" type="text/javascript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
// end hiding -->
</script>

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/marc-editor.css">
<style type="text/css">
.catalogue {
	background-color:#ad11ad;
	color:#FFFFFF;
	background-image:none;
	text-decoration: normal;
	}
a.catalogue:hover {
	background-color: #ad11ad;
	color: #FFFFFF;
	text-decoration: none;
	}
</style>
</head>

<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Connecté en tant que : <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Connectez-vous</a> à Koha</p>
<!-- /TMPL_IF -->
