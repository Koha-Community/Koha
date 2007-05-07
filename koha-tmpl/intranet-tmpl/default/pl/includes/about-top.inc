<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: About</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<!-- TMPL_IF NAME="TemplateEncoding" --><meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME="TemplateEncoding" -->"><!-- TMPL_ELSE --><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><!-- /TMPL_IF -->
<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<style type="text/css">

.about {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	}
a.about:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	}
</style>
</head>
<body>


<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Zalogowano jako: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Wyloguj</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Zaloguj do</a> Systemu Koha</p>
<!-- /TMPL_IF -->
