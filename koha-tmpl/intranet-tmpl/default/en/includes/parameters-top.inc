<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Parameters</title>
<!-- Additions to enable Calendar system -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-system.css">
<!-- End of additions -->

<meta http-equiv="Content-Type" content="text/html; charset=utf8">
<!-- Additions to enable Calendar system -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-en.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-setup.js"></script>
<!-- End of additions -->

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">

<style type="text/css">
.parameters {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	background-image:none;
	}
a.parameters:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	}
</style>
</head>
<body>

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<!-- TMPL_INCLUDE name="menus.inc" -->
<!-- TMPL_IF NAME="loggedinusername" -->
    <p class="user">Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p class="user"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
