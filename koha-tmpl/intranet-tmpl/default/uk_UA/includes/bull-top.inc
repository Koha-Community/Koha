<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>КОХА: ІНТЕРФЕЙС БІБЛІОТЕКАРЯ: Управління періодичними виданнями</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<!-- TMPL_IF NAME="TemplateEncoding" --><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><!-- TMPL_ELSE --><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><!-- /TMPL_IF -->
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
	background-image:none;
	}
a.bull:hover {
	background-color: #803010;
	color: #FFFFFF;
	text-decoration: normal;
	}
</style>
</head>
<body>

<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Зайдено у систему як: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Вихід</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Реєструватися</a> у Коха</p>
<!-- /TMPL_IF -->
