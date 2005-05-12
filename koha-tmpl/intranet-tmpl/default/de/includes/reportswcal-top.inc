<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>KOHA: INTRANET: Reports</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<!-- Additions to enable Calendar system -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-system.css">
<!-- End of additions -->

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<!-- Additions to enable Calendar system -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-en.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/includes/calendar/calendar-setup.js"></script>
<!-- End of additions -->

<script language="JavaScript" type="text/javascript">
function Help() {
	newin=window.open("/cgi-bin/koha/help.pl","Koha Help",'width=600,height=600,toolbar=false,scrollbars=yes');
}
</script>

<style type="text/css">
.reports {
	background-color: #6b7cbe;
	color:#FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	background-image:none;
	}
a.reports:hover {
	background-color: #6b7cbe;
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
	<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Erwerbung</a> <a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet">Katalog</a> <a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Ausleihe</a> <a class="members" href="/cgi-bin/koha/members/members-home.pl">Benutzer</a> <a class="authority" href="/cgi-bin/koha/authorities/authorities-home.pl">Authorities</a> <a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a> <a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameter</a> <a class="about" href="/cgi-bin/koha/about.pl">&Uuml;ber</a> <a class="catalogue" href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">Hilfe</a>
</div>
<div id="submenu">
	<span class="koha">Optionen &gt;&gt;&nbsp;&nbsp;</span>
	<a href="/cgi-bin/koha/reports/manager.pl?report_name=itemtypes" class="submenu">Medientypen</a>
</div>

<!-- TMPL_IF NAME="loggedinusername" -->
    <p align="left">Angemeldet als: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">Abmelden</a>]</p>
<!-- TMPL_ELSE -->
    <p align="left"><a href="/cgi-bin/koha/opac-user.pl">Log In</a> to Koha</p>
<!-- /TMPL_IF -->
