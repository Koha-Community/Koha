<!doctype html public "-//w3c//dtd html 4.0 transitional//en">

<html>
<head>
<title>KOHA: INTRANET: Parameters</title>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR name="themelang" -->/includes/common-style.css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<style>
.parameters {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
a.parameters:hover {
	background-color: #86c268;
	color: #FFFFFF;
	text-decoration: normal;
	font-weight: bold;
	}
</style>
</head>
<body>

<!------------------------MENUS-------------------------------->
<div id="menubar">
		<span class="koha">KOHA</span>
			<a class="home" href="/cgi-bin/koha/mainpage.pl">Home</a>
			<a class="catalogue" href="/cgi-bin/koha/loadmodules.pl?module=search&type=intranet">Catalogue</a>
			<a class="members" href="/cgi-bin/koha/members/members-home.pl">Members</a>
			<a class="acquisition" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions">Acquisitions</a>
			<a class="circulation"  href="/cgi-bin/koha/circ/circulation.pl">Circulation</a>
			<a class="reports" href="/cgi-bin/koha/reports-home.pl">Reports</a>
			<a class="parameters" href="/cgi-bin/koha/admin-home.pl">Parameters</a>
			<a class="about" href="/cgi-bin/koha/about.pl">About</a>
</div>
<div id="submenu">
	<span class="koha">options &gt;&gt;&nbsp;&nbsp;</span>
	<a href="/cgi-bin/koha/admin/aqbookfund.pl" class="submenu">Funds</a>
	<a href="/cgi-bin/koha/admin/authorised_values.pl" class="submenu2">Auth value</a>
	<a href="/cgi-bin/koha/admin/thesaurus.pl" class="submenu">Thesaurus</a>
	<a href="/cgi-bin/koha/admin/currency.pl" class="submenu2">Currencies</a>
	<a href="/cgi-bin/koha/admin/printers.pl" class="submenu">Printers</a>
</div>
<!-- TMPL_IF NAME="loggedinusername" -->
    <p align=left>Logged in as: <!-- TMPL_VAR NAME="loggedinusername" --> [<a href=/cgi-bin/koha/mainpage.pl?logout.x=1>Log Out</a>]</p>
<!-- TMPL_ELSE -->
    <p align=left><a href=/cgi-bin/koha/opac-user.pl>Log In</a> to Koha</p>
<!-- /TMPL_IF -->
