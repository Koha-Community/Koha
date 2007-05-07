<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>KOHA: INTRANET: Cat&aacute;logo</title>
<!-- TMPL_IF NAME="TemplateEncoding" --><meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME="TemplateEncoding" -->"><!-- TMPL_ELSE --><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><!-- /TMPL_IF -->

<script language="JavaScript" type="text/javascript">
<!-- Hide from old browsers
function openWindow(targeturl, windowname) {
	newwin =
window.open(targeturl,windowname,"height=480,width=640,scrollbars,resizable")
}
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
// end hiding -->
</script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
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

<body>

<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Registrado como: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Salir</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Entrar</a> a Koha</p>
<!-- /TMPL_IF -->

