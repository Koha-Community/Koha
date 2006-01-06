<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA : INTRANET : Acquisitions</title>
<link rel="stylesheet" type="text/css" media="print" href="<!-- TMPL_VAR name="themelang" -->/includes/common-print.css">
<link rel="stylesheet" type="text/css" media="screen" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<!-- Additions for Calendar-system -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-system.css">
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar.js">
</script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-en.js">
</script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-setup.js">
</script>
<!-- /Additions for Calendar-system -->

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<style type="text/css">
.acquisition {
	background-color: #ffdf61;
	color:#000000;
	background-image:none;
	text-decoration: normal;
	}
a.acquisition:hover {
	background-color: #ffdf61;
	color: #000000;
	text-decoration: normal;
	}
</style>
</head>
<body>


<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Connecté en tant que : <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Déconnecter</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Connectez-vous</a> à Koha</p>
<!-- /TMPL_IF -->
